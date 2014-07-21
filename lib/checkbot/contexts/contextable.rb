module Checkbot
  module Contextable
    attr_accessor :contextables

    def initialize
      @contextables = []
    end

  private

    def find(name)
      contextables.find { |p| p.name == name }
    end
  end
end
