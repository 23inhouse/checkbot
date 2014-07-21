module Checkbot
  class CartContext
    include Contextable

    alias_method :carts, :contextables
    alias_method :carts=, :contextables=

    def add(cart)
      cart.items.each { |item| item.item = context.add(item.type, item.item) }

      self.carts << cart
      cart
    end
  end
end
