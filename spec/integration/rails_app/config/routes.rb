Rails.application.routes.draw do
  resources :notifications
  get '/', controller: :home, action: :index

  resources :groups do
    resources :memberships
    
    resources :meetings do
      resources :participations
    end
  end
  resources :users do
    resources :notifications
  end
  resources :sessions

  mount ActionCable.server => '/cable'
end
