module Checkbot
  class Context
    extend Forwardable

    attr_accessor :cart_context
    attr_accessor :discount_context
    attr_accessor :mixed_pack_context
    attr_accessor :product_context
    attr_accessor :tag_context

    def_delegators :cart_context,       :carts
    def_delegators :discount_context,   :discounts
    def_delegators :mixed_pack_context, :mixed_packs
    def_delegators :product_context,    :products
    def_delegators :tag_context,        :tags

    def initialize
      @cart_context       = CartContext.new(self)
      @discount_context   = DiscountContext.new(self)
      @mixed_pack_context = MixedPackContext.new(self)
      @product_context    = ProductContext.new(self)
      @tag_context        = TagContext.new(self)
    end

    def add(type, object)
      contexts[type].add(object)
    end

  private

    def contexts
      {
        cart:       cart_context,
        discount:   discount_context,
        mixed_pack: mixed_pack_context,
        product:    product_context,
        tag:        tag_context,
      }
    end
  end
end
