class HomeController < ApplicationController

	before_filter :authenticate_user!, :except => [:index]

	def index
	  if current_user
	    @album = Album.new
      redirect_to add_path
    end
	end

	def manage
		@albums = Album.where(user_id: current_user.id)
	end

	def update_view
		@album = Album.find(params[:album_id])
		@count = 0
		@album.photos.each do |photo|
      # TODO: scope followers to just guests (but can anyone besides guest follow anyways?)
			count = photo.followers_by_type_count('Guest')
			@count = @count + count
		end
		pop_pics = Photo.where(album_id: @album.id)
    #TODO: Need to write scope to find most popular photos
		#@popular_pics = pop_pics.order(:followers_count, :desc).limit(5)
    @popular_pics = []
	end

	def analytics
		albums = Album.where(user_id: current_user.id).order(:impressionist_count)
		@albums= albums.limit(10)
    #TODO: Need to write scope to find most popular photos
		#@popular_pics = Photo.order(:followers_count, :desc).limit(5)
    @popular_pics = []
	end

end
