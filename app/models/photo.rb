class Photo < ActiveRecord::Base
  acts_as_followable
  include Rails.application.routes.url_helpers

## ========================== ATTRIBUTES ACCESSIBLE ============================

  attr_accessible :album_id, :photo, :user_id, :photo_file_name, 
                  :photo_content_type, :photo_file_size

## ================================ RELATIONS ==================================

  belongs_to :album
  belongs_to :user

##================================= SCOPES =====================================

  default_scope include: :followings

## ================================= IMAGES ====================================

  #TODO: Bad image sizes
  has_attached_file :photo,
    :styles => {
      :original => ['400x400', :jpg],
      :small    => ['30x30',   :jpg],
      :medium   => ['100x100',    :jpg],
      :large => ['400x400', :jpg],
      :thumb    => ['200x200>',   :jpg]
    },
    :convert_options => { :all => '-background white -flatten +matte' },
    :default_url => "/images/original/missing.png"

  def to_jq_upload
    {
      "name" => read_attribute(:photo_file_name),
      "size" => read_attribute(:photo_file_size),
      "url" => photo.url(:original),
      "delete_url" => photo_path(self),
      "delete_type" => "DELETE"
    }
  end
end
