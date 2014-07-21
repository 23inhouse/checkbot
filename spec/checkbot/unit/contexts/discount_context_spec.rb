require 'spec_helper'

module Checkbot
  describe DiscountContext do
    let(:context) { DiscountContext.new }

    describe "#add" do
      subject { context.add(discount) }

      context "when the input is a discount" do
        let(:discount) { Discount.new }
        it { is_expected.to be(discount) }
      end
    end

    describe "#discounts" do
      subject { context.discounts }

      it { is_expected.to be_a(Array) }

      context "when the input is a discount" do
        let(:input) { Discount.new }
        before { context.add(input) }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a discount" do
        let(:input1) { Discount.new }
        let(:input2) { Discount.new }

        before {
          context.add(input1)
          context.add(input2)
        }

        describe "then the discount is added to the context" do
          specify {
            expect(subject.size).to eq(2)
            expect(subject.first).to be(input1)
            expect(subject.last).to be(input2)
          }
        end
      end
    end
  end
end
