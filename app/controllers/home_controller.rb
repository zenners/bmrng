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
			count = photo.followers_count_by_type("guest")
			@count = @count + count
		end
		pop_pics = Photo.where(album_id: @album.id)
		@popular_pics = pop_pics.desc(:followers_count).limit(5)
	end

	def analytics
		albums = Album.where(user_id: current_user.id).desc(:impressionist_count.all)
		@albums= albums.limit(10)
		@popular_pics = Photo.with_max_followers
	end

end
