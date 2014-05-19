class AlbumsController < ApplicationController


  # authenticate users
  before_filter :authenticate_user!, :except => [:display]

  # gather page impressions
  impressionist actions: [:display]
  
  def index
    @albums = Album.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  def show
    @album = Album.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album }
    end
  end

  def display
    if @user = User.find_by_name_or_id(params[:name])
      if @album = @user.albums.where(name: params[:id].gsub(' ', '_')).first
        @guests = Guest.where(album_id: @album.id).
                        where(last_sign_in_ip: request.remote_ip)
      end
    end
    raise ActiveRecord::RecordNotFound unless @album
    render partial: 'guests/load' if current_guest.blank?
  end

  def new
    @album = Album.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
    end
  end

  def edit
    @album = Album.find(params[:id])
  end

  def create
    @album = Album.new(params[:album])

    respond_to do |format|
      if @album.save
        format.html { redirect_to album_path(@album), notice: 'Album was successfully created' }
        format.json { render json: album_path(@album), status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
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
    @album.destroy #REVIEW: This probably better to mark as deleted

    respond_to do |format|
      format.html { redirect_to home_manage_path }
      format.json { head :no_content }
    end
  end
end
