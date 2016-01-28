Rails.application.routes.draw do
  get '/', controller: :home, action: :index

  resources :groups do
    resources :group_memberships
  end
  resources :users
  resources :sessions
end
