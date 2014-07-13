module Checkbot
  class Pack
    class InvalidDiscount < StandardError; end

    attr_accessor :type, :name
    attr_accessor :amount_off, :fixed_price, :percentage_off, :or_more, :shipping
    attr_accessor :packables

    def initialize(type = :discount, name = '', options = {})
      @type = type
      @name = name

      @amount_off     = Money.new(options[:amount_off])          if options.has_key?(:amount_off)
      @fixed_price    = Money.new(options[:fixed_price])         if options.has_key?(:fixed_price)
      @percentage_off = Percentage.new(options[:percentage_off]) if options.has_key?(:percentage_off)

      @or_more        = options.fetch(:or_more)  { false }
      @shipping       = options.fetch(:shipping) { false }

      @packables      = options.fetch(:packables) { [] }

      validate
    end

  protected

    def savings?
      amount_off || fixed_price || percentage_off
    end

    def to_s
      return '' if !savings?

      [].tap { |a|
        a << '+' if or_more
        a << ' -> '
        a << (shipping ? 'Sh' : 'D')
        a << '-'+amount_off.to_s if amount_off
        a << fixed_price.to_s if fixed_price
        a << '-'+percentage_off.to_s if percentage_off
      }.join
    end

  private

    def valid?
      savings.empty? || savings.one?
    end

    def validate
      return if valid?
      message = 'The options contain more than one key '
      message << "{:amount_off => '#{amount_off}', :fixed_price => '#{fixed_price}', :percentage_off => '#{percentage_off}'}"
      raise InvalidDiscount.new(message)
    end

    def savings
      [amount_off, fixed_price, percentage_off].compact
    end
  end
end
