module Checkbot
  class SavingsInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              (?:(?<or_more>\+))?                                         # or more
              \s*+
              ->                                                          # start savings
              \s*+
              (?<shipping>(?:Sh|D))                                       # shipping
              \s*+
              (?:
                #{MoneyInterpreter.regex('fixed_price').source}           # fixed price
              |
                -                                                         # negative
                \s*+
                #{MoneyInterpreter.regex('amount_off').source}            # amount off
              |
                -                                                         # negative
                \s*+
                #{PercentageInterpreter.regex('percentage_off').source}   # percentage off
              )
              \s*+
            }xo

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      amount_off     = match['amount_off']
      fixed_price    = match['fixed_price']
      percentage_off = match['percentage_off']
      or_more        = match['or_more'].to_s == '+'
      shipping       = match['shipping'].to_s == 'Sh'

      {
        shipping: shipping,
        or_more: or_more,
      }.tap do |h|
        h[:amount_off]     = amount_off     if amount_off
        h[:fixed_price]    = fixed_price    if fixed_price
        h[:percentage_off] = percentage_off if percentage_off
      end
    end
  end
end
