-----------
-- USERS --
-----------

create or replace function sign_in (p_email varchar, p_password varchar)
  returns varchar
  language plpgsql
as
$$
declare
  user_id int;
  user_password users.password%type;
begin
  select id, password
    into user_id, user_password
    from users u
    where u.email = p_email;
  if not found or p_password <> user_password then
    return 'wrong username or password';
  else
    return 'signed in user with id ' || user_id;
  end if;
end
$$;

create or replace function sign_up (p_email varchar, p_password varchar)
  returns varchar
  language plpgsql
as
$$
declare
  count_users int;
  new_id int;
begin
  select count(*)
    into count_users
    from users u
    where u.email = p_email;
  if count_users = 0 then
    insert into
      users (email, password)
      values (p_email, p_password)
      returning id into new_id;
    return 'created user with id ' || new_id;
  else
    return 'email already in use';
  end if;
end
$$;

create or replace procedure delete_user (p_id int)
  language plpgsql
as
$$
begin
  delete
    from users u
    where u.id = p_id;
end
$$;


--------------
-- PROFILES --
--------------

create or replace function add_profile (p_id_user int, p_platform varchar)
  returns varchar
  language plpgsql
as
$$
declare
  count_profiles int;
  new_id int;
begin
  select count(*)
    into count_profiles
    from profiles p
    where p.id_user = p_id_user and p.platform = p_platform;
  if count_profiles = 0 then
    insert into
      profiles (id_user, platform, logged_in)
      values (p_id_user, p_platform, true)
      returning id into new_id;
    return 'created profile with id ' || new_id;
  else
    return 'platform already in use';
  end if;
end
$$;

create or replace procedure delete_profile (p_id int)
  language plpgsql
as
$$
begin
  delete
    from profiles p
    where p.id = p_id;
end
$$;


------------
-- IMAGES --
------------

create or replace function post_image (
  p_id_user int,
  p_post_file bytea,
  p_post_profiles_ids int[],
  p_post_tags varchar[] default null,
  p_post_text varchar default null
)
  returns int
  language plpgsql
as
$$
declare
  tag varchar;
  profile int;
  tag_id tags.id%type;
  profile_id profiles.id%type;
  new_id int;
begin
  insert into
    images (id_user, post_file, post_text, post_date)
    values (p_id_user, p_post_file, p_post_text, current_timestamp)
    returning id into new_id;

  foreach tag in array p_post_tags loop
    select id
      into tag_id
      from tags
      where tags.title = tag;
    if not found then
      insert into
        tags (title)
        values (tag)
        returning id into tag_id;
    end if;
    insert into
      image_tag (id_image, id_tag)
      values (new_id, tag_id);
  end loop;

  foreach profile in array p_post_profiles_ids loop
    select id
      into profile_id
      from profiles
      where profiles.id_user = p_id_user
      and profiles.id = profile;
    if found then
      insert into
        image_profile (id_image, id_profile)
        values (new_id, profile_id);
    end if;
  end loop;

  return new_id;
end
$$;

create or replace function search_images (
  p_id_user int,
  p_post_profiles_ids int[] default null,
  p_post_tags varchar[] default null
)
  returns table (j json)
  language plpgsql
as
$$
begin
  return query
    select json_agg(t)
    from (
      select *
        from images
        where images.id_user = p_id_user
        and array (
          select id
          from profiles
          where id in (
            select id_profile
            from image_profile
            where id_image = images.id
          )
        ) @> p_post_profiles_ids
        and array (
          select title
          from tags
          where id in (
            select id_tag
            from image_tag
            where id_image = images.id
          )
        ) @> p_post_tags
    ) t;
end
$$;
