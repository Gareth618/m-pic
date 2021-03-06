drop table if exists photos;
drop table if exists profiles;
drop table if exists users;

create table users (
  id serial primary key,
  email varchar not null,
  password varchar not null
);

create table profiles (
  id serial primary key,
  user_id int not null,
  platform varchar not null,
  code varchar not null,
  token varchar,

  constraint fkey_profiles_users
    foreign key (user_id)
    references users (id)
    on delete cascade
);

create table photos (
  id serial primary key,
  user_id int not null,
  uri varchar not null,
  created_at date not null,

  constraint fkey_photos_users
    foreign key (user_id)
    references users (id)
    on delete cascade
);
