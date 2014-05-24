class CartGenerator
  attr_accessor :cart, :checkbot, :exploded_items

  delegate :handling_charges, :scd_charges, :shipping_charges, :transaction_charge, :to => :checkbot
  delegate :order, :to => :cart
  delegate :total_price, :total_shipping_price, :to => :checkbot

  def initialize(checkbot)
    @checkbot = checkbot
    @cart = checkbot.cart
    @exploded_items = checkbot.exploded_items
  end

  def generate_cart
    return unless cart.present?

    generate_cart = add_cart

    add_charges(generate_cart)

    exploded_items.group_by(&:unique_key).each do |unique_key, grouped_exploded_items|
      grouped_exploded_items.sort_by(&:full_name).group_by(&:full_name).each do |full_name, exploded_items|
        add_discount_tallys(generate_cart, exploded_items)
        add_items(generate_cart, exploded_items)
      end
    end

    round_items(generate_cart.items)
    round_tallies(generate_cart.discount_tallies)
    round_totals(generate_cart)

    generate_cart.order = order

    remove_tally_discounts(generate_cart)

    generate_cart
  end

  def new_cart
    generate_cart
  end

private

  def add_cart
    new_cart = cart.dup
    new_cart.seller = cart.seller
    new_cart.items = []
    new_cart.discount_tallies = []
    new_cart.total = nil
    new_cart.total_rrp = nil
    new_cart.scd_charges = nil
    new_cart
  end

  def add_charges(new_cart)
    new_cart.shipping_charges = shipping_charges
    new_cart.handling_charges = handling_charges
    new_cart.transaction_charge = transaction_charge
    new_cart.scd_charges = scd_charges
  end

  def add_discount_tallys(new_cart, exploded_items)
    previous_price_tally = previous_shipping_tally = previous_price_pack = previous_shipping_pack = nil

    exploded_items.each do |exploded_item|
      if exploded_item.price_tally?
        if previous_price_tally = existing_tally(new_cart, exploded_item.price_discount_pack, :price)
          add_to_existing_discount_tally(new_cart, exploded_item, :price, previous_price_tally)
        else
          add_new_discount_tally(new_cart, exploded_item, :price)
        end
      end

      if exploded_item.shipping_tally?
        if previous_shipping_tally = existing_tally(new_cart, exploded_item.shipping_discount_pack, :shipping)
          add_to_existing_discount_tally(new_cart, exploded_item, :shipping, previous_shipping_tally)
        else
          add_new_discount_tally(new_cart, exploded_item, :shipping)
        end
      end
    end
  end

  def add_items(new_cart, exploded_items)
    previous_product = previous_specific_mixed_pack = previous_price_pack = previous_shipping_pack = nil

    exploded_items.each do |exploded_item|
      price_discount_pack = quantity_pack(exploded_item.price_discount_pack)
      shipping_discount_pack = quantity_pack(exploded_item.shipping_discount_pack)

      if previous_product == exploded_item.purchasable && previous_specific_mixed_pack == exploded_item.specific_mixed_pack && previous_price_pack == price_discount_pack && previous_shipping_pack == shipping_discount_pack
        add_to_existing_item(new_cart, exploded_item)
      else
        add_new_item(new_cart, exploded_item)

        previous_product = exploded_item.purchasable
        previous_specific_mixed_pack = exploded_item.specific_mixed_pack
        previous_price_pack = quantity_pack(price_discount_pack)
        previous_shipping_pack = quantity_pack(shipping_discount_pack)
      end
    end
  end

  def add_new_item(new_cart, exploded_item)
    item = exploded_item.item.dup
    item.purchasable = exploded_item.item.purchasable
    item.price = exploded_item.price
    item.quantity = 1

    item.specific_mixed_pack = exploded_item.specific_mixed_pack
    if item.specific_mixed_pack.present?
      item.specific_mixed_pack_quantity = item.quantity.to_s.to_d / exploded_item.specific_mixed_pack.quantity
      item.price = exploded_item.price * item.specific_mixed_pack.discount_price / item.specific_mixed_pack.full_price if item.specific_mixed_pack.discount_price.present?
    end

    item.price_pack = exploded_item.price_discount_pack
    item.price_pack_name = exploded_item.price_discount_pack_name
    item.price_subtotal = subtotal_price(exploded_item)
    item.price_rrp = exploded_item.specific_mixed_pack_price_subtotal
    item.price_discount = item.price_rrp - item.price_subtotal

    if shipping_charges.present?
      item.shipping_pack = exploded_item.shipping_discount_pack
      item.shipping_pack_name = exploded_item.shipping_discount_pack_name
      item.shipping_price = exploded_item.shipping_per_item
      item.shipping_subtotal = subtotal_shipping(exploded_item)
      item.shipping_rrp = exploded_item.specific_mixed_pack_shipping_subtotal
      item.shipping_discount = item.shipping_rrp - item.shipping_subtotal
    end

    new_cart.items << item
  end

  def add_new_discount_tally(new_cart, exploded_item, price_or_shipping)
    if price_or_shipping == :price
      price_discount_pack = exploded_item.price_discount_pack
      price_discount = exploded_item.specific_mixed_pack_price_subtotal - exploded_item.price_subtotal
      new_cart.discount_tallies.build(
        :price_pack => price_discount_pack,
        :price_pack_name => price_discount_pack.name,
        :price_discount => price_discount
      )
    end

    if shipping_charges.present? && price_or_shipping == :shipping
      shipping_discount_pack = exploded_item.shipping_discount_pack
      shipping_discount = exploded_item.specific_mixed_pack_shipping_subtotal - exploded_item.shipping_subtotal
      new_cart.discount_tallies.build(
        :shipping_pack => shipping_discount_pack,
        :shipping_pack_name => shipping_discount_pack.name,
        :shipping_discount => shipping_discount
      )
    end
  end

  def add_to_existing_item(new_cart, exploded_item)
    item = new_cart.items.last
    item.quantity += 1

    if item.specific_mixed_pack.present?
      item.specific_mixed_pack_quantity = item.quantity.to_s.to_d / exploded_item.specific_mixed_pack.quantity
    end


    item.price_rrp += exploded_item.specific_mixed_pack_price_subtotal
    item.price_subtotal += subtotal_price(exploded_item)
    item.price_discount += item.price_rrp - item.price_subtotal

    if shipping_charges.present?
      item.shipping_rrp += exploded_item.specific_mixed_pack_shipping_subtotal
      item.shipping_subtotal += subtotal_shipping(exploded_item)
      item.shipping_discount += item.shipping_rrp - item.shipping_subtotal
    end
  end

  def add_to_existing_discount_tally(new_cart, exploded_item, price_or_shipping, previous_tally)
    if price_or_shipping == :price
      price_discount = exploded_item.specific_mixed_pack_price_subtotal - exploded_item.price_subtotal
      previous_tally.price_discount += price_discount
    end

    if shipping_charges.present? && price_or_shipping == :shipping
      shipping_discount = exploded_item.specific_mixed_pack_shipping_subtotal - exploded_item.shipping_subtotal
      previous_tally.shipping_discount += shipping_discount
    end
  end

  def existing_tally(new_cart, discount_pack, price_or_shipping)
    new_cart.discount_tallies.select { |t| discount_pack == (price_or_shipping == :price ? t.price_pack : t.shipping_pack) }.first
  end

  def quantity_pack(pack)
    pack = pack.present? && pack.quantity_discount? ? pack : nil
  end

  def remove_tally_discounts(new_cart)
    new_cart.items.each do |item|
      if item.price_pack.present? && item.price_pack.amount_discount?
        item.price_pack = nil
        item.price_pack_name = nil
      end

      if item.shipping_pack.present? && item.shipping_pack.amount_discount?
        item.shipping_pack = nil
        item.shipping_pack_name = nil
      end
    end
  end

  def round_items(items)
    items.each do |item|
      item.price_discount = (item.price_rrp - item.price_subtotal).round(9)
      item.price_rrp = item.price_rrp.round(9)
      item.price_subtotal = item.price_subtotal.round(9)
      if shipping_charges.present?
        item.shipping_discount = (item.shipping_rrp - item.shipping_subtotal).round(9)
        item.shipping_rrp = item.shipping_rrp.round(9)
        item.shipping_subtotal = item.shipping_subtotal.round(9)
      end
    end
  end

  def round_tallies(tallies)
    tallies.each do |tally|
      tally.price_discount = tally.price_discount.round(9) if tally.price_discount.present?
      tally.shipping_discount = tally.shipping_discount.round(9) if tally.shipping_discount.present?
    end
  end

  def round_totals(new_cart)
    new_cart.price_rrp = new_cart.items.inject(0.0.to_d) { |sum, item| sum + item.price_rrp }
    new_cart.price_subtotal = total_price.round(9)
    new_cart.price_discount = new_cart.price_rrp - new_cart.price_subtotal

    new_cart.quantity = new_cart.items.inject(0) { |sum, item| sum + item.quantity }

    if shipping_charges.present?
      new_cart.shipping_rrp = new_cart.shipping_charges.round(9) + new_cart.handling_charges
      new_cart.shipping_subtotal = total_shipping_price.round(9)
      new_cart.shipping_discount = new_cart.shipping_rrp - new_cart.shipping_subtotal

      new_cart.total = new_cart.price_subtotal + new_cart.shipping_subtotal
      new_cart.total_rrp = new_cart.price_rrp + new_cart.shipping_rrp
    end
  end

  def subtotal_price(exploded_item)
    exploded_item.price_tally? ? exploded_item.specific_mixed_pack_price_subtotal : exploded_item.price_subtotal
  end

  def subtotal_shipping(exploded_item)
    exploded_item.shipping_tally? ? exploded_item.specific_mixed_pack_shipping_subtotal : exploded_item.shipping_subtotal
  end
end
