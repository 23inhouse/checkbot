module Checkbot
  class DiscountBuilder
    attr_accessor :discount

    def initialize(options)
      packables = options.delete(:packables)
      packables = packables.collect { |p| PackableBuilder.new(p).packable }

      options[:packables] = packables
      @discount = Discount.new(options)
    end
  end
end
