Rails.application.routes.draw do
  resource :authenticate, only: %i[create show destroy] do
    post 'request-code'
  end

  resources :feeds, only: %i[index] do
    get :preview
  end

  resources :subscriptions, only: %i[create]

  namespace :webhooks do
    post :twilio
  end
end
