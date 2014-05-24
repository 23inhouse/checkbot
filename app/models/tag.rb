class Tag < ActiveRecord::Base
  belongs_to :seller
  has_many :discounts, :through => :packed_products, :source => :pack
  has_many :discounted_products, :as => :packable
  has_many :packed_products, :as => :packable
  has_many :taggings, :dependent => :destroy
  has_many :product_listings, :through => :taggings

  def anchor
    full_name.gsub(' ', '-').gsub(/[^[A-Za-z0-9]-]+/, '').downcase
  end

  def full_name
    name
  end
end
