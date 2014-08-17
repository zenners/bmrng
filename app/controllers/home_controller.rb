class HomeController < ApplicationController

	before_filter :authenticate_user!, :except => [:index, :viewer]
  layout :choose_layout

  def choose_layout
    'marketing'
  end

	def index
	  if current_user
	    @album = Album.new
      redirect_to new_album_path
    end
	end

	def manage
		@albums = Album.where(user_id: current_user.id)
	end
end
