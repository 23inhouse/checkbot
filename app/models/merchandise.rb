class Merchandise < ActiveRecord::Base
  belongs_to :seller
  has_many :items
  has_many :discounts, :through => :discounted_products, :conditions => {:type => 'Discount'}
  has_many :discounted_products, :as => :packable
  has_many :mixed_products, :as => :packable
  has_many :packed_products, :as => :packable
  has_many :product_listings, :as => :listable
  has_many :tags, :through => :product_listings

  attr_accessor :exclude_from_price_discounts, :exclude_from_shipping_discounts

  delegate :winery_website_wine_page, :winery_website, :to => :seller
end
