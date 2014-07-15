module Checkbot
  class Cart
    attr_accessor :items, :tallies
    attr_accessor :shipping, :subtotal, :total

    def initialize(items = [], tallies = [], options = {})
      @items = items
      @tallies = tallies

      @subtotal = Money.new(options[:subtotal]) if options.has_key?(:subtotal)
      @shipping = Money.new(options[:shipping]) if options.has_key?(:shipping)
      @total    = Money.new(options[:total])    if options.has_key?(:total)
    end

    def to_s
      [].tap { |a|
        a << items   if !items.empty?
        a << tallies if !tallies.empty?
        a << 'subtotal => '+subtotal.to_s if subtotal
        a << 'shipping => '+shipping.to_s if shipping
        a << 'total => '+total.to_s       if total
      }.join("\n")
    end
  end
end
