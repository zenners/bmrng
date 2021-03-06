class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :determine_layout

  before_filter :setup_mailer_host

  before_filter :ensure_not_expired

  before_filter :ensure_subdomain

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

  def ensure_not_expired
    if (request.params["what"] == "subscription") or request.path.include?('sign_out')
      nil
    elsif current_user and current_user.expired? and !current_user.admin? and (!request.path.include?('subscriptions'))
      redirect_to change_user_path(current_user, what: 'subscription')
    elsif request.subdomain == ENV['DISPLAY_SUBDOMAIN']
      if user_id = request.params['user_id']
        if user = User.find_by_name_or_id(user_id)
          if user.expired? and !user.admin?
            redirect_to '/contact_studio.html'
          end
        else
          redirect_to '/'
        end
      end
    end
  end

  def determine_layout
    subdomain = request.subdomain rescue 'www'
    #domain, tld = request.domain.split(".") rescue [nil, nil]
    #domain ||= 'localhost'
    if ENV['PRIMARY_SUBDOMAIN'] == subdomain
      'application'
    elsif ENV['DISPLAY_SUBDOMAIN'] == subdomain
      'display'
    else
      'application'
    end
  end

  def ensure_subdomain
    if request.path.include? new_user_session_path and request.subdomain != ENV['PRIMARY_SUBDOMAIN']
      redirect_to('http://' + ENV['PRIMARY_SUBDOMAIN'] + '.' + request.domain + request.path)
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
      edit_subscription_user_path(resource)
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