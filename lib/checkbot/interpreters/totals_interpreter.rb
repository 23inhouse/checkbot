module Checkbot
  class TotalsInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              \b(?<type>((?:subtotal|shipping|total)))    # type
              \s*+
              =>                                          # equal sign
              \s*+
              \$ \s*+ (?<money>[\d\.]++)                  # money
              \s*+
            }x

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      key   = match['type']
      value = match['money']

      valid_keys = %W(subtotal shipping total)
      key        = key.to_sym if valid_keys.include?(key)
      value      = value

      { key => value }
    end
  end
end
