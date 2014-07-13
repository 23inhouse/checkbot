module Checkbot
  class Packable
    extend Forwardable

    attr_accessor :packable, :amount, :quantity

    def_delegators :packable, :name

    def initialize(packable, options = {})
      @packable = packable

      @amount   = Money.new(options[:amount]) if options.has_key?(:amount)
      @quantity = options[:quantity].to_i     if options.has_key?(:quantity)
    end

    def amount?
      !amount.nil?
    end

    def mixed_pack?
      packable.is_a?(MixedPack)
    end

    def product?
      packable.is_a?(Product)
    end

    def quantity?
      !quantity.nil?
    end

    def tag?
      packable.is_a?(Tag)
    end

    def to_s
      [].tap { |a|
        a << amount.to_s if amount?
        a << '#'+quantity.to_s if quantity?
        a << 'M' if mixed_pack?
        a << 'P' if product?
        a << 'T' if tag?
        a << '('+name+')'
      }.join
    end
  end
end
