class UsersController < ApplicationController
  before_filter :authenticate_user!


  def resource
    @user ||= User.find_by_name_or_id(params[:id])
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
    authorize! :index, @user, :message => 'Not authorized as an administrator'
    @users = User.all
  end

  def show
    unless current_user.admin? or (resource and myself?)
      render
      #render :file => "#{Rails.root}/public/404.html", :status => 404 and return
    end
    @albums = resource.albums
  end

  def display
    @user = User.find_by_name_or_id(params[:name].gsub('_', ' '))
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

  def analytics
		@albums = Album.where(user_id: current_user.id).
                    order(:impressions_count).limit(10)
    photos = Photo.includes(:albums).where('albums.user_id = ?', current_user.id)
    @popular_pics = photos.sort_by(&:followers_count)[0..4]
  end

  def update_view
		@album = Album.find(params[:album_id])
		@count = @album.photos.map do |photo|
			photo.followers_by_type_count('Guest')
		end.reduce(:+)
		@popular_pics = Photo.where(album_id: @album.id).
                          sort_by(&:followers_count)[0..4]
	end
end