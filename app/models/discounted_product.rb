class DiscountedProduct < PackedProduct
  belongs_to :discount, :foreign_key => 'pack_id'
  delegate :product_listings, :to => :packable
  delegate :taggings, :to => :packable
end
