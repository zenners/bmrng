class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :determine_layout

  before_filter :setup_mailer_host

  rescue_from RuntimeError,     with: :rescue_visible_error_in_public

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to home_path, :alert => exception.message
  end

  def rescue_action_in_public(exception)
    logger.info "Got Exception: #{exception.inspect}"
    case exception
      when ::ActionController::UnknownController,
           ::ActionController::ActionNotFound,
           ::ActionController::RoutingError,
           ::ActionController::NoMethodError
        render_404
      else
        deliverer = self.class.exception_data
        data = case deliverer
          when nil then {}
          when Symbol then send(deliverer)
          when Proc then deliverer.call(self)
               end
        unless request.headers['USER_AGENT'].include?("bot")
          ExceptionNotifier.exception_notification(
            exception, self, request, data).deliver
        end
        render_500
    end
  end

  def setup_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def determine_layout
    domain, tld = request.domain.split(".") rescue [nil, nil]
    domain ||= 'localhost'
    if [ENV['PRIMARY_DOMAIN'].split('.').first, 'localhost'].include? domain
      'application'
    elsif domain == ENV['DISPLAY_DOMAIN'].split('.').first
      'display'
    else
      raise "Seems like the wrong url... Sorry."
    end
  end

  def after_sign_in_path_for(resource)
    if resource.active?
      if resource.admin?
        users_path
      else
        user_path(resource)
      end
    elsif resource.expired?
      #TODO: expired_path
    elsif resource.created?
      welcome_user_path(resource)
    else
      #TODO: ERROR?
    end
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