class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env['omniauth.auth'])
    session[:user_id] = user.id
    cookies.signed['user.id'] = user.id
    if session[:current_conference_id].present?
      redirect_to conference_path(session[:current_conference_id])
    else
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.signed['user.id'] = nil
    redirect_to root_path
  end
end
