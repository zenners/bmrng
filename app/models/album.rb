class Album < ActiveRecord::Base
  is_impressionable counter_cache: true, unique: :ip_address

## ========================== ATTRIBUTES ACCESSIBLE ==============================

  attr_accessible :user_id, :title, :session_image, :name, :watermark, 
                  :password_toggle, :password

## ================================ RELATIONS ====================================
  has_many :photos
  has_many :guests

  belongs_to :user

end
