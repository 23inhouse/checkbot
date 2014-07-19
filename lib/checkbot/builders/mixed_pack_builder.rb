module Checkbot
  class MixedPackBuilder
    attr_accessor :mixed_pack

    def initialize(options)
      name      = options.delete(:name)
      price     = options.delete(:price)

      packables = options.delete(:packables)
      packables = packables.collect { |p| PackableBuilder.new(p).packable }

      tags      = options.delete(:tags) || []
      tags      = tags.collect { |t| Tag.new(t[:name]) }

      options[:packables] = packables
      options[:tags]      = tags if !tags.empty?
      @mixed_pack = MixedPack.new(name, price, options)
    end
  end
end
