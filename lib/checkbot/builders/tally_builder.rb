module Checkbot
  class TallyBuilder
    attr_accessor :tally

    def initialize(options)
      amount = options.delete(:amount)
      @tally = Tally.new(amount, options)
    end
  end
end
