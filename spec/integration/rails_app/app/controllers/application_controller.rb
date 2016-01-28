class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    remember_location
    redirect_to new_session_path unless current_user
  end

  def remember_location
    session[:back_paths] ||= []
    unless session[:back_paths].last == request.fullpath
      session[:back_paths] << request.fullpath
    end

    # make sure that the array doesn't bloat too much
    session[:back_paths] = session[:back_paths][-10..-1]
  end

  def back
    session[:back_paths] ||= []
    session[:back_paths].pop
  end
end
