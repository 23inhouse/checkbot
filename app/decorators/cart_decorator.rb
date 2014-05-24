class CartDecorator
  def initialize(cart)
    return if cart.nil?
    @cart = cart
    @items = []
    cart.items.each { |item| @items << item.clone }
  end

  def generate_cart_by_price
    generate_cart_by_mixed_pack(:price)
  end

  def generate_cart_by_product
    generate_cart_by_item
  end

  def generate_cart_by_quantity
    generate_cart_by_mixed_pack(:quantity)
  end

  def generate_cart_by_shipping
    generate_cart_by_mixed_pack(:shipping)
  end

private

  def generate_cart_by_item
    return unless @cart.present?

    generated_cart = @cart.dup
    generated_cart.seller = @cart.seller
    generated_cart.items = []

    previous_product = nil

    @items.sort_by(&:full_name).group_by(&:full_name).each do |full_name, exploded_items|
      exploded_items.each do |exploded_item|

        if previous_product == exploded_item.purchasable
          item = generated_cart.items.last

          item.quantity += exploded_item.quantity
          item.price_rrp += exploded_item.price_rrp
          item.price_subtotal += exploded_item.price_subtotal
          item.price_discount = item.price_rrp - item.price_subtotal
          item.shipping_rrp = (item.shipping_rrp || 0) + (exploded_item.shipping_rrp || 0)
          item.shipping_subtotal = (item.shipping_subtotal || 0) + (exploded_item.shipping_subtotal || 0)
          item.shipping_discount = item.shipping_rrp - item.shipping_subtotal
        else
          item = exploded_item.clone

          generated_cart.items << item.dup
          previous_product = item.purchasable
        end
      end
    end

    generated_cart
  end

  def generate_cart_by_mixed_pack(generate_by = :price)
    return unless @cart.present?

    generated_cart = @cart.dup
    generated_cart.seller = @cart.seller
    generated_cart.discount_tallies = @cart.discount_tallies
    generated_cart.items = []

    previous_product = previous_pack = previous_in_a_pack = nil

    @items.group_by(&:specific_mixed_pack).each do |specific_mixed_pack, items|
      in_a_pack = nil

      if specific_mixed_pack.present?
        specific_mixed_pack_name = items.first.specific_mixed_pack_name || specific_mixed_pack.name
        item = generated_cart.items.build(:purchasable => specific_mixed_pack, :full_name => specific_mixed_pack_name, :winelist => items.first.winelist)
        item.price = specific_mixed_pack.price
        item.quantity = @items.inject(0) { |sum, i|
          sum + (i.specific_mixed_pack == specific_mixed_pack ? i.quantity : 0)
        } / specific_mixed_pack.quantity

        price_discount_pack = items.first.price_pack
        shipping_discount_pack = items.first.shipping_pack

        item.price_pack = price_discount_pack
        item.price_pack_name = price_discount_pack.name if price_discount_pack.present?
        item.price_rrp = (specific_mixed_pack.price * item.quantity) || 0
        item.price_discount = item.price_subtotal = 0

        item.shipping_pack = shipping_discount_pack
        item.shipping_pack_name = shipping_discount_pack.name if shipping_discount_pack.present?
        item.shipping_rrp = (items.first.shipping_rrp * item.quantity if @cart.complete_cart?) || 0
        item.shipping_discount = item.shipping_subtotal = 0

        in_a_pack = item
      end

      items.sort_by(&:full_name).group_by(&:full_name).each do |full_name, exploded_items|
        exploded_items.each do |exploded_item|

          if in_a_pack.present?
            in_a_pack.price_subtotal += exploded_item.price_subtotal
          end

          this_pack = case generate_by
          when :price
            exploded_item.price_pack
          when :shipping
            exploded_item.shipping_pack
          when :quantity
            true
          end

          if previous_product == exploded_item.purchasable && previous_pack == this_pack && in_a_pack == previous_in_a_pack
            item = generated_cart.items.last

            item.quantity += exploded_item.quantity
            item.price_rrp += exploded_item.price_rrp
            item.price_subtotal += exploded_item.price_subtotal
            item.price_discount = item.price_rrp - item.price_subtotal
            item.shipping_rrp = (item.shipping_rrp || 0) + (exploded_item.shipping_rrp || 0)
            item.shipping_subtotal = (item.shipping_subtotal || 0) + (exploded_item.shipping_subtotal || 0)
            item.shipping_discount = item.shipping_rrp - item.shipping_subtotal
          else
            item = exploded_item.clone

            generated_cart.items << item
            previous_product = item.purchasable
            previous_pack = this_pack
            previous_in_a_pack = in_a_pack
          end
        end
      end

      if in_a_pack.present?
        in_a_pack.price_discount = (in_a_pack.price_rrp - in_a_pack.price_subtotal).round(9)
      end

    end

    generated_cart.items.each do |item|
      item.price_discount = item.price_discount.round(8)
      item.price_rrp = item.price_rrp.round(8)
      item.price_subtotal = item.price_subtotal.round(8)
      if @cart.complete_cart?
        item.shipping_discount = item.shipping_discount.round(8)
        item.shipping_rrp = item.shipping_rrp.round(8)
        item.shipping_subtotal = item.shipping_subtotal.round(8)
      end
    end

    generated_cart.discount_tallies.sort

    generated_cart
  end
end
