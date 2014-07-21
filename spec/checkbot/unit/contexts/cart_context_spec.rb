require 'spec_helper'

module Checkbot
  describe CartContext do
    let(:context) { CartContext.new }

    describe "#add" do
      subject { context.add(cart) }

      context "when the input is a cart" do
        let(:cart) { Cart.new }
        it { is_expected.to be(cart) }
      end
    end

    describe "#carts" do
      subject { context.carts }

      it { is_expected.to be_a(Array) }

      context "when the input is a cart" do
        let(:input) { Cart.new }
        before { context.add(input) }
        it { is_expected.to eq([input]) }
      end
    end
  end
end
