require 'spec_helper'

module Checkbot
  describe CartItem do
    describe ".new" do
      subject { CartItem.new(item, 1, options) }

      let(:item) { Product.new('item name')}
      let(:options) do
        {
          price_rrp: 1,
          price_discount: 1,
          price_subtotal: 1,
          shipping_rrp: 1,
          shipping_discount: 1,
          shipping_subtotal: 1,
        }
      end

      it { is_expected.to be_a(CartItem) }

      specify {
        expect(subject.name).to eq('item name')
        expect(subject.price_rrp).to be_a(Money)
        expect(subject.price_rrp).to eq(1)
        expect(subject.price_discount).to be_a(Money)
        expect(subject.price_discount).to eq(1)
        expect(subject.price_subtotal).to be_a(Money)
        expect(subject.price_subtotal).to eq(1)
        expect(subject.shipping_rrp).to be_a(Money)
        expect(subject.shipping_rrp).to eq(1)
        expect(subject.shipping_discount).to be_a(Money)
        expect(subject.shipping_discount).to eq(1)
        expect(subject.shipping_subtotal).to be_a(Money)
        expect(subject.shipping_subtotal).to eq(1)
      }
    end

    describe "#to_s" do
      subject { cart_item.to_s }

      let(:item) { Product.new('item name', 20.5) }
      let(:cart_item) { CartItem.new(item, 2) }
      it { is_expected.to be_a(String) }

      context "when it's basic" do
        let(:cart_item) { CartItem.new(item, 2) }
        it { is_expected.to eq('#2(item name $20.50)') }
      end

      context "when the item is a mixed pack" do
      let(:item) { MixedPack.new('item name', 20.5) }
        it { is_expected.to eq('#2[item name $20.50]') }
      end

      context "when it is has price discounts" do
        let(:options) do
          {
            price_rrp: 41,
            price_subtotal: 35,
          }
        end
        let(:cart_item) { CartItem.new(item, 2, options) }
        it { is_expected.to eq('#2(item name $20.50) -> $41 ($35)') }
      end

      context "when it is has just a price" do
        let(:options) do
          {
            price_rrp: 41,
          }
        end
        let(:cart_item) { CartItem.new(item, 2, options) }
        it { is_expected.to eq('#2(item name $20.50) -> $41') }
      end

      context "when it is has shipping discounts" do
        let(:options) do
          {
            shipping_rrp: 10,
            shipping_subtotal: 0,
          }
        end
        let(:cart_item) { CartItem.new(item, 2, options) }
        it { is_expected.to eq('#2(item name $20.50) sh -> $10 ($0)') }
      end

      context "when it is has just a shipping rate" do
        let(:options) do
          {
            shipping_rrp: 10,
          }
        end
        let(:cart_item) { CartItem.new(item, 2, options) }
        it { is_expected.to eq('#2(item name $20.50) sh -> $10') }
      end

      context "when it is has price and shipping discounts" do
        let(:options) do
          {
            price_rrp: 41,
            price_subtotal: 35,
            shipping_rrp: 10,
            shipping_subtotal: 0,
          }
        end
        let(:cart_item) { CartItem.new(item, 2, options) }
        it { is_expected.to eq('#2(item name $20.50) -> $41 ($35) sh -> $10 ($0)') }
      end

      context "when it is has price and shipping rate" do
        let(:options) do
          {
            price_rrp: 41,
            shipping_rrp: 10,
          }
        end
        let(:cart_item) { CartItem.new(item, 2, options) }
        it { is_expected.to eq('#2(item name $20.50) -> $41 sh -> $10') }
      end
    end
  end
end
