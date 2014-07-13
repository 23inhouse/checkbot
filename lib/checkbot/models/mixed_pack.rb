module Checkbot
  class MixedPack < Pack
    include Discountable
    include Taggable

    def initialize(name = '', price = nil, options = {})
      options[:fixed_price] = price if price
      super(:mixed_pack, name, options)

      set_discount_codes(options)
      set_tags(options.fetch(:tags, []))
    end

    def price
      fixed_price
    end

    def to_s
      [].tap { |a|
        a << name
        a << '['+packables.collect(&:to_s).join(' & ')+']'
        a << discount_codes if excluded_from_discounts?
        a << tag_names if tags?
      }.join(' ').tap { |s|
        s << super if savings?
      }
    end
  end
end
