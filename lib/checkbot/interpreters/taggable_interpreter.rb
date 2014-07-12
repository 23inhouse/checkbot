module Checkbot
  class TaggableInterpreter
    include Interpretable

    REGEX = /\{\s*+(?<tags>((?!\s*+\}).)+)\s*+(?:\})/

    def self.regex
      REGEX
    end

  private

    def build_hash(match)
      tag_names = match['tags']
      tag_names.split(/\s*+,\s*+/).collect { |name| { name: name } }
    end
  end
end
