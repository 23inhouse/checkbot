require 'spec_helper'

module Checkbot
  describe CartItemInterpreter do
    let(:interpreter) { CartItemInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is a cart item" do
        let(:input) { '#2(item name $20.50)' }
        it { is_expected.to eq(['#2(item name $20.50)']) }
      end

      context "when the input is a cart item without a price" do
        let(:input) { '#2(item name)' }
        it { is_expected.to eq(['#2(item name)']) }
      end

      context "when the input is a cart item is a mixed pack" do
        let(:input) { '#2[item name]' }
        it { is_expected.to eq(['#2[item name]']) }
      end

      context "when the input has price savings" do
        let(:input) { '#2(item name $20.50) -> $41 ($35)' }
        it { is_expected.to eq(['#2(item name $20.50) -> $41 ($35)']) }
      end

      context "when the input has shipping savings" do
        let(:input) { '#2(item name $20.50) sh -> $10 ($0)' }
        it { is_expected.to eq(['#2(item name $20.50) sh -> $10 ($0)']) }
      end

      context "when the input has both price and shipping savings" do
        let(:input) { '#2(item name $20.50) -> $41 ($35) sh -> $10 ($0)' }
        it { is_expected.to eq(['#2(item name $20.50) -> $41 ($35) sh -> $10 ($0)']) }
      end
    end

    describe "#attributes" do
      let(:cart_items) { interpreter.attributes }
      let(:first_cart_item) { cart_items.first }

      context "when the input is a String" do
        let(:input) { '#2(item name $20.50) -> $41 ($35) sh -> $10 ($0)'}

        describe "it sets all the attributes" do
          specify {
            expect(cart_items).to be_a(Array)
            expect(cart_items.size).to eq(1)
            expect(first_cart_item).to eq({
              quantity: 2,
              item_type: :product,
              item_name: 'item name',
              item_price: '20.50',
              price_rrp: '41',
              price_subtotal: '35',
              shipping_rrp: '10',
              shipping_subtotal: '0'
            })
          }
        end
      end

      context "when the input is a multiline String" do
        let(:input) { "#2(item name $20.50) -> $41 ($35) sh -> $10 ($0)\n#2[item name $20.50] -> $41 ($35) sh -> $10 ($0)"}

        describe "there will be more than one" do
          specify {
            expect(cart_items).to be_a(Array)
            expect(cart_items.size).to eq(2)
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n #  2  [  item name  $20.50  ]  ->  $  41  (  $35  )  sh  ->  $10  (  $0  )  \n" }

        describe "it still works" do
          specify {
            expect(cart_items).to be_a(Array)
            expect(cart_items.size).to eq(1)
            expect(first_cart_item).to eq({
              quantity: 2,
              item_type: :mixed_pack,
              item_name: 'item name',
              item_price: '20.50',
              price_rrp: '41',
              price_subtotal: '35',
              shipping_rrp: '10',
              shipping_subtotal: '0'
            })
          }
        end
      end
    end
  end
end
