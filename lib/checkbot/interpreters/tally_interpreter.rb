module Checkbot
  class TallyInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              (?:(?<shipping>(sh)))?        # shipping optional
              \s*+
              discount\s*+=>                # discount
              \s*+
              -?                            # negative optional
              \s*+
              \$ \s*+ (?<amount>[\d\.]+)    # amount
              \s*+
            }x

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      shipping = match['shipping']
      amount   = match['amount']

      {
        amount: amount,
      }.tap do |h|
        h[:shipping] = true if shipping
      end
    end
  end
end
