module Checkbot
  class PercentageInterpreter
    include Interpretable

    def self.regex(name = 'percentage')
      /(?<#{name}>[\d\.]+)\s*+\%/
    end

  private

    def build_hash(match)
      amount = match['percentage']
      {percentage: Percentage.new(amount)}
    end

    def regex(name = 'percentage')
      self.class.regex(name)
    end
  end
end
