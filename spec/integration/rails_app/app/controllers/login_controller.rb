class LoginController < ApplicationController
  def new
  end

  def login
    name = params.fetch(:user, {}).permit(:name)[:name]
    u = User.find_or_create_by(name: name)
    session[:user_id] = u.id

    redirect_to '/'
  end
end
