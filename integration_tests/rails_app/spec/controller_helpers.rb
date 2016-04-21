module ControllerHelpers
  def login(user_id)
    request.session[:user_id] = user_id
  end
end
