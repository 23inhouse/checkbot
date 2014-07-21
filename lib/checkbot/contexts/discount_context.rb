module Checkbot
  class DiscountContext
    include Contextable

    alias_method :discounts, :contextables

    def add(discount)
      discounts << discount
      discount
    end
  end
end
