Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    Figaro.env.auth0_client_id,
    Figaro.env.auth0_client_secret,
    Figaro.env.auth0_domain,
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile email'
    }
  )
end
