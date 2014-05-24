class Cart < ActiveRecord::Base
  extend Memoist

  belongs_to :seller
  belongs_to :account
  has_many :discount_tallies
  has_many :items
  has_many :winelists, :through => :items
  has_one :order

  include ActionView::Helpers::TextHelper

  attr_accessor :messages, :postcode_error

  delegate :minimum_bottles_per_order, :to => :seller

  def number_of_bottles
    items.inject(0) do |sum, item|
      q = item.purchasable.is_a?(MixedPack) ? item.purchasable.quantity.to_i : 1
      sum + (item.quantity.to_i * q)
    end
  end
  memoize :number_of_bottles

  def scd_charges
    read_attribute(:scd_charges) || 0.0.to_d
  end

  def scd_charges=(value)
    true
  end

  def transaction_charge
    0
  end

  def transaction_charge=(value)
    true
  end

  def complete_cart?
    shipping_charges.present? && total.present?
  end
end
