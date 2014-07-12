module Checkbot
  module Discountable
    attr_accessor :qualify_for_price_discount, :receive_price_discount
    attr_accessor :qualify_for_shipping_discount, :receive_shipping_discount

    def get_discount_codes
      {
        qualify_for_price_discount:    @qualify_for_price_discount,
        receive_price_discount:        @receive_price_discount,
        qualify_for_shipping_discount: @qualify_for_shipping_discount,
        receive_shipping_discount:     @receive_shipping_discount,
      }
    end

    def set_discount_codes(options)
      options ||= {}

      @qualify_for_price_discount    = options.fetch(:qualify_for_price_discount)    { true }
      @receive_price_discount        = options.fetch(:receive_price_discount)        { true }
      @qualify_for_shipping_discount = options.fetch(:qualify_for_shipping_discount) { true }
      @receive_shipping_discount     = options.fetch(:receive_shipping_discount)     { true }
    end

    def discount_codes
      '['+discount_code+']'
    end

    def excluded_from_discounts?
      discount_qualifications.any?(&:!)
    end

  private

    def discount_code
      discount_qualifications.collect { |d| d == true ? '1' : '0' }.join
    end

    def discount_qualifications
      [
        qualify_for_price_discount,
        receive_price_discount,
        qualify_for_shipping_discount,
        receive_shipping_discount
      ]
    end
  end
end
