class Album < ActiveRecord::Base
  is_impressionable counter_cache: true
  accepts_nested_attributes_for :impressions

## ========================== ATTRIBUTES ACCESSIBLE ==============================

  attr_accessible :user_id, :title, :session_image, :name, :watermark, 
                  :password_toggle, :password, :social

## ================================ CALLBACKS ====================================
  before_save :ensure_url_save_name

## =============================== VALIDATIONS ===================================

  validates_length_of :name, in: 1..50, allow_nil: false,  if: :name_changed?
  validates_length_of :title, in: 1..50, allow_nil: false, if: :title_changed?

## ================================ RELATIONS ====================================
  has_many :photos
  has_many :guests

  belongs_to :user

## ================================= SCOPES ====================================
  scope :active, -> {where(status: :active) }

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

  #REVIEW: THIS IS NOT DYNAMIC AT ALL
  def url
    "http://#{ENV['DISPLAY_SUBDOMAIN']}.boomerangproof.com/#{user.url_name}/#{name}"
  end

  def top_photos
    #MAJOR HACK!!! BAD PERF!!! THIS SHOULD BE A SCOPE
    photos.map{|p| p.followers_count > 0 ? [p.id, p.followers.count] : nil}.
           compact.sort_by{|p| -p[1]}[0..4].map{|p| Photo.find p[0]}
  end

  private

  def ensure_url_save_name
    self.name = name.gsub(' ', '_')
  end



end
