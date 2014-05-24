class Pack < ActiveRecord::Base
  extend Memoist

  belongs_to :seller
  has_many :packed_products, :dependent => :destroy
  has_many :product_listings, :as => :listable
  has_many :tags, :through => :product_listings

  attr_accessor :full_price, :full_shipping_price

  def all_products?
    packed_products.all?(&:product?) if packed_products.present?
  end

  def amount
    return unless amount_discount?
    packed_products.inject(0.0.to_d) { |sum, packed_product| sum + packed_product.amount }
  end

  def amount_discount?
    packed_products.all?(&:amount?) if packed_products.present?
  end

  def discount_amount_off=(value)
    value = value.to_f.abs if value && value.to_f < 0
    write_attribute(:discount_amount_off, value)
  end

  def discount_amount_off
    return read_attribute(:discount_amount_off) if read_attribute(:discount_amount_off).present?

    return unless full_price
    return (full_price.abs * read_attribute(:discount_percentage_off) * 0.01.to_d).round(4) if read_attribute(:discount_percentage_off).present?
    return (full_price.abs - read_attribute(:discount_price)).round(4) if read_attribute(:discount_price).present?
  end
  # memoize :discount_amount_off

  def discount_percentage_off=(value)
    value = value.to_f.abs if value && value.to_f < 0
    write_attribute(:discount_percentage_off, value)
  end

  def discount_percentage_off
    return read_attribute(:discount_percentage_off) if read_attribute(:discount_percentage_off).present?

    return unless full_price
    return 0.0 if full_price == 0
    return (100 * read_attribute(:discount_amount_off) / full_price).round(4) if read_attribute(:discount_amount_off).present?
    return (100 * (full_price - read_attribute(:discount_price)) / full_price).round(4) if read_attribute(:discount_price).present? && full_price
  end
  # memoize :discount_percentage_off

  def discount_price
    return read_attribute(:discount_price) if read_attribute(:discount_price).present?

    return unless full_price
    return (full_price.abs - read_attribute(:discount_amount_off)).round(4) if read_attribute(:discount_amount_off).present?
    return (full_price.abs * (100 - read_attribute(:discount_percentage_off)) * 0.01.to_d).round(4) if read_attribute(:discount_percentage_off).present?
  end
  # memoize :discount_price

  def first_product
    packed_products.first || PackedProduct.new
  end

  def free_shipping_discount?
    read_attribute(:shipping_price) == 0 || read_attribute(:shipping_percentage_off) == 100
  end

  def full_name
    name
  end

  def full_price
    return @full_price if @full_price.present?
    return amount if amount.present? && amount_discount?
    # return amount if !or_more && amount_discount?
    packed_products.inject(0.0.to_d) { |sum, pp| sum + pp.quantity.to_i * pp.price } if all_products?
  end

  def price
    discount_price || full_price
  end

  def price_discount?
    read_attribute(:discount_amount_off).present? ||
    read_attribute(:discount_percentage_off).present? ||
    read_attribute(:discount_price).present?
  end
  # memoize :price_discount?

  def priceish_discount?
    price_discount? || !shipping_discount?
  end

  def quantity
    packed_products.inject(0) { |sum, mp|
      q = mp.packable.is_a?(Pack) ? mp.packable.quantity.to_i : 1
      sum + (q * mp.quantity.to_i)
    }
  end

  def quantity_discount?
    packed_products.all?(&:quantity?) if packed_products.present?
  end

  def shipping_amount_off=(value)
    value = value.to_f.abs if value && value.to_f < 0
    write_attribute(:shipping_amount_off, value)
  end

  def shipping_amount_off
    return read_attribute(:shipping_amount_off) if read_attribute(:shipping_amount_off).present?

    return unless full_shipping_price
    # return full_shipping_price * read_attribute(:shipping_percentage_off) * 0.01.to_d if read_attribute(:shipping_percentage_off).present?
    # return full_shipping_price - read_attribute(:shipping_price) if read_attribute(:shipping_price).present?
  end
  # memoize :shipping_amount_off

  def shipping_discount?
    read_attribute(:shipping_amount_off).present? ||
    read_attribute(:shipping_percentage_off).present? ||
    read_attribute(:shipping_price).present?
  end
  memoize :shipping_discount?

  def shippingish_discount?
    shipping_discount? || !price_discount?
  end

  def shipping_percentage_off=(value)
    value = value.to_f.abs if value && value.to_f < 0
    write_attribute(:shipping_percentage_off, value)
  end

  def shipping_percentage_off
    return read_attribute(:shipping_percentage_off) if read_attribute(:shipping_percentage_off).present?

    # return unless full_shipping_price
    # return 100 * read_attribute(:shipping_amount_off) / full_shipping_price if read_attribute(:shipping_amount_off).present?
    # return 100 * (full_shipping_price - read_attribute(:shipping_price)) / full_shipping_price if read_attribute(:shipping_price).present? && full_shipping_price
  end
  # memoize :shipping_percentage_off

  def shipping_price
    return read_attribute(:shipping_price) if read_attribute(:shipping_price).present?

    return unless full_shipping_price
    # return full_shipping_price - read_attribute(:shipping_amount_off) if read_attribute(:shipping_amount_off).present?
    # return full_shipping_price * (100 - read_attribute(:shipping_percentage_off)) * 0.01.to_d if read_attribute(:shipping_percentage_off).present?

    # return full_shipping_price.round(9)
  end
  # memoize :shipping_price

  def specific_mixed_pack?
    type == 'MixedPack'
  end
end
