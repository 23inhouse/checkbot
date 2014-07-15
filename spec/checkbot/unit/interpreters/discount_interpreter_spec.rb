require 'spec_helper'

module Checkbot
  describe DiscountInterpreter do
    let(:interpreter) { DiscountInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is a discount" do
        let(:input) { '#2P(product 1) & #1P(product 2) -> D$20' }
        it { is_expected.to eq(['#2P(product 1) & #1P(product 2) -> D$20']) }
      end
    end

    describe "#attributes" do
      let(:discounts) { interpreter.attributes }
      let(:first_discount) { discounts.first }

      context "when the input is a String" do
        let(:input) { '#2P(product 1) & #1P(product 2)+ -> D-50%'}

        describe "it sets all the attributes" do
          specify {
            expect(discounts).to be_a(Array)
            expect(discounts.size).to eq(1)
            expect(first_discount).to eq({
              packables: [
                {quantity: '2', type: :product, name: 'product 1'},
                {quantity: '1', type: :product, name: 'product 2'}
              ],
              percentage_off: '50',
              or_more: true,
              shipping: false
            })
          }
        end
      end

      context "when the input is a multiline String" do
        let(:input) { "#2P(product 1) & #1P(product 2) -> D-50%\n #2P(product 1) & #1P(product 2) -> D-50%"}

        describe "there will be more than one" do
          specify {
            expect(discounts).to be_a(Array)
            expect(discounts.size).to eq(2)
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n  #  2  P  (  product 1  ) & #  1  P  (  product 2  )  +   ->   D  -  50  % \n" }

        describe "it still works" do
          specify {
            expect(discounts).to be_a(Array)
            expect(discounts.size).to eq(1)
            expect(first_discount).to eq({
              packables: [
                {quantity: '2', type: :product, name: 'product 1'},
                {quantity: '1', type: :product, name: 'product 2'}
              ],
              percentage_off: '50',
              or_more: true,
              shipping: false
            })
          }
        end
      end
    end
  end
end
