module Checkbot
  class DiscountableInterpreter
    include Interpretable

    REGEX = /\[(?<discountable>[^\]]+)\]/

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      excludes = match[:discountable].gsub(/[^\d]/, '').split('')
      {
        qualify_for_price_discount:    (excludes[0] != '0'),
        receive_price_discount:        (excludes[1] != '0'),
        qualify_for_shipping_discount: (excludes[2] != '0'),
        receive_shipping_discount:     (excludes[3] != '0'),
      }
    end
  end
end
