require 'spec_helper'

module Checkbot
  describe Context do
    let(:context) { Context.new }

    describe "#add" do
      subject { context.add(type, input) }

      context "when the input is a cart" do
        let(:type) { :cart }
        let(:input) { Cart.new }
        it { is_expected.to be(input) }
      end

      context "when the input is a discount" do
        let(:type) { :discount }
        let(:input) { Discount.new }
        it { is_expected.to be(input) }
      end

      context "when the input is a mixed pack" do
        let(:type) { :mixed_pack }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to be(input) }
      end

      context "when the input is a product" do
        let(:type) { :product }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to be(input) }
      end

      context "when the input is a tag" do
        let(:type) { :tag }
        let(:input) { Tag.new('name') }
        it { is_expected.to be(input) }
      end
    end

    describe "#carts" do
      subject { context.carts }

      before { context.add(type, input)}

      context "when the input is a cart" do
        let(:type) { :cart }
        let(:input) { Cart.new }
        it { is_expected.to eq([input]) }
      end
    end

    describe "#mixed_packs" do
      subject { context.mixed_packs }

      before { context.add(type, input)}

      context "when the input is a mixed pack" do
        let(:type) { :mixed_pack }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to eq([input]) }
      end
    end

    describe "#products" do
      subject { context.products }

      before { context.add(type, input)}

      context "when the input is a product" do
        let(:type) { :product }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to eq([input]) }
      end
    end

    describe "#tags" do
      subject { context.tags }

      before { context.add(type, input)}

      context "when the input is a tag" do
        let(:type) { :tag }
        let(:input) { Tag.new('name') }
        it { is_expected.to eq([input]) }
      end
    end
  end
end
