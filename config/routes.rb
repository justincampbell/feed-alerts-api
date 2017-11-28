Rails.application.routes.draw do
  resources :feeds, only: [:index] do
    get :preview
  end
end
