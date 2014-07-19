class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :determine_layout

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to home_path, :alert => exception.message
  end

  def determine_layout
    domain, tld = request.domain.split(".") rescue [nil, nil]
    domain ||= 'localhost'
    if [ENV['PRIMARY_DOMAIN'], 'localhost'].include? domain
      if current_user
        'application'
      else
        'marketing'
      end
    elsif domain == ENV['DISPLAY_DOMAIN']
      'display'
    end
  end

  def after_sign_in_path_for(resource)
     users_path
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  helper_method :current_guest

  private

  def current_guest
    @current_guest ||= Guest.find(session[:guest_id]) rescue nil if session[:guest_id]

  end
  
end