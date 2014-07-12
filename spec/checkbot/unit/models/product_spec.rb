require 'spec_helper'

module Checkbot
  describe Product do
    describe ".new" do
      subject { Product.new('product name', 1.111, options) }
      let(:options) do
        {
          tags: [:tag],
          qualify_for_price_discount: false
        }
      end

      it { is_expected.to be_a(Product) }
      it { is_expected.to be_a(Discountable) }
      it { is_expected.to be_a(Taggable) }

      specify {
        expect(subject.name).to eq('product name')
        expect(subject.price).to be_a(Money)
        expect(subject.price).to eq(1.111)
        expect(subject.tags).to eq([:tag])
        expect(subject.qualify_for_price_discount).to be(false)
        expect(subject.receive_price_discount).to be(true)
      }
    end

    describe "#to_s" do
      subject { product.to_s }
      let(:product) { Product.new('product name', 1) }
      it { is_expected.to be_a(String) }

      context "when it's basic" do
        let(:product) { Product.new('product name', 99) }
        it { is_expected.to eq('product name $99') }
      end

      context "when it has tags" do
        let(:tags) { {tags: [Tag.new('tag1'), Tag.new('tag2')]} }
        let(:product) { Product.new('product name', 28.55, tags) }
        it { is_expected.to eq('product name $28.55 { tag1, tag2 }') }
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
        let(:product) { Product.new('product name', 22.1, exclusions) }
        it { is_expected.to eq('product name $22.10 [0011]') }
      end

      context "when it is excluded from discounts and has tags" do
        let(:tags) { {tags: [Tag.new('tag4'), Tag.new('tag9')]} }
        let(:exclusions) { {qualify_for_shipping_discount: false} }
        let(:options) { tags.merge(exclusions) }
        let(:product) { Product.new('product name', 27.5, options) }
        it { is_expected.to eq('product name $27.50 [1101] { tag4, tag9 }') }
      end
    end
  end
end
