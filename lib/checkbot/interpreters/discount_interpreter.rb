module Checkbot
  class DiscountInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              (?<packables>(?:\#|\$)++ \s*+ \d++ \s*+ [MPT] \s*+ \( (?!\)\s*\&).+ \))   # packables
              \s*+
              #{SavingsInterpreter.regex.source}                                        # savings
              \s*+
            }xo

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      packables = match['packables'].to_s

      packables = PackableInterpreter.new(packables).attributes
      savings   = SavingsInterpreter.new(match[0]).attributes

      {
        packables: packables,
      }.tap do |h|
        h.merge!(savings.first) if !savings.empty?
      end
    end
  end
end
