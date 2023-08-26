class Users::SessionsController < Devise::SessionsController
	before_action :can_create?, except: [:new, :create]

  def create

    if current_user.present?
      if Rails.env.production?
        current_user.generate_otp_code_and_expiration
        current_user.send_otp_code
        redirect_url = request_opt_code_otp_path(current_user.otp_token)
        sign_out(resource_name)
        redirect_to redirect_url, notice: "An OTP Code has been sent to your email. Please check your email." and return
      else
        super
      end
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end


    # if Rails.env.production?
    #   if verify_recaptcha(model: resource)
    #     self.resource = warden.authenticate!(auth_options)
    #     set_flash_message!(:notice, :signed_in)
    #     sign_in(resource_name, resource)
    #     yield resource if block_given?
    #     respond_with resource, location: after_sign_in_path_for(resource)
    #     return
    #   else
    #     sign_out(resource_name)
    #     # respond_with resource, location: after_sign_in_path_for(resource)
    #     redirect_to new_user_session_path, alert: "reCAPTCHA verification failed." and return
    #   end
    # else

    # end
  end
end