const onloadAuthorizeTwitter = window.onload || (() => { });
window.onload = () => {
  const authorize = async () => {
    if (window.location.href.indexOf('?') === -1) {
      window.open('https://api.twitter.com/oauth/authorize?' + new URLSearchParams({
        oauth_token: (await call('GET', '/twitter/init')).token
      }), '_self');
      return;
    }
    const params = new URLSearchParams(window.location.search);
    const tokens = await call('GET', '/twitter/authorize', {
      oauth_token: params.get('oauth_token'),
      oauth_verifier: params.get('oauth_verifier')
    });
    console.log(tokens);
  };
  authorize();
  onloadAuthorizeTwitter();
};
