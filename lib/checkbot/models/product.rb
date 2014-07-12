module Checkbot
  class Product
    include Discountable
    include Taggable

    attr_accessor :name, :price

    def initialize(name, price = nil, options = {})
      @name  = name.to_s
      @price = Money.new(price)

      set_discount_codes(options)
      set_tags(options.fetch(:tags, []))
    end

    def to_s
      [].tap { |a|
        a << name
        a << price
        a << discount_codes if excluded_from_discounts?
        a << tag_names if tags?
      }.join(' ')
    end
  end
end
