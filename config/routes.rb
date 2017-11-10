Rails.application.routes.draw do
  resources :feeds, only: [:index]
end
