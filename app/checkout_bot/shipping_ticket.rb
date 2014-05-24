class ShippingTicket < DiscountTicket
  extend Memoist

  def exploded_item_price
    exploded_item.shipping_per_item
  end

  def mixed_item_price
    return exploded_item_price if in_mixed_pack.present?
    exploded_item_price
  end

private

  def amount_off
    # divisor = amount_with_same_discount_pack * number_of_bottles # only applicable for price not shipping
    # if attr_amount_off && !or_more && divisor != 0
    #   return attr_amount_off * exploded_item_price * applicable_number_of_bottles_with_same_discount_pack / divisor
    # end
    super
  end

  def amount_with_same_discount_pack(discount_pack = nil)
    discount_pack ||= pack
    exploded_items.inject(0.0.to_d) { |sum, i|
      sum + (i.shipping_discount_pack == discount_pack ? i.price_per_item : 0)
    }
  end

  def amount_with_same_pack(discount_pack = nil)
    discount_pack ||= pack
    amount_with_same_discount_pack(discount_pack) + exploded_items.inject(0.0.to_d) { |sum, i|
      sum + (i.shipping_tickets.any? { |t| t.pack == discount_pack } ? i.price_per_item : 0)
    }
  end

  def amount_with_removed_tickets(discount_pack = nil)
    discount_pack ||= pack
    exploded_items.inject(0.0.to_d) { |sum, i|
      sum + (i.shipping_tickets.any? { |t| t.pack == discount_pack } ? i.price_per_item : 0)
    } + exploded_items.inject(0.0.to_d) { |sum, i|
      sum + (i.removed_shipping_tickets.any? { |t| t.pack == discount_pack } ? i.price_per_item : 0)
    }
  end

  def applicable_number_of_bottles_with_same_discount_pack
    exploded_item_collection = exploded_items_with_same_pack(pack)
    return (exploded_item_collection.size / pack.quantity).floor * pack.quantity if pack.shipping_price.blank?
    exploded_item_collection.each_slice(pack.quantity).to_a.sum do |slice|
      (slice.size != pack.quantity || slice.sum { |ei| ei.shipping_per_item } < pack.shipping_price) ? 0 : pack.quantity
    end
  end

  def attr_amount_off
    pack.read_attribute(:shipping_amount_off).presence
  end

  def attr_price
    pack.read_attribute(:shipping_price).presence
  end

  def attr_percentage_off
    pack.read_attribute(:shipping_percentage_off).presence
  end

  def discount_tally_amount_off(full_product_price)
    divisor = divisor(amount_with_same_pack)
    full_product_price - (discountable_amount / divisor * pack.shipping_amount_off)
  end

  def discount_tally_amount_off_compensated
    exploded_item_price - (discountable_amount_compensated / divisor * pack.shipping_amount_off)
  end

  def discount_tally_price
    divisor = divisor(amount_with_same_pack)
    (discountable_amount / divisor * pack.shipping_price) + (non_discountable_amount / exploded_item.price * exploded_item_price)
  end

  def discount_tally_price_compensated
    ((amount_with_removed_tickets / number_of_bottles_compensated - non_discountable_amount_compensated) / divisor * pack.shipping_price) + (non_discountable_amount_compensated / exploded_item.price * exploded_item_price)
  end

  def discount_tally_percentage_off(full_product_price)
    discountable_shipping_amount = full_product_price * discountable_amount / exploded_item.price
    full_product_price - (discountable_shipping_amount * pack.shipping_percentage_off * 0.01.to_d)
  end

  def discount_tally_percentage_off_compensated
    discountable_shipping_amount = exploded_item_price * discountable_amount_compensated / exploded_item.price
    exploded_item_price - (discountable_shipping_amount * pack.shipping_percentage_off * 0.01.to_d)
  end

  def exploded_items_with_same_discount_pack(discount_pack)
    exploded_items.select { |i| i.shipping_discount_pack == discount_pack }
  end

  def exploded_items_with_same_pack(discount_pack)
    exploded_items.select { |i| i.shipping_tickets.any? { |t| t.pack == discount_pack } || i.shipping_discount_pack == discount_pack }
  end

  def exploded_items_with_same_pack_with_removed_tickets(discount_pack)
    exploded_items.select { |i|
      i.shipping_tickets.any? { |t| t.pack == discount_pack } ||
      i.removed_shipping_tickets.any? { |t| t.pack == discount_pack } ||
      i.shipping_discount_pack == discount_pack
    }
  end

  def number_of_bottles_compensated(discount_pack = nil)
    discount_pack ||= pack
    return pack.quantity if !or_more && pack.quantity_discount?
    exploded_items.select { |i| i.shipping_tickets.any? { |t| t.pack == discount_pack } }.size + number_of_removed_bottles_with_same_pack
  end

  def number_of_bottles_with_same_discount_pack(discount_pack = nil)
    discount_pack ||= pack
    exploded_items_with_same_discount_pack(discount_pack).size
  end

  def number_of_bottles_with_same_pack(discount_pack = nil)
    discount_pack ||= pack
    exploded_items_with_same_pack(discount_pack).size
  end

  def number_of_removed_bottles_with_same_pack(discount_pack = nil)
    discount_pack ||= pack
    exploded_items.select { |i| i.removed_shipping_tickets.any? { |t| t.pack == discount_pack } }.size
  end

  def price
    # return (exploded_item_price / pack.full_price) * pack.discount_price if specific_mixed_pack? # only applicable for price not shipping
    # if !or_more # only applicable for price not shipping
    #   divisor = applicable_number_of_bottles_with_same_discount_pack / number_of_bottles
    #   return attr_price * exploded_item_price * divisor / amount_with_same_discount_pack if attr_price
    # end
    super
  end

  def price_compensated
    # return (exploded_item_price / pack.full_price) * pack.discount_price if specific_mixed_pack? # only applicable for price not shipping
    super
  end
end
