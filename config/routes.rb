Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'pages#dashboard'
  get 'client-portal', to: 'pages#client_portal'
  get 'virtual-review-committee', to: 'pages#virtual_review_committee'
  get 'show-virtual-review-committee', to: 'pages#show_virtual_review_committee'
  get 'provider-source', to: 'pages#provider_source', as: :custom_provider_source
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

  resources :providers
  resources :enrollments do
    collection do
      get :new_user, path: 'new-user'
      post :new_user, path: 'new-user'
      get :groups
      get :new_group, path: 'new-group'
      post :new_group, path: 'new-group'
      resources :groups do
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

  resources :systems
  resources :settings

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
end
