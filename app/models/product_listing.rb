class ProductListing < ActiveRecord::Base
  belongs_to :seller
  belongs_to :category, :touch => true
  belongs_to :listable, :polymorphic => true, :touch => true
  belongs_to :winelist, :touch => true
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings

  delegate :anchor, :disabled?, :exclude_from_price_discounts, :exclude_from_shipping_discounts, :full_name, :photo_url, :release_date, :price, :to => :listable
end
