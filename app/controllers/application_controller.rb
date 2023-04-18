class ApplicationController < ActionController::Base
	before_action :authenticate_user!, except: %i[terms privacy_policy]
	before_action :configure_permitted_parameters, if: :devise_controller?
	include ApplicationHelper

	protected
	 def configure_permitted_parameters
    update_params = [:first_name, :last_name, :user_type, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit(:account_update, keys: update_params)
				devise_parameter_sanitizer.permit(:sign_up, keys: update_params)
  end

  def search_inputs
  	keys = %w[first_name last_name city state_abbr zipcode
  			  npi ssn medv_id cred_status vrc_status full_name
  			  cred_cycle medv_ids entity tin from_attest_date
  			  to_attest_date birth_date provider_type specialty]

	  @search_inputs = keys.map { |k| [k, params[k.to_sym]] }.to_h
  end
end

