module Checkbot
  class ProductInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              (?<name>([^\#\$\=\-\+\[\]\(\)\<\>]){3,})        # name
              \s++
              #{MoneyInterpreter.regex('price').source}       # price
              \s*+
              (?:#{DiscountableInterpreter.regex.source})?    # codes optional
              \s*+
              (?:#{TaggableInterpreter.regex.source})?        # tags  optional
              \s*+
            }xo

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      name  = match['name'].strip
      price = match['price']
      codes = match['discountable'].to_s
      tags  = match['tags'].to_s

      return if name == ''

      codes = DiscountableInterpreter.new('['+codes+']').attributes
      tags  = TaggableInterpreter.new('{'+tags+'}').attributes

      {
        name: name,
        price: price,
      }.tap do |h|
        h[:tags] = tags       if !tags.empty?
        h.merge!(codes.first) if !codes.empty?
      end
    end
  end
end
