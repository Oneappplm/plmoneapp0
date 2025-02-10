class Users::SessionsController < Devise::SessionsController
  def create
    if current_user.present?
      if current_setting.qualifacts? && !current_user&.super_administrator?
        sign_out current_user
        redirect_to root_path, alert: "You are not allowed to authenticate the system. Please contact the administrator." and return
      end

     if Rails.env.production? && current_setting.enable_otp?
        current_user.generate_otp_code_and_expiration
        current_user.send_otp_code
        redirect_url = request_otp_code_otp_path(current_user.otp_token)
        sign_out(resource_name)
        redirect_to redirect_url, notice: "An OTP Code has been sent to your email. Please check your email." and return
      else
        super
      end
    else
      if current_setting.qualifacts?
       redirect_to root_path, alert: "You are not allowed to authenticate the system."
      else
       self.resource = warden.authenticate!(auth_options)
       set_flash_message!(:notice, :signed_in)
       sign_in(resource_name, resource)
       yield resource if block_given?
       respond_with resource, location: after_sign_in_path_for(resource)
      end
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

  def logout_url
    request_params = {
      returnTo: root_url,
      client_id: Figaro.env.auth0_client_id
    }

    URI::HTTPS.build(host: Figaro.env.auth0_domain, path: '/v2/logout', query: request_params.to_query).to_s
  end
end
