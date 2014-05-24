class MixedProduct < PackedProduct
  belongs_to :mixed_pack, :foreign_key => 'pack_id'

  delegate :bottle_name_label, :description, :to => :packable
  delegate :product_listings, :to => :pack
end
