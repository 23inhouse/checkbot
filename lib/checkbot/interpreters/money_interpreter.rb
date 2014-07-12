module Checkbot
  class MoneyInterpreter
    include Interpretable

    def self.regex(name = 'money')
      /\$\s*+(?<#{name}>[\d\.]+)/
    end

  private

    def build_hash(match)
      amount = match['money']
      {money: Money.new(amount)}
    end

    def regex(name = 'money')
      self.class.regex(name)
    end
  end
end
