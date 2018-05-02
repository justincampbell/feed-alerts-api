Rails.application.routes.draw do
  resource :authenticate, only: %i[create show destroy] do
    post 'request-code'
  end

  resources :users, only: %i[index show]

  resources :feeds, only: %i[index create]

  resources :subscriptions, only: %i[create]
  post :preview, to: "subscriptions#preview"

  namespace :webhooks do
    post :twilio
  end
end
