module Checkbot
  class Tally
    attr_accessor :amount, :shipping

    def initialize(amount, options = {})
      @amount   = Money.new(amount)
      @shipping = options.has_key?(:shipping) ? options[:shipping] : false
    end

    def to_s
      [].tap { |a|
        a << 'sh' if shipping
        a << 'discount'
        a << '=>'
        a << amount.to_s
      }.join(' ')
    end
  end
end
