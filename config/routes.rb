Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#dashboard"
  get "client-portal", to: 'pages#client_portal', as: :client_portal
end
