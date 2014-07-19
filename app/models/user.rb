class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :albums
  has_many :questions

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
      :thumb    => ['200x30',   :jpg]
    },
    :convert_options => { :all => '-background white -flatten +matte' },
    :default_url => "/images/missing.png"
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

## ================================ VALIDATIONS ================================
  
  #validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :encrypted_password
  validates_uniqueness_of :name, allow_nil: false, if: :name_changed?


## ATTRIBUTES ACCESIBILITY

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, 
  :created_at, :updated_at, :image, :stripe_token, :coupon, :logo, :link

  attr_accessor :stripe_token, :coupon

## Hooks
  before_save :update_stripe
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

  def update_plan(role)
    self.role_ids = []
    self.add_role(role.name)
    unless stripe_customer_id.nil?
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      customer.update_subscription(:plan => role.name)
    end
    true
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to update your subscription. #{e.message}."
    false
  end
  
  def update_stripe
    return if Rails.env.development?
    return if email.include?('@example.com') and not Rails.env.production?
    if stripe_customer_id.nil?
      if !stripe_token.present?
        raise "Stripe token not present. Can't create account."
      end
      if coupon.blank?
        customer = Stripe::Customer.create(
          :email => email,
          :description => name,
          :card => stripe_token,
          :plan => roles.first.name
        )
      else
        customer = Stripe::Customer.create(
          :email => email,
          :description => name,
          :card => stripe_token,
          :plan => roles.first.name,
          :coupon => coupon
        )
      end
    else
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = email
      customer.description = name
      customer.save
    end
    self.last_4_digits = customer.cards.data.first["last4"]
    self.stripe_customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end
  
  def cancel_subscription
    unless stripe_customer_id.nil?
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      unless customer.nil? or customer.respond_to?('deleted')
        if customer.subscription.status == 'active'
          customer.cancel_subscription
        end
      end
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end
  
  def expire
    UserMailer.expire_email(self).deliver
    destroy
  end

  # Finds the best role of the user
  def best_role
    return nil if roles.blank?
    #Could be better where it checks for platinum, then gold, etc
    roles.first.name
  end

  def admin?
    roles.first.name.downcase == 'admin'
  end
end
