require 'bigdecimal'
require 'bigdecimal/util'

module Checkbot
  class Money < BigDecimal
    def initialize(value)
      super(value.to_s)
    end

    def inspect
      "#<Checkbot::Money: #{super} >"
    end

    def to_s(*args)
      return super if !args.empty?

      return "$%.0f" % self if self.to_i == self
      "$%05.2f" % self
    end
  end
end
