class GuestsController < ApplicationController
  
  def new
    @guest = Guest.new

    respond_to do |format|
      format.html
      format.json { render json: @guest }
    end
  end

  def create
    @guest = Guest.create(params[:guest])
    session[:guest_name] = @guest.name
    session[:guest_id] = @guest.id

    respond_to do |format|
      if @guest.save
        format.html { redirect_to @guest.album_url }
        format.json { render json: display_path(@guest.album_id), status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def show

    @guest = Guest.find(params[:id])

    @album = Album.find(params[:album_id])
		@popular_pics = @album.photos.sort_by(&:followers_count)[0..4]
  end

  def start_session
    @guest = Guest.find(params[:guest])
    session[:guest_name] = @guest.name
    session[:guest_id] = @guest.id
    
    url = params[:url]
    redirect_to url
  end

  def destroy_session
    url = params[:url]
    reset_session
    redirect_to url
  end

end
