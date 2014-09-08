class AlbumsController < ApplicationController


  # authenticate users
  before_filter :authenticate_user!, :except => [:display]

  # gather page impressions
  #impressionist actions: [:display]

  def resource
    param = params['album_id'] || params['id']
    @user ||= Album.find_by_name_or_id(param)
  end
  
  def index
    @albums = Album.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  def show
    @album = Album.find(params[:id])
    @photos = @album.photos
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album }
    end
  end

  def display
    if @user = User.find_by_name_or_id(params[:user_id])
      if @album = @user.albums.active.where(name: params[:album_id].gsub(' ', '')).first
        impressionist(@album)
      end
    end
    raise ActiveRecord::RecordNotFound unless @album
    session[:guest_id] = Guest.create unless current_guest
  end

  def new
    @album = Album.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
    end
  end

  def create
    #fix the name up to not have spaces
    name = params[:album].delete(:name)
    name = name.gsub(' ', '')
    @album = Album.new(params[:album].merge(name: name))
    @album.status = 'created'

    respond_to do |format|
      if @album.save
        format.html { redirect_to set_title_album_path(@album) }
        format.json { render json: album_path(@album), status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_title
    if request.patch? or request.post?
      resource.title = params[:album][:title]
      if resource.valid?
        resource.save
        if resource.status == 'created'
          redirect_to set_password_album_path
        else
          redirect_to resource.user
        end
      end
    else
      @album = resource
    end
  end

  def set_password
    if request.patch?
      if params[:album][:password_toggle] == '1'
        resource.password_toggle = 1
        resource.password = params[:album][:password]
        if resource.save
          if resource.status == 'created'
            redirect_to settings_album_path and return
          else
            redirect_to resource.user and return
          end
        end
      else
        redirect_to settings_album_path
      end
    else
      @album = resource
    end
  end

  def settings
    if request.patch? or request.post?
      resource.social = params[:album][:social]
      #@resource.watermark = params[:album][:watermark] #TODO: future feature
      resource.password = params[:album][:social]
      resource.status = 'active'
      if resource.valid?
        resource.save
        respond_to do |format|
          format.html { redirect_to resource }
        end
      end
    end
    @album = resource
  end

  def edit
    @album = Album.find(params[:id])
  end

  def update
    @album = Album.find(params[:id])

    respond_to do |format|
      if @album.update_attributes(params[:album])
        #TODO: This should probably be :back, but the page won't load correctly due to JS update_view on link click from left side
        format.html { redirect_to @album, notice: 'Album was successfully updated' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @album = Album.find(params[:id])
    @album.status = 'deleted' #Fake delete
    @album.save

    respond_to do |format|
      format.html { redirect_to @album.user }
      format.json { head :no_content }
    end
  end
end
