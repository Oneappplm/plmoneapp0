class Users::SessionsController < Devise::SessionsController
  before_action :set_captcha, only: [:new, :create]

  def create
    sign_out(resource_name) if user_signed_in?
  
    if params[:captcha_answer].to_i != (session[:captcha_num1] + session[:captcha_num2])
      set_captcha
      flash[:alert] = "Captcha answer is incorrect"
      redirect_to new_user_session_path and return
    end  

    if current_user.present?
      if Rails.env.production? && current_setting.enable_otp?
        current_user.generate_otp_code_and_expiration
        current_user.send_otp_code
        redirect_url = request_otp_code_otp_path(current_user.otp_token)
        sign_out(resource_name)
        redirect_to redirect_url, notice: "An OTP Code has been sent to your email. Please check your email." and return
      else
        super
        log_login_activity(resource)
      end
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  def destroy
    logout
  end

  def logout
    reset_session

    redirect_to logout_url, allow_other_host: true
  end

  private

  def log_login_activity(user)
    CustomAudit.create!(
      auditable: user,
      auditable_type: 'User',
      action: 'login',
      user_id: user.id,
      audited_changes: { 'Login' => "User #{user.full_name} logged in at #{Time.current}" }
    )
  end

  def set_captcha
    session[:captcha_num1] ||= rand(1..10)
    session[:captcha_num2] ||= rand(1..10)
  end

  def logout_url
    request_params = {
      returnTo: root_url,
      client_id: Figaro.env.auth0_client_id
    }

    URI::HTTPS.build(host: Figaro.env.auth0_domain, path: '/v2/logout', query: request_params.to_query).to_s
  end
end

  