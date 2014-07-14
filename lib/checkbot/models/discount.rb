module Checkbot
  class Discount < Pack
    attr_accessor :conditions, :rewards

    def initialize(options = {})
      name = options.delete(:name)
      super(:discount, name , options)

      @conditions = []
      @rewards    = []
    end

    def to_s
      [].tap { |a|
        a << name+' ' if name
        a << packables.collect(&:to_s).join(' & ')
        a << super if savings?
      }.join
    end
  end
end

