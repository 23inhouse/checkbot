class CheckoutBot
  extend Memoist

  attr_accessor :cart, :exploded_items, :packs, :seller, :total
  attr_accessor :shipping_charge

  delegate :number_of_bottles, :shipping_charges, :transaction_charge, :to => :cart

  def initialize(seller = nil, cart = nil, packs = [])
    @seller = seller
    @cart = cart
    @packs = packs
    @exploded_items = []
  end

  def handling_charges
    return 0.0.to_d unless seller.present?
    seller.handling_charges.round(9)
  end

  def new_cart
    prepare_cart
    CartGenerator.new(self).new_cart
  end

  def prepare_cart
    return if @cart.nil?

    explode_items
    explode_packs

    sort_exploded_items

    sort_packs_for_fitness(@price_packs, :price)
    sort_packs_for_fitness(@shipping_packs, :shipping) if shipping_charges.present?
    remove_all_tickets

    scan_packs(@price_packs, :price)
    remove_partial_pack_price_tickets
    choose_price_tickets

    if shipping_charges.present?
      scan_packs(@shipping_packs, :shipping)
      remove_partial_pack_shipping_tickets
      choose_shipping_tickets
    end
  end

  def scd_charges
    ((total_price || 0) * transaction_charge).to_d
  end

  def shipping_and_handling_charges
    shipping_charges + handling_charges
  end

  def total_price
    exploded_items.inject(0.0.to_d) { |sum, exploded_item| sum + exploded_item.price_subtotal }.round(9)
  end

  def total_shipping_price
    exploded_items.inject(0.0.to_d) { |sum, exploded_item| sum + exploded_item.shipping_subtotal }.round(9) if shipping_charges
  end

private

  def apply_tickets_with_pack(pack)
    exploded_items.collect { |i| pack.packed_products.any? { |pp| i.insert_ticket(pack, pp, @price_or_shipping, self) } }.include?(true)
  end

  def choose_price_tickets
    @price_packs.each do |pack|
      exploded_items.each do |ei|
        ei.choose_price_ticket if ei.price_tickets.any? { |t| t.pack == pack }
      end
    end
  end

  def choose_shipping_tickets
    @shipping_packs.each do |pack|
      exploded_items.each do |ei|
        ei.choose_shipping_ticket if ei.shipping_tickets.any? { |t| t.pack == pack }
      end
    end
  end

  def explode_items
    @cart.items.each do |item|
      item.quantity.times do
        case item.purchasable
        when Pack
          explode_packed_products(item)
        else
          exploded_items << ExplodedItem.new(item, item.purchasable.price, shipping_per_item)
        end
      end
    end
  end

  def explode_packed_products(item)
    pack = item.purchasable
    pack.packed_products.each do |packed_product|
      packed_product.quantity.times do
        packed_item = Item.new(:full_name => packed_product.name, :purchasable => packed_product.packable, :quantity => 1, :specific_mixed_pack => pack, :winelist => item.winelist)
        exploded_items << ExplodedItem.new(packed_item, packed_item.purchasable.price, shipping_per_item)
      end
    end
  end

  def explode_packs
    @packs.reject! { |pack| pack.is_a?(Discount) && pack.conditions.to_a.size > 0 }

    @shipping_packs = @packs.select(&:shippingish_discount?)
    @price_packs = @packs.select(&:priceish_discount?)
  end

  def original_price
    exploded_items.inject(0.0.to_d) { |sum, exploded_item| sum + exploded_item.price }.round(9)
  end
  memoize :original_price

  def packs_fatness(pack)
    sum = 0
    sum += 1000 if pack.read_attribute(:shipping_percentage_off).present?
    sum += 100 if pack.packed_products.any?(&:quantity)
    sum
  end

  def pack_fitness(pack)
    remove_all_tickets
    scan_packs([pack], @price_or_shipping, false)

    case @price_or_shipping
    when :price
      choose_price_tickets
      original_price - total_price
    when :shipping
      choose_shipping_tickets
      shipping_charges - total_shipping_price
    end
  end
  memoize :pack_fitness

  def qualify?(pack)
    pack.packed_products.all? { |pp| qualifying_product?(pack, pp) }
  end

  def qualifying_by_amount(pack, packed_product)
    exploded_items.sum { |i| i.qualify?(pack, packed_product.packable, @price_or_shipping) ? (pack.price_discount? ? i.price : i.price_subtotal) : 0 }
  end

  def qualifying_by_quantity(pack, packed_product)
    exploded_items.sum { |i| i.qualify?(pack, packed_product.packable, @price_or_shipping) ? 1 : 0 }
  end

  def qualifying_product?(pack, packed_product)
    if packed_product.quantity.present?
      qualifying_by_quantity(pack, packed_product) >= packed_product.quantity
    else
      qualifying_by_amount(pack, packed_product) >= packed_product.amount
    end
  end
  memoize :qualifying_product?

  def remove_all_tickets
    exploded_items.each { |exploded_item| exploded_item.remove_all_tickets }
  end

  def remove_partial_pack_price_tickets
    exploded_items.select { |i| i.specific_mixed_pack.present? }.each do |exploded_item|
      exploded_item.price_tickets.delete_if do |discount_ticket|
        unless discount_ticket.pack == exploded_item.specific_mixed_pack
          remove_partial_pack_price_ticket?(discount_ticket, exploded_item.specific_mixed_pack)
        end
      end
    end
  end

  def remove_partial_pack_price_ticket?(discount_ticket, specific_mixed_pack)
    exploded_items.select { |i| i.specific_mixed_pack == specific_mixed_pack }.any? do |exploded_item|
      exploded_item.price_tickets.none? { |ticket| ticket.pack == discount_ticket.pack }
    end
  end

  def remove_partial_pack_shipping_tickets
    exploded_items.select { |i| i.specific_mixed_pack.present? }.each do |exploded_item|
      exploded_item.shipping_tickets.delete_if do |discount_ticket|
        unless discount_ticket.pack == exploded_item.specific_mixed_pack
          remove_partial_pack_shipping_ticket?(discount_ticket, exploded_item.specific_mixed_pack)
        end
      end
    end
  end

  def remove_partial_pack_shipping_ticket?(discount_ticket, specific_mixed_pack)
    exploded_items.select { |i| i.specific_mixed_pack == specific_mixed_pack }.any? do |exploded_item|
      exploded_item.shipping_tickets.none? { |ticket| ticket.pack == discount_ticket.pack }
    end
  end

  def scan_packs(packs, price_or_shipping = nil, scan_rewards = true)
    @price_or_shipping = price_or_shipping if price_or_shipping.present?

    rewards = []
    packs.each do |pack|
      maximum_quantity_that_any_pack_could_be = number_of_bottles
      while qualify?(pack) && maximum_quantity_that_any_pack_could_be > 0
        maximum_quantity_that_any_pack_could_be -= 1
        rewards += pack.rewards if pack.is_a?(Discount)
        break unless apply_tickets_with_pack(pack)
      end
    end

    if scan_rewards && rewards.present?
      scan_reward_packs(rewards.uniq)
      rewards.uniq.each do |reward|
        @price_packs << reward if reward.price_discount?
        @shipping_packs << reward if reward.shippingish_discount?
      end
    end
  end
  memoize :scan_packs

  def scan_reward_packs(rewards)
    scan_packs(rewards, @price_or_shipping, false)
  end

  def shipping_per_item
    shipping_and_handling_charges / number_of_bottles if shipping_charges.present?
  end
  memoize :shipping_per_item

  def sort_exploded_items
    exploded_items.sort! do |a, b|
      if b.price == a.price
        a.full_name <=> b.full_name
      else
        (b.price || 0.0.to_d) <=> (a.price || 0.0.to_d)
      end
    end
  end

  def sort_packs_for_fitness(packs, price_or_shipping = nil)
    @price_or_shipping = price_or_shipping if price_or_shipping.present?
    packs.sort! do |a, b|
      if (preliminary_result = (pack_fitness(b) <=> pack_fitness(a))) != 0
        preliminary_result
      else
        packs_fatness(b) <=> packs_fatness(a)
      end
    end
  end

  def total_price_rrp
    cart.items.inject(0.0.to_d) { |sum, item| sum + (item.price * item.quantity)}.round(9)
  end

  # ===========================

  # def drop_info
  #   puts '================================ drop_info ================================'
  #   exploded_items.each do |exploded_item|
  #     # next unless exploded_item.full_name == '2009 Chardonnay'
  #     puts "----- #{exploded_item.full_name}"
  #     p "SMP: #{exploded_item.specific_mixed_pack.name if exploded_item.specific_mixed_pack.present?}"
  #     price_exclusive_pack_name = exploded_item.price_exclusive_pack.name if exploded_item.price_exclusive_pack.present?
  #     shipping_exclusive_pack_name = exploded_item.shipping_exclusive_pack.name if exploded_item.shipping_exclusive_pack.present?
  #     p "Exc: D-#{price_exclusive_pack_name}, Sh-#{shipping_exclusive_pack_name}"
  #     p "PTks: " + exploded_item.price_tickets.collect { |pt| pt.pack.name }.join(', ')
  #     p "PDT: #{exploded_item.price_discount_pack_name}"
  #     p "STks: " + exploded_item.shipping_tickets.collect { |pt| pt.pack.name }.join(', ')
  #     p "SDT: #{exploded_item.shipping_discount_pack_name}"
  #     puts
  #   end
  #   puts '================================           ================================'
  # end
end
