Rails.application.routes.draw do
  resources :group_memberships
  resources :groups
  get '/', controller: :home, action: :index

  get 'login/new'

  post 'login/login'

  resources :groups do
    resources :group_memberships
  end
end
