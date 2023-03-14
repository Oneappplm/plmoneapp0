Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'pages#dashboard'
  get 'client-portal', to: 'pages#client_portal'
  get 'virtual-review-committee', to: 'pages#virtual_review_committee'
  get 'show-virtual-review-committee', to: 'pages#show_virtual_review_committee'
  get 'provider-source', to: 'pages#provider_source'
  get 'app-tracker', to: 'pages#app_tracker'
  get 'encompass', to: 'pages#encompass'
  get 'microsite', to: 'pages#microsite'
  get 'ps-office-manager', to: 'pages#ps_office_manager'
  get 'plm-sales-tool', to: 'pages#plm_sales_tool'
  get 'help', to: 'pages#help'
  get 'settings', to: 'pages#settings'
  get 'show-client-details', to: 'pages#show_client_details'
  get 'smart-contract', to: 'pages#smart_contract'

  devise_scope :user do
    # Redirests signing out users back to sign-in
    get "users", to: "devise/sessions#new"
  end

  devise_for :users
end
