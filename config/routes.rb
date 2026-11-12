Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  resources :items do
    resources :comments, only: %i[create destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "items#index"
end
