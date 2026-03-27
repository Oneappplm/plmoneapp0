class Auth0Controller < ActionController::Base
  protect_from_forgery with: :exception
  
  def callback
    auth_info = request.env['omniauth.auth']
 
    user = User.from_omniauth(auth_info)
    if user
     sign_in(user)
     session[:uid] = auth_info['uid']

     redirect_to root_path, notice: 'You have successfully logged in.'
    else
     redirect_to root_path, alert: 'An error occurred or the email could not be found.'
    end
  end

  def logout(error_message = nil)
    reset_session

    redirect_to logout_url(error_message), allow_other_host: true
  end

  private

  def logout_url error_message = nil
    request_params = {
      returnTo: root_url(error_message: error_message),
      client_id: Figaro.env.auth0_client_id
    }

    URI::HTTPS.build(host: Rails.application.config_for(:auth0)['auth0_domain'], path: '/v2/logout', query: request_params.to_query).to_s
  end
end
