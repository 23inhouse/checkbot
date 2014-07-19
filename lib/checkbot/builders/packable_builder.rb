module Checkbot
  class PackableBuilder
    attr_accessor :packable

    PACKABLE_CLASSES =  {
                          :mixed_pack => MixedPack,
                          :product    => Product,
                          :tag        => Tag,
                        }

    def initialize(options)
      type  = options.delete(:type)
      name  = options.delete(:name)

      packable = PACKABLE_CLASSES[type].new(name)
      @packable = Packable.new(packable, options)
    end
  end
end
