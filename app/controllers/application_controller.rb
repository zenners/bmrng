class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'application'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    if resource.roles.include? Role.find_by_name('Admin')
      users_path
    else
      resource
    end
  end

  def after_sign_out_path_for(resource)
    users_path
  end

  helper_method :current_guest

  private

  def current_guest
    @current_guest ||= Guest.find(session[:guest_id]) if session[:guest_id]
  end
  
end