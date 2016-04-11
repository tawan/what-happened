class SessionsController < ApplicationController
  def new
  end

  def create
    name = params.fetch(:user, {}).permit(:name)[:name]
    u = User.find_or_create_by(name: name)
    session[:user_id] = u.id
    cookies.signed[:user_id] = u.id

    redirect_to back || '/'
  end

  def destroy
    cookies.signed[:user_id] = nil
    session[:user_id] = nil
    redirect_to '/'
  end
end
