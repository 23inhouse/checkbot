module Checkbot
  class CartItem
    extend Forwardable

    attr_accessor :item, :quantity
    attr_accessor :price_rrp, :price_discount, :price_subtotal
    attr_accessor :shipping_rrp, :shipping_discount, :shipping_subtotal

    def_delegators :item, :name, :price

    def initialize(item, quantity = 1, options = {})
      @item = item
      @quantity = quantity

      @price_rrp         = Money.new(options[:price_rrp])         if options.has_key?(:price_rrp)
      @price_discount    = Money.new(options[:price_discount])    if options.has_key?(:price_discount)
      @price_subtotal    = Money.new(options[:price_subtotal])    if options.has_key?(:price_subtotal)
      @shipping_rrp      = Money.new(options[:shipping_rrp])      if options.has_key?(:shipping_rrp)
      @shipping_discount = Money.new(options[:shipping_discount]) if options.has_key?(:shipping_discount)
      @shipping_subtotal = Money.new(options[:shipping_subtotal]) if options.has_key?(:shipping_subtotal)
    end

    def to_s
      [item_to_s, price_saving_to_s, shipping_savings_to_s].compact.join(' ')
    end

    def type
      return :mixed_pack if mixed_pack?
      return :product    if product?
    end

  private

    def item_to_s
      [].tap { |a|
        a << '#'
        a << quantity.to_s
        a << (mixed_pack? ? '[' : '(')
        a << name+' '+price.to_s
        a << (mixed_pack? ? ']' : ')')
      }.join
    end

    def mixed_pack?
      item.is_a?(MixedPack)
    end

    def price_saving_to_s
      return if !price_rrp
      [].tap { |a|
        a << '->'
        a << price_rrp.to_s
        a << '('+price_subtotal.to_s+')' if price_subtotal
      }.join(' ')
    end

    def product?
      item.is_a?(Product)
    end

    def shipping_savings_to_s
      return if !shipping_rrp
      [].tap { |a|
        a << 'sh ->'
        a << shipping_rrp.to_s
        a << '('+shipping_subtotal.to_s+')' if shipping_subtotal
      }.join(' ')
    end
  end
end
