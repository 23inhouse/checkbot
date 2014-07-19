module Checkbot
  class CartItemBuilder
    attr_accessor :cart_item

    ITEM_CLASSES =  {
                      mixed_pack: MixedPack,
                      product:    Product,
                    }

    def initialize(options)
      item_type  = options.delete(:item_type)
      item_name  = options.delete(:item_name)
      item_price = options.delete(:item_price)
      item       = ITEM_CLASSES[item_type].new(item_name, item_price)

      quantity   = options.delete(:quantity)
      @cart_item = CartItem.new(item, quantity, options)
    end
  end
end
