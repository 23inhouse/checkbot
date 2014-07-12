require 'spec_helper'

module Checkbot
  describe Discountable do
    before(:all) {
      class Code
        include Discountable
        def initialize(options = {})
          set_discount_codes(options)
        end
      end
    }
    let(:discount_code) { Code.new(options) }
    let(:options) { nil }

    describe "#discount_codes" do
      subject { discount_code.discount_codes }
      it { is_expected.to be_a(String) }
      it { is_expected.to eq('[1111]') }

      context "when it is excluded from price discounts" do
        let(:options) do
          {
            qualify_for_price_discount: false,
            receive_price_discount: false,
            qualify_for_shipping_discount: true,
            receive_shipping_discount: true
          }
        end

        it { is_expected.to eq('[0011]') }
      end

      context "when it is excluded from shipping discounts" do
        let(:options) do
          {
            qualify_for_price_discount: true,
            receive_price_discount: true,
            qualify_for_shipping_discount: false,
            receive_shipping_discount: false
          }
        end

        it { is_expected.to eq('[1100]') }
      end

      context "when it is excluded from counting towards discounts but still receives them" do
        let(:options) do
          {
            qualify_for_price_discount: false,
            receive_price_discount: true,
            qualify_for_shipping_discount: false,
            receive_shipping_discount: true
          }
        end

        it { is_expected.to eq('[0101]') }
      end

      context "when it is excluded from receiving discounts but still counts towards them" do
        let(:options) do
          {
            qualify_for_price_discount: true,
            receive_price_discount: false,
            qualify_for_shipping_discount: true,
            receive_shipping_discount: false
          }
        end

        it { is_expected.to eq('[1010]') }
      end
    end
  end
end
