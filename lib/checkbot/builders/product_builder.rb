module Checkbot
  class ProductBuilder
    attr_accessor :product

    def initialize(options)
      name  = options.delete(:name)
      price = options.delete(:price)
      tags  = options.delete(:tags) || []

      options[:tags] = tags.collect { |tag| TagBuilder.new(tag).tag }
      @product = Product.new(name, price, options)
    end
  end
end
