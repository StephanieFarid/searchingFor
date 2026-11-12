Rails.application.routes.draw do
  resources :items, only: %i[index show create] do
    resources :comments, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "items#index"
end
