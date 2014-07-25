module Checkbot
  class Interpreter

    attr_accessor :tags, :products, :mixed_packs, :discounts
    attr_accessor :cart_items, :tallies, :totals

    def initialize
      @cart_items  = []
      @discounts   = []
      @mixed_packs = []
      @products    = []
      @tags        = []
      @tallies     = []
      @totals      = []
    end

    def interpret(input)
      {
        tags:        TaggableInterpreter,
        products:    ProductInterpreter,
        mixed_packs: MixedPackInterpreter,
        discounts:   DiscountInterpreter,
        cart_items:  CartItemInterpreter,
        tallies:     TallyInterpreter,
        totals:      TotalsInterpreter
      }.each do |key, klass|
        send(key).concat(klass.new(input).attributes)
      end
    end
  end
end
