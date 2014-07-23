module Checkbot
  class TagBuilder
    attr_accessor :tag

    def initialize(options)
      name = options.delete(:name)

      @tag = Tag.new(name)
    end
  end
end
