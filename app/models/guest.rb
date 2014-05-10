class Guest < ActiveRecord::Base

  ## GIVE VOTING ABILITY
  #include Mongo::Voter

  acts_as_follower

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :album_id, :album_url, :last_sign_in_ip

  belongs_to :album
  has_many :answers

end
