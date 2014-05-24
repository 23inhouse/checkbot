class DiscountTally < ActiveRecord::Base
  belongs_to :cart
  belongs_to :price_pack, :class_name => 'Pack'
  belongs_to :shipping_pack, :class_name => 'Pack'

  def <=>(other)
    return -1 if (price_discount || 0) > (other.price_discount || 0)
    return +1 if (price_discount || 0) < (other.price_discount || 0)
    return -1 if (shipping_discount || 0) > (other.shipping_discount || 0)
    return +1 if (shipping_discount || 0) < (other.shipping_discount || 0)
    0
  end
end
