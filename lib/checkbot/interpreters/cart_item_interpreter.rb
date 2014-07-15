module Checkbot
  class CartItemInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              \# \s*+ (?<quantity>[\d]++)                                 # quantity
              \s*+
              (?<item_type>(?:\(|\[)++)                                   # item type
              \s*+
              (?<item_name>((?!\s*+(?:\)|\$)).)+)                         # item name
              \s*+
              (?:#{MoneyInterpreter.regex('item_price').source})?         # item price optional
              \s*+
              (?:\)|\])++
              \s*+
              (?:                                                         # optional
                ->                                                        # price totals
                \s*+
                #{MoneyInterpreter.regex('price_rrp').source}             # rrp
                \s*+
                (?:                                                       # optional
                  \(
                  \s*+
                  #{MoneyInterpreter.regex('price_subtotal').source}      # subtotal
                  \s*+
                  \)
                )?
              )?
              \s*+
              (?:                                                         # optional
                sh \s*+ ->                                                # shipping totals
                \s*+
                #{MoneyInterpreter.regex('shipping_rrp').source}          # rrp
                \s*+
                (?:                                                       # optional
                  \(
                  \s*+
                  #{MoneyInterpreter.regex('shipping_subtotal').source}   # subtotal
                  \s*+
                  \)
                )?
              )?
              \s*+
            }xo

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      quantity   = match['quantity'].to_i

      item_type  = match['item_type'].to_s
      item_name  = match['item_name'].to_s
      item_price = match['item_price']

      item_type = (item_type == '[' ? :mixed_pack : :product)

      price_rrp         = match['price_rrp']
      price_subtotal    = match['price_subtotal']
      shipping_rrp      = match['shipping_rrp']
      shipping_subtotal = match['shipping_subtotal']

      {
        quantity:   quantity,
        item_type:  item_type,
        item_name:  item_name,
        item_price: item_price,
      }.tap { |h|
        h[:price_rrp]         = price_rrp         if price_rrp
        h[:price_subtotal]    = price_subtotal    if price_subtotal
        h[:shipping_rrp]      = shipping_rrp      if shipping_rrp
        h[:shipping_subtotal] = shipping_subtotal if shipping_subtotal
      }
    end
  end
end
