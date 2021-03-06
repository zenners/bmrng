class PhotosController < ApplicationController
  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos }
    end
  end

  def display
    @photo = Photo.find_by_id(params[:id])
    @album = @photo.album
  end

  def fave
    @photo = Photo.find(params[:id])
    album = Album.find_by(id: @photo.album.id)
    current_guest.follow(@photo)

    respond_to do |format|
      format.html { redirect_to display_album_path(id: album.id) }
      format.js { render 'defave' }
    end
  end

  def defave
    @photo = Photo.find(params[:id])
    current_guest.stop_following(@photo)
    
    respond_to do |format|
      format.html { redirect_to display_album_path(id: @photo.album.id) }
      format.js { render 'fave'}
    end
  end

  def show
    @photo = Photo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
  	@photo = Photo.new(params[:photo])
    #@photo.photo = params[:file]
  	if @photo.save
      respond_to do |format|
        format.json {render json: { message: "success", fileID: @photo.id }, :status => 200}
        format.html {redirect_to @photo.album}
      end

  	else
  	  #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
  	  render json: { error: @photo.errors.full_messages.join(',')}, :status => 400
  	end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, notice: 'Photo was successfully updated' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json

  def destroy
    @photo = Photo.find(params[:id])
    if @photo.destroy
      render json: { message: "File deleted from server" }
    else
      render json: { message: @photo.errors.full_messages.join(',') }
    end
  end
  #def destroy
  #  @photo = Photo.find(params[:id])
  #  @photo.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to photos_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
  def upload_params
  	params.require(:photo).permit(:photo, :file)
  end
end
