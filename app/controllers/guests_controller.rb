class GuestsController < ApplicationController
  
  def new
    @guest = Guest.new

    respond_to do |format|
      format.html
      format.json { render json: @guest }
    end
  end

  def create
    @guest = Guest.new(params[:guest])
    session[:guest_name] = @guest.name
    session[:guest_id] = @guest.id

    respond_to do |format|
      if @guest.save
        debugger
        format.html { redirect_to @guest.album_url }
        format.json { render json: display_path(@guest.album_id), status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def start
    @guest = Guest.find(params[:guest])
    session[:guest_name] = @guest.name
    session[:guest_id] = @guest.id
    
    url = params[:url]
    redirect_to url
  end

  def destroy
    url = params[:url]
    reset_session
    redirect_to url
  end

end
