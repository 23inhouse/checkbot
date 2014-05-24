class DiscountTicket
  extend Memoist

  attr_accessor :checkbot, :exploded_item, :pack

  delegate :exploded_items, :shipping_charges, :to => :checkbot
  delegate :or_more, :specific_mixed_pack?, :to => :pack
  delegate :quantity_discount?, :amount_discount?, :to => :pack
  delegate :item, :to => :exploded_item
  delegate :price_discount_pack, :shipping_discount_pack, :to => :exploded_item
  delegate :price_discount_ticket, :shipping_discount_ticket, :to => :exploded_item
  delegate :price_exclusive_pack, :shipping_exclusive_pack, :to => :exploded_item
  delegate :price_exclusive_ticket, :shipping_exclusive_ticket, :to => :exploded_item

  def initialize(exploded_item, pack, checkbot)
    @exploded_item = exploded_item
    @pack = pack
    @checkbot = checkbot
  end

  def choose_subtotal
    choose_subtotal_discount || mixed_item_price
  end

  def choose_subtotal_discount
    case
    when quantity_discount?
      discount_subtotal_compensated if or_more || in_mixed_pack.present? || number_of_bottles_with_same_discount_pack < applicable_number_of_bottles_with_same_discount_pack
    when amount_discount?
      discount_tally_compensated if or_more || in_mixed_pack.present? || amount_with_same_discount_pack < applicable_amount_with_same_discount_pack
    end
  end

  def subtotal(ticket = nil)
    return discount_subtotal(ticket) if quantity_discount?
    return discount_tally(ticket) if amount_discount?
  end

protected

  def discount_subtotal(ticket = nil)
    full_product_price = full_product_price(ticket)

    return discount_price if attr_price
    return discount_amount_off(full_product_price) if attr_amount_off
    return discount_percentage_off(full_product_price) if attr_percentage_off
  end

  def discount_subtotal_compensated(ticket = nil)
    full_product_price = full_product_price(ticket)

    return discount_price_compensated if attr_price
    return discount_amount_off_compensated(full_product_price) if attr_amount_off
    return discount_percentage_off(full_product_price) if attr_percentage_off
  end

  def divisor(pack_amount = nil)
    pack_amount ||= amount_with_removed_tickets
    or_more ? pack_amount : pack.amount
  end

  def full_product_price(ticket = nil)
    ticket.present? ? ticket.discount_subtotal : mixed_item_price
  end

private

  def amount_off
    attr_amount_off / number_of_bottles if attr_amount_off
  end

  def amount_off_compensated
    attr_amount_off / number_of_bottles_compensated if attr_amount_off
  end

  def applicable_amount_with_same_discount_pack
    (amount_with_removed_tickets / divisor).floor * divisor
  end

  def amount_with_same_item(item = nil)
    item ||= exploded_item.item

    return exploded_items.sum { |exploded_item| exploded_item.item == item ? exploded_item.price : 0.0 } if pack.or_more

    exploded_items.sum do |e|
      e.item.packable.tags.any? do |t|
        t == pack.packed_products.first.packable
      end ? e.price : 0.0
    end
  end

  def discount_amount_off(full_product_price)
    non_negative_discount(full_product_price - amount_off)
  end

  def discount_amount_off_compensated(full_product_price)
    non_negative_discount(full_product_price - amount_off_compensated)
  end

  def discount_percentage_off(full_product_price)
    non_negative_discount(full_product_price - (full_product_price * percentage_off * 0.01.to_d))
  end

  def discount_price
    non_negative_discount(price)
  end

  def discount_price_compensated
    non_negative_discount(price_compensated)
  end

  def discount_tally(ticket = nil)
    full_product_price = full_product_price(ticket)

    return discount_tally_price if attr_price
    return non_negative_discount(discount_tally_amount_off(full_product_price)) if attr_amount_off
    return discount_tally_percentage_off(full_product_price) if attr_percentage_off
  end

  def discount_tally_compensated(ticket = nil)
    return discount_tally_price_compensated if attr_price
    return discount_tally_amount_off_compensated if attr_amount_off
    return discount_tally_percentage_off_compensated if attr_percentage_off
  end

  def discountable_amount
    exploded_item.price - non_discountable_amount
  end

  def discountable_amount_compensated
    exploded_item.price - non_discountable_amount_compensated
  end

  def in_mixed_pack
    item.specific_mixed_pack
  end

  def non_discountable_amount
    non_negative_discount(exploded_item.price - (exploded_item.price * applicable_amount_with_same_discount_pack / amount_with_same_discount_pack))
  end

  def non_discountable_amount_compensated
    non_negative_discount(exploded_item.price + amount_with_same_discount_pack - applicable_amount_with_same_discount_pack)
  end

  def non_negative_discount(discount)
    discount < 0 ? 0.0.to_d : discount
  end

  def number_of_bottles
    or_more ? number_of_bottles_with_same_pack : pack.quantity
  end

  def number_of_removed_bottles
    or_more ? number_of_removed_bottles_with_same_pack : 0
  end

  def percentage_off
    attr_percentage_off if attr_percentage_off
  end

  def price
    attr_price / number_of_bottles if attr_price
  end

  def price_compensated
    attr_price / number_of_bottles_compensated if attr_price
  end
end
