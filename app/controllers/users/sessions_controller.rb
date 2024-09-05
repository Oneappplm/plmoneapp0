class Users::SessionsController < Devise::SessionsController
  def create
    if current_user.present?
      # if current_setting.qualifacts? && !["deborah.jodway@qualifacts.com"].include?(current_user.email)
      #   sign_out current_user
      #   redirect_to root_path, alert: "You are not allowed to authenticate the system." and return
      # end

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
end
