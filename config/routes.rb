Rails.application.routes.draw do
  resource :authenticate, only: %i[create show destroy] do
    post 'request-code'
  end

  resources :feeds, only: %i[index]

  resources :subscriptions, only: %i[create]
  post :preview, to: "subscriptions#preview"

  namespace :webhooks do
    post :twilio
  end
end
