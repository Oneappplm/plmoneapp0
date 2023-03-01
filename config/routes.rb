Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'pages#dashboard'
  get 'client-portal', to: 'pages#client_portal'
  get 'virtual-review-committee', to: 'pages#virtual_review_committee'
  get 'provider-source', to: 'pages#provider_source'
  get 'app-tracker', to: 'pages#app_tracker'
  get 'encompass', to: 'pages#encompass'
  get 'microsite', to: 'pages#microsite'
  get 'ps-office-manager', to: 'pages#ps_office_manager'
  get 'help', to: 'pages#help'
  get 'settings', to: 'pages#settings'
end
