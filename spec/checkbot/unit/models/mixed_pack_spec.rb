require 'spec_helper'

module Checkbot
  describe MixedPack do
    describe ".new" do
      subject { MixedPack.new('mixed pack name', nil, options) }
      let(:options) do
        {
          tags: [:tag],
          qualify_for_price_discount: false
        }
      end

      it { is_expected.to be_a(MixedPack) }
      it { is_expected.to be_a(Pack) }
      it { is_expected.to be_a(Discountable) }
      it { is_expected.to be_a(Taggable) }

      specify {
        expect(subject.name).to eq('mixed pack name')
        expect(subject.tags).to eq([:tag])
        expect(subject.qualify_for_price_discount).to be(false)
        expect(subject.receive_price_discount).to be(true)
      }

      context "when the price is set" do
        subject { MixedPack.new('mixed pack name', 20) }
        specify {
          expect(subject.price).to eq(20)
          expect(subject.fixed_price).to eq(20)
        }
      end
    end

    describe "#to_s" do
      subject { mixed_pack.to_s }
      let(:mixed_pack) { MixedPack.new('mixed pack name', nil, options) }
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
        let(:mixed_pack) { MixedPack.new('mixed pack name', nil, options) }
        it { is_expected.to eq('mixed pack name [#2P(product 1) & #1P(product 2)]') }
      end

      context "when it has savings" do
        let(:options) do
          { packables: packables, amount_off: 20 }
        end
        let(:mixed_pack) { MixedPack.new('mixed pack name', nil, options) }
        it { is_expected.to eq('mixed pack name [#2P(product 1) & #1P(product 2)] -> D-$20') }
      end

      context "when it has a price" do
        let(:mixed_pack) { MixedPack.new('mixed pack name', 20, options) }
        it { is_expected.to eq('mixed pack name [#2P(product 1) & #1P(product 2)] -> D$20') }
      end

      context "when it has tags" do
        let(:tags) { {tags: [Tag.new('tag1'), Tag.new('tag2')]} }
        let(:options) do
          { packables: packables }
            .merge(tags)
        end
        it { is_expected.to eq('mixed pack name [#2P(product 1) & #1P(product 2)] { tag1, tag2 }') }
      end

      context "when it is excluded from price discounts" do
        let(:exclusions) do
          {
            qualify_for_price_discount: false,
            receive_price_discount: false,
            qualify_for_shipping_discount: true,
            receive_shipping_discount: true
          }
        end
        let(:options) do
          { packables: packables }
            .merge(exclusions)
        end
        it { is_expected.to eq('mixed pack name [#2P(product 1) & #1P(product 2)] [0011]') }
      end

      context "when it is excluded from discounts and has tags" do
        let(:tags) { {tags: [Tag.new('tag4'), Tag.new('tag9')]} }
        let(:exclusions) { {qualify_for_shipping_discount: false} }
        let(:options) do
          { packables: packables }
            .merge(tags)
            .merge(exclusions)
        end
        it { is_expected.to eq('mixed pack name [#2P(product 1) & #1P(product 2)] [1101] { tag4, tag9 }') }
      end
    end
  end
end
