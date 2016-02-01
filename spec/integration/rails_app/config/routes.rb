Rails.application.routes.draw do
  resources :notifications
  get '/', controller: :home, action: :index

  resources :groups do
    resources :memberships
  end
  resources :users do
    resources :notifications
  end
  resources :sessions
end
