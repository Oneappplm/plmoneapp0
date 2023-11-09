Rails.application.routes.draw do
  resources :hvhs_data
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'dashboard#dashboard' # Overview	page
  get 'client-portal', to: 'pages#client_portal' # Data Access page
  get 'virtual-review-committee', to: 'pages#virtual_review_committee' # Decision Point page
  get 'provider-engage', to: 'provider_app#provider_source', as: :custom_provider_source # Provider Engage page

		get 'show-virtual-review-committee', to: 'pages#show_virtual_review_committee'
		get 'app-tracker', to: 'pages#app_tracker'
  get 'encompass', to: 'pages#encompass'
  get 'microsite', to: 'pages#microsite'
  get 'ps-office-manager', to: 'pages#ps_office_manager'
  get 'plm-sales-tool', to: 'pages#plm_sales_tool'
  get 'help', to: 'pages#help'
  # get 'settings', to: 'pages#settings'
  get 'show-client-details', to: 'pages#show_client_details'
  get 'smart-contract', to: 'pages#smart_contract'
  get 'terms', to: 'pages#terms'
  get 'privacy-policies', to: 'pages#privacy_policy'
  # get 'providers', to: 'pages#providers'
  get 'provider-enrollment', to: 'pages#provider_enrollment'
  # get 'enrollments', to: 'pages#enrollments'
  # get 'new-enrollment', to: 'pages#new_enrollment'
  get 'clients', to: 'pages#all_clients'
  get 'provider-clients', to: 'pages#provider_clients'
  get 'new-dco', to: 'pages#new_dco'
  get 'enroll-new-user', to: 'pages#enroll_new_user'
  get 'new-group', to: 'pages#new_group'
  get 'new-group-enrollment', to: 'pages#new_group_enrollment'
  get 'data-access', to: 'pages#data_access' #made this to not conflict with active state of client portal but for now same view

  post 'delete-record', to: 'ajax#delete_record'
  post 'group-dco-note', to: 'ajax#create_group_dco_note'
  post 'provider-note', to: 'ajax#create_provider_note'
  post 'create-enrollment-comment', to: 'ajax#create_enrollment_comment'
  post 'create-roles', to: 'ajax#create_roles'
  post 'get-group-dcos', to: 'ajax#get_group_dcos'
  post 'get-provider-payers', to: 'ajax#get_provider_payers'
  post 'get-enrollment-status-count', to: 'ajax#get_enrollment_status_count'
  post 'change-enrollment-status', to: 'ajax#change_enrollment_status'
  get 'get-provider-types', to: 'ajax#get_provider_types'
  get 'get-enrollment-groups', to: 'ajax#get_enrollment_groups'
  get 'get-group-locations', to: 'ajax#get_enrollment_group_locations'
  get 'get-provider-notification-services', to: 'ajax#get_provider_notification_services'
  get 'get-group-notification-services', to: 'ajax#get_group_notification_services'
  post 'get-selected-provider-types', to: 'ajax#get_selected_provider_types'
  post 'get-selected-practitioner-types', to: 'ajax#get_selected_practitioner_types'
  get 'get-ps-provider-types', to: 'ajax#get_ps_provider_types'
  post 'get-selected-ps-provider-types', to: 'ajax#get_selected_ps_provider_types'
  get 'get-mixed-providers-options', to: 'ajax#get_mixed_providers_options'
  post 'get-selected-mixed-providers-options', to: 'ajax#get_selected_mixed_providers_options'
  get 'get-providers', to: 'ajax#get_providers'
  get 'get-provider', to: 'ajax#get_provider'
  post 'get-selected-providers', to: 'ajax#get_selected_providers'
  get 'get-states', to: 'ajax#get_states'
  post 'get-selected-states', to: 'ajax#get_selected_states'
  get 'get-visa-types', to: 'ajax#get_visa_types'
  post 'get-selected-visa-types', to: 'ajax#get_selected_visa_types'
  get 'get-languages', to: 'ajax#get_languages'
  post 'get-selected-languages', to: 'ajax#get_selected_languages'
  get 'get-countries', to: 'ajax#get_countries'
  post 'get-selected-countries', to: 'ajax#get_selected_countries'
  get 'doughnut-data', to: 'ajax#get_dougnut_data'
  post 'get-dashboard-providers', to: 'ajax#get_dashboard_providers'
  post 'update-collapse', to: 'ajax#update_collapse'
  get 'monthly-visits', to: 'ajax#get_monthly_visits'
  get 'browser-visits', to: 'ajax#browser_visits'
  get 'state-providers', to: 'ajax#state_providers'
  get 'providers-gender', to: 'ajax#providers_gender'
  get 'get-specialties', to: 'ajax#get_specialties'
  get 'get-languages', to: 'ajax#get_languages'
  get 'get-states', to: 'ajax#get_states'
  post 'get-provider-practitioner-types', to: 'ajax#get_provider_practitioner_types'
  post 'get-provider-specialties', to: 'ajax#get_provider_specialties'
  post 'update-timeline', to: 'ajax#update_timeline'
  get 'get-group-roles', to: 'ajax#get_group_roles'
  post 'get-selected-group-roles', to: 'ajax#get_selected_group_roles'
  get 'get-states-with-id', to: 'ajax#get_states_with_id'
  post 'mark-notification-read', to: 'ajax#mark_notification_read'
  post 'logout-on-close', to: 'ajax#logout_on_close'

  resources :manage_clients


  resources :provider_sources do
    collection do
      post :autosave
      get :fetch
      post :get_progress
      post :autosave_multi_record
    end
  end

  resources :alt_enrollment_groups, path: 'alt-enrollment-groups' do
    get :documents
    get :enrollments
    get :providers
    resources :locations
  end

  resources :notifications, only: [:index]

  resources :missing_field_submissions

  # added these two resources just to make it different to pages_controller for now it doesn't have any model
  resources :verification_platform, path: 'verification-platform'
  resources :office_managers, path: 'group-engage' do
    collection do
      post :send_invitation
      post :bulk_remove_providers
      post :send_invite
						get :manage_practice_locations
    end
    member do
      get :manage_applications
      post :credentialing_application
      post :view_summary
      post :re_attest_application
      post :remove_provider
    end
  end

  resources :practice_locations
  resources :group_engage_providers, path: 'group-engage-providers' do
    member do
      post :add_to_roster
    end
    collection do
      get :search
    end
  end
  resource :client_organizations


  resources :time_lines, path: 'time-lines'
  resources :manage_clients, path: 'manage-clients'
  resources :manage_practitioners, path: 'manage-practitioners'
  resources :work_ticklers, path: 'work-ticklers'

  resources :comments
  resources :query_reports, path: 'query-reports' do
    collection do
      get :staff_directory, path: 'staff-directory'
      get :provider_directory, path: 'provider-directory'
      get :privilege_reporting_tool, path: 'privilege-reporting-tool'
      get :meeting_report_by_practitioner, path: 'meeting-report-by-practitioner'
      get :cme_practitioner_profile, path: 'cme-practitioner-profile'
      get :customize_reporting_service, path: 'customize-reporting-service'
    end
  end

  resources :providers do
    put :update_from_notifications, path: 'update-from-notifications'

    collection do
      get "overview"
      get :document_deleted_logs
      post :delete_document
    end
  end
  resources :enrollments do
    collection do
      get :new_user, path: 'new-user'
      post :new_user, path: 'new-user'
      get :groups
      get :new_group, path: 'new-group'
      post :new_group, path: 'new-group'
      get :document_deleted_logs
      post :delete_document
      resources :groups do
        post :get_dcos
        resources :dcos
      end
    end
    member do
      get :delete_user
      get :edit_user, path: 'edit-user'
      patch :edit_user, path: 'edit-user'
      post :delete_group
      get :edit_group, path: 'edit-group'
      patch :edit_group, path: 'edit-group'
    end
  end
  resources :enrollment_providers, path: 'enrollment-providers'
  resources :client_provider_enrollments, path: 'client-provider-enrollments', only: [:index, :show]
  resources :enroll_groups, path: 'enrollment-groups'
  resources :enrollment_clients, path: 'enrollment-clients' do
    collection do
      get :download_documents
      get :reports
      get :notifications
      get :dashboard
      get :groups
      get :view_group
    end
  end

  resources :systems do
    collection do
      get :sub_features, path: 'sub-features'
      get :securables
      get :acl
      get :data_lookup, path: 'data-lookup'
      get :data_import, path: 'data-import'
    end
  end
  resources :settings do
    collection do
      resources :roles
      resources :users
    end
  end
  resources :role_based_accesses, only: [:index], path: 'role-based-access' do
    member do
      post :update_access
    end
    collection do
      post :delete_role
    end
  end
  resources :pals_verifications, only: [:index], path: 'pals-verification'

  resources :manage_tools, path: 'manage-tools' do
    collection do
      post :creation_of_schedule
      get :manage_cme, path: 'manage-cme'
      get :meeting_attendance, path: 'meeting-attendance'
      get :call_schedule_maintenance, path: 'call-schedule-maintenance'
      get :call_schedule_group_maintenance, path: 'call-schedule-group-maintenance'
      get :generate_call_schedule, path: 'generate-call-schedule'
      get :generate_alpha_order_call_schedule, path: 'generate-alpha-order-call-schedule'
      get :call_schedule, path: 'calendar-view/call-schedule'
      get :cme_calendar, path: 'calendar-view/cme-calendar'
      get :meetings_calendar, path: 'calendar-view/meetings-calendar'
      get :daily_report, path: 'daily-report'
      get :health_plan_contract_enrollment, path: 'health-plan-contract-enrollment'
      get :site_review_questionnaire, path: 'site-review-questionnaire'
      get :correction_action_plan, path: 'correction-action-plan'
      get :define_privileges, path: 'define-privileges'
    end
  end



  resources :view_summary

  devise_scope :user do
    # Redirests signing out users back to sign-in
    get "users", to: "devise/sessions#new"
  end

  devise_for :users, controllers: {
    invitations: 'users/invitations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
  }

  get 'organization-profile', to: 'users#organization_profile'
  get 'new-user', to: 'users#new'
  get 'organization-users', to: 'users#organization_users'
  get 'client-portal-search', to: 'pages#client_search'
  get 'download-clients', to: 'pages#download_clients'

  namespace :webscrapers do
    root to: 'logs#index'
    resources :alaska_states, only: [:index], path: 'state-alaska' do
      collection do
        get :crawl
        get :clear
      end
    end
    resources :california_states, only: [:index], path: 'state-california' do
      collection do
        get :crawl
        get :clear
      end
    end
  end
  namespace :enrollment_trackings do
    root to: 'overviews#index'
  end
  resources :auto_verifies, only: [:index], path: 'auto-verify' do
    collection do
      get :download_as_pdf
    end
  end
  resources :multi_select_data, only: [], path: 'multi-select-data' do
    collection do
      get :states
      get :provider_types
      get :countries
      get :visa_types
      get :languages
      get :health_plans
      get :hospitals
      get :directories
      get :specialties
      get :training_types
      get :privilege_statuses
      get :providers
      get :enrollment_payers
      get :provider_states, path: 'provider-states'
      get :board_names
      get :group_states, path: 'group-states'
      get :serviced_populations
      get :method_resolutions
      # add more here
    end
  end

  resources :enrollment_payers do
    collection do
      post :add_payer
      post :delete_payer
    end
  end

  resources :otps do
    member do
      get :request_otp_code
      post :request_otp_code
    end
  end

  namespace :api do
    namespace :v1 do
      resources :providers, only: [:index, :create]
      resources :enrollment_providers, only: [:index], path: 'enrollment-providers'
      resources :enroll_groups, only: [:index], path: 'enrollment-groups'
      resources :groups, only: [:index], path: 'groups'
      resources :dcos, only: [:index]
    end
  end
end
