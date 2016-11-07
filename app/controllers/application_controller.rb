class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :current_admin, :require_admin

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_admin
    current_user && current_user.uid.in?(Rails.application.secrets.admin_uids.to_s.split)
  end

  def require_admin
    redirect_to root_path, alert: 'Not authorized' unless current_admin.present?
  end
end
