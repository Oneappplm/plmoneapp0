class ApplicationController < ActionController::Base
	before_action :authenticate_user!, except: %i[terms privacy_policy]
	before_action :configure_permitted_parameters, if: :devise_controller?

	protected
	 def configure_permitted_parameters
    update_params = [:first_name, :last_name, :user_type, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit(:account_update, keys: update_params)
				devise_parameter_sanitizer.permit(:sign_up, keys: update_params)
  end
end
