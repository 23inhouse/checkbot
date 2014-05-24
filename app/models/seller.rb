class Seller < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  has_many :carts
  has_many :discounts, :dependent => :destroy
  has_many :items, :through => :carts
  has_many :merchandise, :dependent => :destroy
  has_many :mixed_packs, :dependent => :destroy
  has_many :packs
  has_many :product_listings
  has_many :tags, :dependent => :destroy
  has_many :wines, :dependent => :destroy

  alias_method :specific_mixed_packs, :mixed_packs

  def handling_as_percentage=(value)
    true
  end

  def handling_charges
    read_attribute(:handling_charges) || 0.0.to_d
  end
end
