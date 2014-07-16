module Checkbot
  module Interpretable
    attr_accessor :attributes, :input, :matches

    def initialize(input)
      @input = input.to_s

      @attributes = []
      @matches    = []

      interpret
    end

    def self.regex
      /\s*+(?<anything>((.*)))\s*+/
    end

  private

    def store(match)
      matches << match.to_s
      attributes << build_hash(match)
    end

    def build_hash(match)
      anything = match['anything']
      { anything: anything }
    end

    def interpret
      input.to_enum(:scan, regex).each do
        match = Regexp.last_match
        store(match)
      end
      attributes.flatten!
      attributes.compact!
    end

    def regex
      self.class.regex
    end
  end
end
