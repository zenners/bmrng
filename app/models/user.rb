class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :albums
  has_many :questions
  has_one  :subscription

  attr_accessor :subscription_plan, :stripe_card_token

  accepts_nested_attributes_for :questions, :allow_destroy => true

  ## FOLLOWABLE FIELDS
  ##include Mongo::Followable::Follower
  ##include Mongo::Followable::History

  ## GIVE VOTING ABILITY
  ##include Mongo::Voter

## ================================= IMAGES ======================================

  #TODO: This is bad sizing, would make a square
  has_attached_file :logo,
    :styles => {
      :original => ['400x400', :jpg],
      :thumb    => ['200x50',   :jpg]
    },
    #:convert_options => { :all => '-background white -flatten +matte' },
    :default_url => "/images/original/missing.png"
  validates_attachment_content_type :logo, :content_type => ["image/jpg",
                                                             "image/jpeg",
                                                             "image/png",
                                                             "image/gif"]
  validates_attachment_file_name :logo, :matches => [/png\Z/,
                                                     /jpe?g\Z/,
                                                     /gif\Z/]

## ================================ VALIDATIONS ================================
  
  #validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :encrypted_password
  validates_uniqueness_of :name, allow_nil: false, if: :name_changed?


## ATTRIBUTES ACCESIBILITY

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, 
  :created_at, :updated_at, :image, :stripe_customer_token, :coupon, :logo, :link, :status

  attr_accessor :stripe_token, :coupon

## Hooks
  #before_save :update_stripe
  before_destroy :cancel_subscription

## Methods

  # utility to make finding things easier when the key could be an
  # object, integer, symbol, or string.   Works even if the string holds
  # an integer, so it can take params[:id] like "25020"
  def self.find_by_name_or_id(x)
    if x.is_a?(ActiveRecord::Base)
      r = x
    elsif x.is_a?(Fixnum)
      r = find_by_id(x)
    elsif x.is_a?(String) or x.is_a?(Symbol)
      if (r = find_by_name(x.to_s))
        r
      elsif !(x.is_a?(Symbol)) and ((i = x.to_i) and (i.to_s == x.to_s.strip))
        find_by_id(i)
      else
        nil
      end
    end
  end

  def url_name
    name.gsub(' ', '_')
  end

  # Finds the best role of the user
  def best_role
    return nil if roles.blank?
    #Could be better where it checks for platinum, then gold, etc
    roles.first.name
  end

  def admin?
    roles.try(:first).try(:name).try(:downcase) == 'admin'
  end

  def active?
    status == 'active'
  end

  def expired?
    subscription.stripe_current_period_end < Time.now rescue false
  end

  def created?
    status == 'created'
  end
end
