require 'spec_helper'

module Checkbot
  describe Discount do
    describe ".new" do
      subject { Discount.new(options) }
      let(:options) { {} }

      it { is_expected.to be_a(Discount) }
      it { is_expected.to be_a(Pack) }

      specify {
        expect(subject.conditions).to eq([])
        expect(subject.rewards).to eq([])
      }
    end

    describe "#to_s" do
      subject { mixed_pack.to_s }
      let(:mixed_pack) { Discount.new(options) }
      it { is_expected.to be_a(String) }

      let(:product1) { Product.new('product 1', 15) }
      let(:product2) { Product.new('product 2', 9.99) }
      let(:packables) do
        [
          Packable.new(product1, {quantity: 2}),
          Packable.new(product2, {quantity: 1})
        ]
      end
      let(:options) { { packables: packables } }

      context "when it's basic" do
        let(:mixed_pack) { Discount.new(options) }
        it { is_expected.to eq('#2P(product 1) & #1P(product 2)') }
      end

      context "when it has a name" do
        let(:options) do
          { name: 'discount name', packables: packables }
        end
        let(:mixed_pack) { Discount.new(options) }
        it { is_expected.to eq('discount name #2P(product 1) & #1P(product 2)') }
      end

      context "when it has savings" do
        let(:options) do
          { packables: packables, amount_off: 20 }
        end
        let(:mixed_pack) { Discount.new(options) }
        it { is_expected.to eq('#2P(product 1) & #1P(product 2) -> D-$20') }
      end
    end
  end
end
