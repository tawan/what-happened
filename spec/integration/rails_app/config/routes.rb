Rails.application.routes.draw do
  get '/', controller: :home, action: :index

  get 'login/new'

  post 'login/login'

  resources :groups do
    resources :group_memberships
  end
  resources :users
end
