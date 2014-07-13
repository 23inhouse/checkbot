require 'spec_helper'

module Checkbot
  describe Packable do
    context "when it's a quantity" do
      let(:options) { {quantity: 10.5} }
      let(:packable) { Packable.new(:input, options) }
      specify {
        expect(packable.amount?).to be(false)
        expect(packable.amount).to be_nil
        expect(packable.quantity?).to be(true)
        expect(packable.quantity).to be_a(Fixnum)
        expect(packable.quantity).to eq(10)
      }
    end

    context "when it's an amount" do
      let(:options) { {amount: 50.15} }
      let(:packable) { Packable.new(:input, options) }
      specify {
        expect(packable.amount?).to be(true)
        expect(packable.amount).to be_a(Money)
        expect(packable.quantity?).to be(false)
        expect(packable.quantity).to be_nil
      }
    end

    describe "#to_s" do
      subject { packable.to_s }
      let(:input) { Product.new('product 1', 9)}
      let(:options) { {} }
      let(:packable) { Packable.new(input, options) }
      it { is_expected.to be_a(String) }

      context "when it's a product" do
        let(:input) { Product.new('product 1', 15) }

        specify {
          expect(packable.mixed_pack?).to be(false)
          expect(packable.product?).to be(true)
          expect(packable.tag?).to be(false)
        }

        context "and it's a quantity of them" do
          let(:options) { {quantity: 1} }
          it { is_expected.to eq('#1P(product 1)') }
        end

        context "and it's an amount of them" do
          let(:options) { {amount: 200} }
          it { is_expected.to eq('$200P(product 1)') }
        end
      end

      context "when it's a tag" do
        let(:input) { Tag.new('tag 1') }

        specify {
          expect(packable.mixed_pack?).to be(false)
          expect(packable.product?).to be(false)
          expect(packable.tag?).to be(true)
        }

        context "and it's a quantity of them" do
          let(:options) { {quantity: 1} }
          it { is_expected.to eq('#1T(tag 1)') }
        end

        context "and it's an amount of them" do
          let(:options) { {amount: 200} }
          it { is_expected.to eq('$200T(tag 1)') }
        end
      end

      context "when it's a mixed pack" do
        let(:input) { MixedPack.new('mixed pack name') }

        specify {
          expect(packable.mixed_pack?).to be(true)
          expect(packable.product?).to be(false)
          expect(packable.tag?).to be(false)
        }

        context "and it's a quantity of them" do
          let(:options) { {quantity: 1} }
          it { is_expected.to eq('#1M(mixed pack name)') }
        end

        context "and it's an amount of them" do
          let(:options) { {amount: 200} }
          it { is_expected.to eq('$200M(mixed pack name)') }
        end
      end
    end
  end
end
