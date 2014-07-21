module Checkbot
  module Contextable
    attr_accessor :context, :contextables

    def initialize(context = Context.new)
      @context      = context
      @contextables = []
    end

  private

    def find(name)
      contextables.find { |p| p.name == name }
    end
  end
end
