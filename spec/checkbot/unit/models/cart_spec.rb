require 'spec_helper'

module Checkbot
  describe Cart do
    describe ".new" do
      subject { Cart.new(items, tallies, options) }

      let(:product) { Product.new('product name', 20)}
      let(:mixed_pack) { MixedPack.new('mixed pack name', 100)}
      let(:items) { [ CartItem.new(product, 2), CartItem.new(mixed_pack, 2) ] }
      let(:tallies) { [] }
      let(:options) do
        {
          subtotal: 65,
          shipping: 88,
          total:    100,
        }
      end

      it { is_expected.to be_a(Cart) }

      specify {
        expect(subject.items.size).to eq(2)
        expect(subject.subtotal).to be_a(Money)
        expect(subject.subtotal).to eq(65)
        expect(subject.shipping).to be_a(Money)
        expect(subject.shipping).to eq(88)
        expect(subject.total).to be_a(Money)
        expect(subject.total).to eq(100)
      }
    end

    describe "#to_s" do
      subject { cart.to_s }

      let(:cart) { Cart.new(items, tallies, options) }
      let(:product) { Product.new('product name', 20)}
      let(:mixed_pack) { MixedPack.new('mixed pack name', 100)}
      let(:items) { [ CartItem.new(product, 2), CartItem.new(mixed_pack, 2) ] }
      let(:tallies) { [] }
      let(:options) do
        {
          subtotal: 65,
          shipping: 88,
          total:    100,
        }
      end

      it { is_expected.to be_a(String) }
      it { is_expected.to eq("#2(product name $20)\n#2[mixed pack name $100]\nsubtotal => $65\nshipping => $88\ntotal => $100") }
    end
  end
end
