class ExplodedItem
  extend Memoist

  attr_accessor :item
  attr_accessor :price_discount_ticket, :shipping_discount_ticket
  attr_reader :price_exclusive_ticket, :shipping_exclusive_ticket
  attr_reader :price_per_item, :shipping_per_item
  attr_reader :price_ticket, :shipping_ticket

  attr_reader :price_tickets, :shipping_tickets
  attr_reader :removed_price_tickets, :removed_shipping_tickets

  delegate :full_name, :price, :purchasable, :to => :item
  delegate :specific_mixed_pack, :specific_mixed_pack=, :to => :item
  delegate :price, :to => :purchasable
  delegate :qualify_for_price_discount, :qualify_for_shipping_discount, :to => :purchasable
  delegate :receive_price_discount, :receive_shipping_discount, :to => :purchasable

  def initialize(item, price_per_item, shipping_per_item)
    @item = item
    @price_per_item = price_per_item
    @shipping_per_item = shipping_per_item
    remove_all_tickets
    @removed_price_tickets = []
    @removed_shipping_tickets = []
  end

  def choose_price_ticket
    choose_price_exclusive_ticket
    choose_price_discount_ticket
  end

  def choose_shipping_ticket
    choose_shipping_exclusive_ticket
    choose_shipping_discount_ticket
  end

  def unique_key
    pdk = price_discount_pack.to_s[-17..-2] unless price_tally?
    sdk = shipping_discount_pack.to_s[-17..-2] unless shipping_tally?
    "#{specific_mixed_pack.to_s[-17..-2]}:#{pdk}:#{sdk}"
  end

  def insert_ticket(pack, packed_product, price_or_shipping, checkbot)
    if receive?(pack, packed_product.packable, price_or_shipping)
      insert_price_tickets(PriceTicket.new(self, pack, checkbot)) if pack.price_discount?
      insert_shipping_tickets(ShippingTicket.new(self, pack, checkbot)) if pack.shipping_discount?
      true
    end
  end

  def price_discount_pack
    price_discount_ticket.pack if price_discount_ticket.present?
  end

  def price_discount_pack_name
    price_discount_pack.name if price_discount_pack.present?
  end

  def price_exclusive_pack
    price_exclusive_ticket.pack if price_exclusive_ticket.present?
  end

  def price_subtotal
    return price_discount_ticket.subtotal(price_exclusive_ticket) if price_discount_ticket.present? && pack_receive_price_discounts? && pack_qualify_for_price_discounts?
    return price_exclusive_ticket.subtotal if price_exclusive_ticket.present?
    price
  end

  def price_tally?
    price_discount_ticket.amount_discount? if price_discount_ticket.present?
  end

  def qualify?(pack, product, price_or_shipping)
    case price_or_shipping
    when :price then return false unless qualify_for_price_discount?(pack)
    when :shipping then return false unless qualify_for_shipping_discount?(pack)
    end

    ticket_applicable?(pack, product, price_or_shipping)
  end

  def remove_all_tickets
    remove_all_discount_tickets
    remove_all_chosen_tickets
    remove_all_exclusive_tickets
  end

  def specific_mixed_pack_price_subtotal
    price_exclusive_pack.present? ? price_exclusive_ticket.subtotal : price_per_item
  end

  def specific_mixed_pack_shipping_subtotal
    shipping_exclusive_pack.present? ? shipping_exclusive_ticket.subtotal : shipping_per_item
  end

  def shipping_discount_pack
    shipping_discount_ticket.pack if shipping_discount_ticket.present?
  end

  def shipping_discount_pack_name
    shipping_discount_pack.name if shipping_discount_pack.present?
  end

  def shipping_exclusive_pack
    shipping_exclusive_ticket.pack if shipping_exclusive_ticket.present?
  end

  def shipping_subtotal
    return shipping_discount_ticket.subtotal(shipping_exclusive_ticket) if shipping_discount_ticket.present? && pack_receive_shipping_discounts? && pack_qualify_for_shipping_discounts?
    return shipping_exclusive_ticket.subtotal if shipping_exclusive_ticket.present?
    shipping_per_item
  end

  def shipping_tally?
    shipping_discount_ticket.amount_discount? if shipping_discount_ticket.present?
  end

private

  def choose_best_discount_ticket(tickets)
    if tickets.present?
      ticket = tickets.min { |a, b| a.choose_subtotal <=> b.choose_subtotal }
      ticket if ticket.choose_subtotal_discount.present?
    end
  end

  def choose_price_exclusive_ticket
    @price_exclusive_ticket = @price_tickets.select { |ticket| ticket.pack == specific_mixed_pack }.first
  end

  def choose_price_discount_ticket
    tickets = @price_tickets.reject(&:specific_mixed_pack?)
    @price_discount_ticket = choose_best_discount_ticket(tickets)
    remove_all_price_discount_tickets if @price_discount_ticket.present?
    @price_discount_ticket
  end

  def choose_shipping_exclusive_ticket
    @shipping_exclusive_ticket = @shipping_tickets.select { |ticket| ticket.pack == specific_mixed_pack }.first
  end

  def choose_shipping_discount_ticket
    tickets = @shipping_tickets.reject(&:specific_mixed_pack?)
    @shipping_discount_ticket = choose_best_discount_ticket(tickets)
    remove_all_shipping_discount_tickets if @shipping_discount_ticket.present?
    @shipping_discount_ticket
  end

  def insert_price_tickets(ticket)
    @price_tickets << ticket if receive_price_discount?(ticket.pack)
  end

  def insert_shipping_tickets(ticket)
    @shipping_tickets << ticket if receive_shipping_discount?(ticket.pack)
  end

  def pack_qualify_for_price_discounts?
    price_exclusive_pack.nil? || price_exclusive_pack.qualify_for_price_discount
  end

  def pack_qualify_for_shipping_discounts?
    shipping_exclusive_pack.nil? || shipping_exclusive_pack.qualify_for_shipping_discount
  end

  def pack_receive_price_discounts?
    price_exclusive_pack.nil? || price_exclusive_pack.receive_price_discount
  end

  def pack_receive_shipping_discounts?
    shipping_exclusive_pack.nil? || shipping_exclusive_pack.receive_shipping_discount
  end

  def qualify_for_price_discount?(pack = nil)
    return true if specific_mixed_pack == pack if pack.present?
    specific_mixed_pack.present? ? specific_mixed_pack.qualify_for_price_discount : qualify_for_price_discount
  end

  def qualify_for_shipping_discount?(pack = nil)
    return true if specific_mixed_pack == pack if pack.present?
    specific_mixed_pack.present? ? specific_mixed_pack.qualify_for_shipping_discount : qualify_for_shipping_discount
  end

  def receive?(pack, product, price_or_shipping)
    case price_or_shipping
    when :price
      return false unless price_discount_pack != pack || receive_price_discount?(pack)
    when :shipping
      return false unless price_discount_pack != pack || receive_shipping_discount?(pack)
    end

    ticket_applicable?(pack, product, price_or_shipping)
  end

  def receive_price_discount?(pack = nil)
    return true if specific_mixed_pack == pack if pack.present?
    specific_mixed_pack.present? ? specific_mixed_pack.receive_price_discount : receive_price_discount
  end

  def receive_shipping_discount?(pack = nil)
    return true if specific_mixed_pack == pack if pack.present?
    specific_mixed_pack.present? ? specific_mixed_pack.receive_shipping_discount : receive_shipping_discount
  end

  def remove_all_chosen_tickets
    @price_discount_ticket = nil
    @shipping_discount_ticket = nil
  end

  def remove_all_discount_tickets
    remove_all_price_discount_tickets
    remove_all_shipping_discount_tickets
  end

  def remove_all_exclusive_tickets
    @price_exclusive_ticket = nil
    @shipping_exclusive_ticket = nil
  end

  def remove_all_price_discount_tickets
    @removed_price_tickets = @price_tickets
    @price_tickets = []
  end

  def remove_all_shipping_discount_tickets
    @removed_shipping_tickets = @shipping_tickets
    @shipping_tickets = []
  end

  def ticket_applicable?(pack, product, price_or_shipping)
    return false if pack.specific_mixed_pack? && !specific_mixed_pack
    return false if !pack.specific_mixed_pack? && specific_mixed_pack && product.is_a?(Wine)
    return false if ticket_applied?(pack)

    if product.is_a?(Wine)
      purchasable == product
    elsif product.is_a?(Pack)
      specific_mixed_pack == product
    else
      if specific_mixed_pack.present?
        specific_mixed_pack.tags.any? { |tag| tag == product }
      else
        purchasable.tags.any? { |tag| tag == product }
      end
    end
  end

  def ticket_applied?(pack)
    (@price_tickets + @shipping_tickets).any? { |ticket| ticket.pack == pack }
  end

  # ===========================

  def drop_best_ticket(tickets)
    tickets.each { |t| puts "    choose best discount ticket [#{t.pack.name}] for [#{t.exploded_item.full_name}] ==> [#{t.choose_subtotal}]" }
  end
end
