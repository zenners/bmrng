class GuestsController < ApplicationController
  
  def new
    @guest = Guest.new

    respond_to do |format|
      format.html
      format.json { render json: @guest }
    end
  end

  def update
    current_guest.attributes = params[:guest]

    get_questions(params[:guest][:album_id])

    if current_guest.save
      session[:guest_name] = current_guest.name
      #session[:guest_id] = current_guest.id
      @album = Album.find(params[:guest][:album_id])
      if @question
        render 'guests/ask_questions' and return
      else
        reset_session
        redirect_to "/#{@album.user.name}/#{@album.name}"
      end
    else
      render action: 'new'
    end
  end

  def get_questions(album_id)
    a = Album.find album_id
    @album_id = a.id
    u = a.user
    @questions = u.questions
    @question = @questions.first
    @questions = @questions[1..-1].map{|q| q.id} rescue []
  end

  def show
    @guest = Guest.find(params[:id])
    @album = Album.find(params[:album_id])
		@popular_pics = @album.top_photos
  end

  def start_session
    @guest = Guest.find(params[:guest_id])
    @album = Album.find(params[:album_id])
    #add the follows that may have been created in this session
    @guest.follows << current_guest.all_follows
    session[:guest_name] = @guest.name
    session[:guest_id] = @guest.id
    get_questions(params[:album_id])
    if @question
      render 'guests/ask_questions' and return
    else
      reset_session
      redirect_to "/#{@album.user.name}/#{@album.name}"
    end
  end

  def destroy_session
    reset_session
    redirect_to album_url(@album)
  end

  def save
    @album = Album.find(params[:album_id])
    @guest = current_guest || Guest.new
    @guests = Guest.where(album_id: @album.id).
                      where(last_sign_in_ip: request.remote_ip)
      render 'guests/welcome' and return
    #if current_guest
    #  get_questions(params[:album_id])
    #  if @question
    #    render 'guests/ask_questions' and return
    #  else
    #    reset_session
    #    redirect_to "#{@album.user.name}/#{@album.title}"
    #  end
    #else
    #
    #end
  end

  # This is a little hacky... questions controller handling the creation of
  # answers, but it is probably cleaner then having the answers controller do it
  def ask_questions
    if request.post?
      @album = Album.find( params[:answers][:album_id])
      @user = @album.user
      @question = Question.find params[:answers][:question_id]
      Answer.create(question: @question,
                    content: params[:answers][:content],
                    guest: current_guest)
      logger.info "GUEST: #{current_guest}"
      @questions = params[:answers][:questions].gsub('[','').
                                                gsub(']','').
                                                split(',').
                                                map{|id| id.to_i}
      if @questions.any?
        @album_id = @album.id
        @question = Question.find(@questions.first)
        @questions = @questions[1..-1]
        respond_to do |format|
          format.js
          format.html
        end
      else
        #reset_session
        render 'guests/thank_you'
      end
    end
  end

  def reset_session
    session[:guest_name] = nil
    session[:guest_id] = nil
  end

  def thank_you
    @album = Album.find(params[:album_id])
  end

end
