class ApplicationController < ActionController::Base
	before_action :can_read?, only: [
		:index, :show, :overview, :dashboard, :client_portal, :provider_source, :plm_sales_tool,
		:organization_profile, :virtual_review_committee
	]
	before_action :can_create?, only: [:new, :create]
	before_action :can_update?, only: [:edit, :update, :autosave]
	before_action :can_delete?, only: [:destroy]

	before_action :authenticate_user!, except: %i[terms privacy_policy]
	before_action :configure_permitted_parameters, if: :devise_controller?
  # exceptions for track_event are mostly ajax requests
  before_action :track_event, except: [:delete_record, :get_group_dcos, :get_provider_payers,
                                       :get_enrollment_status_count, :change_enrollment_status, :get_provider_types,
                                       :get_selected_provider_types, :get_dougnut_data, :update_collapse, :get_dashboard_providers,
                                       :get_monthly_visits, :browser_visits, :autosave, :get_progress, :fetch
                                      ]
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

  def track_event
    ahoy.track "Visited page", visit_properties
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
end

