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

  has_attached_file :photo,
    :styles => {
      :original => ['1200x1200>', :jpg],
      :thumb   => ['100x100>',    :jpg],
      :large => ['400x400>', :jpg],
    },
    :convert_options => { :all => '-background white -flatten +matte',
                          :thumb => '-strip -quality 50',
                          :large => '-strip -quality 80',
                          :original => '-quality 75'},
    :default_url => "/images/missing.png"
  validates_attachment_content_type :photo, :content_type => ["image/jpg",
                                                              "image/jpeg",
                                                              "image/png",
                                                              "image/gif"]
  validates_attachment_file_name :photo, :matches => [/png\Z/,
                                                      /jpe?g\Z/,
                                                      /gif\Z/]

  def to_jq_upload
    {
      "name" => read_attribute(:photo_file_name),
      "size" => read_attribute(:photo_file_size),
      "url" => photo.url(:original),
      "delete_url" => photo_path(self),
      "delete_type" => "DELETE"
    }
  end

  # Just remove the extention for displaying in UI
  def file_name
    photo_file_name.split('.')[0..-2].join('.') rescue nil
  end
end
