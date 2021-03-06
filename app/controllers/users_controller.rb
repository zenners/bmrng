class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :display]

  layout :determine_layout

  def determine_layout
    return 'application' if current_user
    return 'display' if resource
    'marketing'
  end

  def resource
    param = params['user_id'] || params['id']
    @user ||= User.find_by_name_or_id(param)
  end

  def myself_role?
    resource == current_user
  end
  alias myself? myself_role?
  helper_method :myself?

    # special admin-only method to "turn ourselves into" the user specified
  def become
    return respond_with_status(401) unless current_user.admin? # double check
    login_as(resource)
    redirect_to user_url
  end

  def index
    authorize! :index, @user #, :message => 'Not authorized as an administrator'
    @users = User.all
  end

  def show
    if !resource or (!myself? and !current_user.try(:admin?))
      render :file => "#{Rails.root}/public/404.html", :status => 404 and return
    end
    @albums = resource.albums
  end

  def display
    @user = resource
    unless @user
      render :file => "#{Rails.root}/public/404.html", :status => 404 and return
    end
  end

  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator'
    @user = User.find(params[:id])
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    params[:user] = params[:user].except(:role_ids)
    if @user.update_attributes(params[:user])
      @user.update_plan(role) unless role.nil?
      redirect_to users_path, :notice => "User updated"
    else
      redirect_to users_path, :alert => "Unable to update user"
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted"
    else
      redirect_to users_path, :notice => "Can't delete yourself"
    end
  end

  def change
     redirect_to current_user and return if params[:what].blank?
    if request.post? or request.patch?
      if params[:user] and params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      if resource.update_attributes(params[:user])
        flash[:notice] = 'Saved Successfully'
        redirect_to users_path and return
      end
      render 'users/change', what: params[:what] and return
    end
    if params[:what] == 'subscription'
      if current_user.stripe_customer_token
        customer = Stripe::Customer.retrieve current_user.stripe_customer_token
        if current_user.subscription
          begin
            sub = customer.subscriptions.retrieve current_user.subscription.try(:stripe_subscription_token)
            if sub.ended_at
              redirect_to new_user_subscription_path(current_user) and return
            else
              redirect_to edit_user_subscription_path(current_user, current_user.subscription) and return
            end
          rescue Stripe::InvalidRequestError => e
            logger.error "Stripe error: #{e}"
          end
        else
          redirect_to new_user_subscription_path(current_user) and return
        end
      else
        redirect_to new_user_subscription_path(current_user) and return
      end
    end
  end

  def welcome
    unless resource.created?
      redirect_to user_path
    end
  end

  def set_human_name
    resource.human_name = params[:user][:human_name]
    if resource.save
      redirect_to set_studio_user_path(resource)
    else
      render :welcome
    end
  end

  def set_studio
    if request.post?
      resource.studio_name = params[:user][:studio_name]
      if resource.save
        redirect_to set_studio_url_user_path(resource)
      else
        render :set_studio
      end
    end
  end

  def set_studio_url
    if request.post?
      resource.link = params[:user][:link]
      if resource.save
        redirect_to set_url_user_path(resource)
      else
        render :set_studio_url
      end
    end
  end

  def set_url
    if request.post?
      resource.name = params[:user][:name].gsub(' ', '')
      if resource.save
        redirect_to set_logo_user_path(resource)
      else
        flash[:error] = "url already in use. Please try again."
        render :set_url
      end
    end
  end

  def set_logo
    @user = resource
    if request.post?
      resource.logo = params[:file]
      if resource.save
        respond_to do |format|
          format.html { redirect_to set_questions_user_path(resource) }
          format.json {render json: { message: "success"}, :status => 200}
        end
      else
        respond_to do |format|
          format.html { render :set_logo }
          format.json { render json: { message: "failed"}, :status => 500}
        end
      end
    end
  end

  def set_questions
    if request.post?
      params[:user] ||= {}
      if resource.update(params[:user].merge(status: 'active'))
        redirect_to welcome_complete_user_path(resource)
      else
        @questions = [] #Question.create(content: "May we please get your name?")
        render :set_questions
      end
    end
  end

  def analytics
		@most_viewed_albums = Album.where(user_id: current_user.id).where('impressions_count is not null').
                    order(:impressions_count).limit(10)
    # BUGBUG CHRISDO TODO: This doesn't work...
    photos = Photo.includes(:album).where('albums.user_id = ?', current_user.id)
    @popular_pic_albums = photos.where(&:followers_count > 0).sort_by(&:followers_count).map{|p| p.album}.uniq![0..4] rescue []
  end

  def update_view
		@album = Album.find(params[:album_id])
		@count = @album.photos.map do |photo|
			photo.followers_by_type_count('Guest')
    end.reduce(:+)
    @count ||= 0
		@popular_pics = Photo.where(album_id: @album.id).
                          sort_by(&:followers_count)[0..4]
  end

  def send_feedback
    if request.post?
      UserMailer.send_feedback(current_user, params[:feedback][:message]).deliver
      redirect_to current_user, notice: 'Thank you for the feedback!'
    else
      render :send_feedback
    end
  end

  def request_support
    if request.post?
      UserMailer.request_support(current_user, params[:support][:message]).deliver
      redirect_to current_user, notice: 'We will get back to you soon!' and return
    else
      render :request_help
    end
  end
end