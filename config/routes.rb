Rails.application.routes.draw do
  resources :feeds, only: %i[index] do
    get :preview
  end

  resources :subscriptions, only: %i[create]
end
