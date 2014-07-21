module Checkbot
  class DiscountContext
    include Contextable

    alias_method :discounts, :contextables

    def add(discount)
      discount.packables.each { |packable| packable.packable = context.add(packable.type, packable.packable) }

      discounts << discount
      discount
    end
  end
end
