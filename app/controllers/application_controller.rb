class ApplicationController < ActionController::Base
	before_action :authenticate_user!, except: %i[terms privacy_policy]
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :ensure_security_questions_set, if: :user_signed_in?
  # exceptions for track_event are mostly ajax requests
	before_action :track_event
	before_action { filter_params params }

  # before_action :force_logout_on_close_if_expired, except: [:logout_on_close] # TODO: uncomment this line

	include ApplicationHelper

	protected

  def skip_validation_for_enrollment_clients?
    !(current_user.present? && current_user.is_provider_account && controller_name == "enrollment_clients" && %w[index show].include?(action_name))
  end

	 def configure_permitted_parameters
    update_params = [:first_name, :last_name, :user_type, :password, :password_confirmation, :current_password, :security_question, :security_answer]
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

  def track_event
    ahoy.track "Visited page", visit_properties unless request.xhr?
  end

  def force_logout_on_close_if_expired
    if current_user.present?
      if current_user.logout_on_close? && current_user.expired_logout_on_close?
        current_user.reset_logout_on_close
        sign_out(current_user)
        redirect_to new_user_session_path, alert: "Your session has expired. Please sign in again." and return
      else
        current_user.reset_logout_on_close
      end
    end
  end

		# Recursively process the params hash
		def filter_params(params)
			params.each do |key, value|
					if value.is_a?(Hash) || value.is_a?(ActionController::Parameters)
							#	process nested hashes
							filter_params(value)
					elsif value.is_a?(Array)
							#	process nested arrays
							value.each { |item| filter_params(item) if item.is_a?(Hash) || item.is_a?(ActionController::Parameters) }
					elsif value.is_a?(String) && value.match(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
						# custom date format for date fields in the form (mm/dd/yyyy) to be converted to (yyyy-mm-dd)
						params[key] = Date.strptime(value, '%m/%d/%Y').strftime('%Y-%m-%d')
					# elsif add	more conditions here if needed
					end
			end
		end

		def redirect_to_default_page

			render partial: 'shared/access_denied' and return if current_user.default_page ==	'access_denied'

			cname, aname = current_user.landing_page
			return if cname == 'overview' &&	aname == 'index'

			menu = menu_links[cname.to_sym][aname.to_sym]
			menu = menu_links[cname.to_sym] if	menu.nil?

			render partial: 'shared/access_denied' and	return if menu[:controller].nil? && menu[:action].nil?
			redirect_to controller: menu[:controller],	action: menu[:action]
		rescue
			render partial: 'shared/access_denied'
		end

  private

  def visit_properties
    user_agent = request.user_agent
    client = DeviceDetector.new(user_agent)
    {
      page: action_name,
      controller: controller_name,
      device_type: client.device_type,
      browser: client.name,
      device_name: client.device_name,
      id: params[:id]
    }
  end

  def ensure_security_questions_set
    return if request.path == edit_security_question_path(current_user) || request.path == security_question_path(current_user)

    if current_user.security_question.blank? || current_user.security_answer.blank?
      redirect_to edit_security_question_path(current_user)
    end
  end
end

