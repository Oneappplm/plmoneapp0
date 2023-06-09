Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'dashboard#dashboard'
  get 'client-portal', to: 'pages#client_portal'
  get 'virtual-review-committee', to: 'pages#virtual_review_committee'
  get 'show-virtual-review-committee', to: 'pages#show_virtual_review_committee'
  get 'provider-source', to: 'provider_app#provider_source', as: :custom_provider_source
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
  post 'get-group-dcos', to: 'ajax#get_group_dcos'
  post 'get-provider-payers', to: 'ajax#get_provider_payers'
  post 'get-enrollment-status-count', to: 'ajax#get_enrollment_status_count'
  post 'change-enrollment-status', to: 'ajax#change_enrollment_status'
  get 'get-provider-types', to: 'ajax#get_provider_types'
  post 'get-selected-provider-types', to: 'ajax#get_selected_provider_types'
  get 'doughnut-data', to: 'ajax#get_dougnut_data'
  post 'get-dashboard-providers', to: 'ajax#get_dashboard_providers'
  post 'update-collapse', to: 'ajax#update_collapse'

  resources :provider_sources do
    collection do
      post :autosave
      get :fetch
      post :get_progress
    end
  end

  # added these two resources just to make it different to pages_controller for now it doesn't have any model
  resources :verification_platform
  resources :office_manager
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
    collection do
      get "overview"
    end
  end
  resources :enrollments do
    collection do
      get :new_user, path: 'new-user'
      post :new_user, path: 'new-user'
      get :groups
      get :new_group, path: 'new-group'
      post :new_group, path: 'new-group'
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
  resources :enroll_groups, path: 'enrollment-groups'

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
      resources :users
      resources :roles
      resources :role_based_accesses, only: [:index], path: 'role-based-access' do
        member do
          post :update_access
        end
      end
    end
  end
  resources :pals_verifications, only: [:index], path: 'pals-verification'

  resources :view_summary

  devise_scope :user do
    # Redirests signing out users back to sign-in
    get "users", to: "devise/sessions#new"
  end

  devise_for :users

  get 'organization-profile', to: 'users#organization_profile'
  get 'new-user', to: 'users#new'
  get 'organization-users', to: 'users#organization_users'
  get 'client-portal-search', to: 'pages#client_search'
  get 'download-clients', to: 'pages#download_clients'

  namespace :webscrapers do
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
  resources :auto_verifies, only: [:index], path: 'auto-verify'

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
