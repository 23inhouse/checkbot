class DiscountDecorator
  include NumberHelper
  attr_accessor :discount, :product

  def initialize(discount)
    return if discount.nil?
    @discount = discount
  end

  delegate :first_product, :to => :discount, :allow_nil => true
  delegate :full_name, :wine?, :tag?, :to => :first_product, :allow_nil => true
  delegate :amount, :amount?, :quantity, :quantity?, :to => :first_product, :allow_nil => true

  delegate :or_more?, :shipping_discount?, :free_shipping_discount?, :to => :discount, :allow_nil => true
  delegate :amount_discount?, :to => :discount, :allow_nil => true

  delegate :discount_amount_off, :discount_amount_off?, :to => :discount, :allow_nil => true
  delegate :discount_percentage_off, :discount_percentage_off?, :to => :discount, :allow_nil => true
  delegate :discount_price, :discount_price?, :to => :discount, :allow_nil => true
  delegate :shipping_amount_off, :shipping_amount_off?, :to => :discount, :allow_nil => true
  delegate :shipping_percentage_off, :shipping_percentage_off?, :to => :discount, :allow_nil => true
  delegate :shipping_price, :shipping_price?, :to => :discount, :allow_nil => true
  delegate :quantity_discount?, :price_discount?, :to => :discount, :allow_nil => true

  def amount_off_component
    return 'free' if free_shipping_discount?
    return number_to_money(shipping_amount_off) if shipping_amount_off?
    return number_to_money(discount_amount_off) if discount_amount_off?
  end

  def default_buy_component
    [amount_or_quantity_component, or_more_component].compact.join(' ')
  end

  def default_discount_component
    wrapped_discount_component(:amount_off_component) ||
    wrapped_discount_component(:price_component) ||
    wrapped_discount_component(:percentage_off_component)
  end

  def default_item_component
    ['of', the_or_any, full_name].join(' ')
  end

  def data_name
    [default_discount_component, default_buy_component, default_item_component].compact.join(' ')
  end

  def default_name
    buy_component = default_buy_component
    item_component = default_item_component

    if quantity? && quantity == 1
      buy_component = nil
      item_component = "any #{full_name}"
    end

    [default_discount_component, buy_component, item_component].compact.join(' ')
  end

  def google_name(wine = nil)
    self.product = wine if wine.present?
    [wrapped_unit_price_component || default_discount_component, default_buy_component, default_item_component].compact.join(' ')
  end

  def google_short_name(wine = nil)
    self.product = wine if wine.present?
    # [unit_price_component, amount_or_quantity_component, or_more_component, save_component].compact.join(' ')
    [wrapped_unit_price_component || default_discount_component, amount_or_quantity_component, or_more_component].compact.join(' ')
  end

  def log
    disc_str = shipping_discount? ? 'Sh' : ' D'
    disc_str << ' $' + number_with_precision(discount.fixed_price, :precision => 4, :strip_insignificant_zeros => true) if discount.read_attribute(:discount_price).present? || discount.read_attribute(:shipping_price).present?
    disc_str << '-$' + number_with_precision(discount.amount_off, :precision => 4, :strip_insignificant_zeros => true) if discount.read_attribute(:discount_amount_off).present? || discount.read_attribute(:shipping_amount_off).present?
    disc_str << '-' + number_with_precision(discount.percentage_off, :precision => 4, :strip_insignificant_zeros => true) + '%' if discount.read_attribute(:discount_percentage_off).present? || discount.read_attribute(:shipping_percentage_off).present?
    disc_str << ' '
    [
      disc_str.ljust(6),
      amount_discount? ? '$' + number_with_precision(amount, :precision => 4, :strip_insignificant_zeros => true) : '#' + first_product.quantity.to_s,
      first_product.packable.is_a?(Tag) ? 'T' : 'P',
      '(' + first_product.anchor + ')',
      or_more? ? '+': ''
    ].join
  end

  def name_for_customer(wine = nil)
    self.product = wine if wine.present?
    return name_for_customer_price if price_discount?
    return name_for_customer_shipping if shipping_discount?
  end

  def notation
    disc_str = shipping_discount? ? 'Sh' : 'D'
    disc_str << '$' + number_with_precision(discount.fixed_price, :precision => 4, :strip_insignificant_zeros => true) if discount.read_attribute(:discount_price).present? || discount.read_attribute(:shipping_price).present?
    disc_str << '-$' + number_with_precision(discount.amount_off, :precision => 4, :strip_insignificant_zeros => true) if discount.read_attribute(:discount_amount_off).present? || discount.read_attribute(:shipping_amount_off).present?
    disc_str << '-' + number_with_precision(discount.percentage_off, :precision => 4, :strip_insignificant_zeros => true) + '%' if discount.read_attribute(:discount_percentage_off).present? || discount.read_attribute(:shipping_percentage_off).present?
    [
      amount_discount? ? '$' + number_with_precision(amount, :precision => 4, :strip_insignificant_zeros => true) : '#' + first_product.quantity.to_s,
      first_product.packable.is_a?(Tag) ? 'T' : 'P',
      '(' + (first_product.anchor || '') + ')',
      or_more? ? '+': '',
      ' => ',
      disc_str
    ].join
  end

  def percentage_off_component
    return 'free' if free_shipping_discount?
    return number_to_percentage(shipping_percentage_off, :precision => 0) if shipping_percentage_off?
    return number_to_percentage(discount_percentage_off, :precision => 0) if discount_percentage_off?
  end

  def price_component
    return 'free' if free_shipping_discount?
    return number_to_money(shipping_price) if shipping_price?
    return number_to_money(discount_price) if discount_price?
  end

  def save_component
    return if !unit_discount_amount_off!.present?
    '(' + ['save', unit_discount_amount_off_component!, 'per bottle'].compact.join(' ') + ')'
  end

  def unit_price_component(wine = nil)
    self.product = wine if wine.present?
    unit_price_component!
  end

  def unit_shipping_discount_component
    return if !shipping_discount?

    return 'free shipping for' if free_shipping_discount?
  end

private

  def amount_or_quantity_component
    return quantity if quantity.present?
    return number_to_money(amount) if amount.present?
  end

  def buy_or_spend_component
    amount? ? 'spend' : 'buy'
  end

  def computed_quantity
    return quantity if quantity_discount?
    return amount / price if amount_discount? && price.present?
  end

  def discount_amount_off!
    return if !price_discount?

    full_price!
    discount_amount_off
  end

  def discount_price!
    return if !price_discount?
    return if !full_price!

    discount_price
  end

  def discount_price_component!
    full_price!
    discount_price_component
  end

  def discount_price_component
    return if !price_discount?

    number_to_money(discount_price) if discount_price
  end

  def discounted_shipping
    return if !shipping_discount?

    case
    when shipping_price.present?
      number_to_money(shipping_price)
    when shipping_amount_off.present?
      number_to_money(shipping_amount_off) + ' off'
    when shipping_percentage_off.present?
      number_to_percentage(shipping_percentage_off, :precision => 0) + ' off'
    end
  end

  def full_price!
    return discount.full_price = price * quantity if quantity_discount? && price.present?
    return discount.full_price = amount if amount_discount?
  end

  def name_for_customer_price
    [default_buy_component, 'for', discount_price_component!].compact.join(' ')
  end

  def name_for_customer_shipping
    [discounted_shipping, 'shipping', 'when you', buy_or_spend_component, default_buy_component].compact.join(' ')
  end

  def or_more_component
    'or more' if or_more?
  end

  def price
    self.product ||= first_product.packable if first_product.packable.is_a?(Wine)
    product.price if product.present?
  end

  def shipping_price!
    return if !shipping_discount?
    return if !full_price!

    shipping_price
  end

  def the_or_any
    tag? ? 'any' : 'the'
  end

  def unit_discount_amount_off!
    return if !discount_amount_off!
    discount_amount_off! / computed_quantity
  end

  def unit_discount_amount_off_component!
    return if !unit_discount_amount_off!
    number_to_money(discount_amount_off / computed_quantity)
  end

  def unit_discount_price!
    return if !discount_price! || !computed_quantity
    discount_price! / computed_quantity
  end

  def unit_price_component!
    return if !unit_discount_price! && !unit_shipping_price!
    number_to_money((discount_price! || shipping_price!) / computed_quantity)
  end

  def unit_shipping_price!
    return if !shipping_price! || !computed_quantity
    shipping_price! / computed_quantity
  end

  def wrapped_discount_component(component)
    component = send(component) if component.is_a?(Symbol)
    if component.present?
      return "free shipping for" if free_shipping_discount?

      off_component = 'off' if !discount_price? && !shipping_price?
      shipping_component = 'shipping' if shipping_discount?
      for_component = 'for' if discount_price? || shipping_discount?
      return [component, off_component, shipping_component, for_component].compact.join(' ')
    end
  end

  def wrapped_unit_price_component(wine = nil)
    self.product = wine if wine.present?
    return if unit_price_component!.blank?

    "#{unit_price_component!} each for" if price_discount?
  end
end
