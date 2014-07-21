require 'spec_helper'

module Checkbot
  describe ProductContext do
    let(:context) { ProductContext.new }

    describe "#add" do
      subject { context.add(product) }

      context "when the input is a product" do
        let(:product) { Product.new('product name') }
        it { is_expected.to be(product) }
      end
    end

    describe "#products" do
      subject { context.products }

      it { is_expected.to be_a(Array) }

      context "when the input is a product" do
        let(:input) { Product.new('product name') }
        before { context.add(input) }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a product" do
        let(:input1) { Product.new('same') }
        let(:input2) { Product.new('different', 2) }
        let(:input3) { Product.new('same', 1) }
        let(:input4) { Product.new('different', 1) }

        before {
          context.add(input1)
          context.add(input2)
          context.add(input3)
          context.add(input4)
        }

        describe "then the product is added to the context" do
          specify {
            expect(subject.size).to eq(2)
            expect(subject.first).to be(input1)
            expect(subject.last).to be(input2)
          }

          describe "and the prices are set to the last specified value" do
            specify {
              expect(subject.first.price).to eq(1)
              expect(subject.last.price).to eq(1)
            }
          end
        end
      end
    end
  end
end
