module Checkbot
  class PackableInterpreter
    include Interpretable

    REGEX = %r{
              \s*+
              (?<units>(?:\#|\$)++)   # units
              \s*+
              (?<unit>[\d\.]++)       # unit
              \s*+
              (?<type>(?:P|T|M)++)    # type
              \s*+
              \(
                \s*+
                (?<name>[^\)]+)       # name
                \s*+
              \)
              \s*+
            }x

    TYPES = {
              'M' => :mixed_pack,
              'P' => :product,
              'T' => :tag,
            }

    UNITS = {
              '#' => :quantity,
              '$' => :amount,
            }

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      units = match['units'].to_s
      unit  = match['unit'].to_s
      type  = match['type'].to_s
      name  = match['name'].to_s.strip

      {
        UNITS[units] => unit,
        type:  TYPES[type],
        name:  name,
      }
    end
  end
end
