module Checkbot
  class MixedPackInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              (?:(?<name>.+?))?                               # name optional
              \s*+
              \[ \s*+ (?<packables>([^\]]+)) \s*+ \]          # packables
              \s*+
              (?:#{DiscountableInterpreter.regex.source})?    # codes
              \s*+
              (?:#{TaggableInterpreter.regex.source})?        # tags
              \s*+
              (?:#{SavingsInterpreter.regex.source})?         # savings
              \s*+
            }xo

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      name      = match['name'].to_s
      packables = match['packables'].to_s
      codes     = match['discountable'].to_s
      tags      = match['tags'].to_s

      return if packables == ''

      packables = PackableInterpreter.new(packables).attributes
      codes     = DiscountableInterpreter.new('['+codes+']').attributes
      tags      = TaggableInterpreter.new('{'+tags+'}').attributes
      savings   = SavingsInterpreter.new(match.to_s).attributes

      return if packables.empty?

      {
        name: name,
        packables: packables,
      }.tap do |h|
        h[:tags] = tags         if !tags.empty?
        h.merge!(codes.first)   if !codes.empty?
        h.merge!(savings.first) if !savings.empty?
      end
    end
  end
end
