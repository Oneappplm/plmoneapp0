# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider(
#     :auth0,
#     Figaro.env.auth0_client_id,
#     Figaro.env.auth0_client_secret,
#     Figaro.env.auth0_domain,
#     callback_path: '/auth/auth0/callback',
#     authorize_params: {
#       scope: 'openid profile email'
#     }
#   )
# end
# config/initializers/auth0.rb

Rails.application.config.middleware.use OmniAuth::Builder do
  client_id     = ENV['AUTH0_CLIENT_ID'] || Figaro.env.auth0_client_id
  client_secret = ENV['AUTH0_CLIENT_SECRET'] || Figaro.env.auth0_client_secret
  domain        = ENV['AUTH0_DOMAIN'] || Figaro.env.auth0_domain

  if client_id.blank? || client_secret.blank? || domain.blank?
    raise "Auth0 ENV vars missing"
  end

  provider(
    :auth0,
    client_id,
    client_secret,
    domain,
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile email'
    }
  )
end
