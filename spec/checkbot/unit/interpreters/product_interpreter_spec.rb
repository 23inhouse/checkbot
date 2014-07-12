require 'spec_helper'

module Checkbot
  describe ProductInterpreter do
    let(:interpreter) { ProductInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is a product" do
        let(:input) { 'product name $25' }
        it { is_expected.to eq(['product name $25']) }
      end

      context "when the input has exclusions set" do
        let(:input) { 'product name $25 [0100]' }
        it { is_expected.to eq(['product name $25 [0100]']) }
      end

      context "when the input has tags" do
        let(:input) { 'product name $25 { tag1, tag2 }' }
        it { is_expected.to eq(['product name $25 { tag1, tag2 }']) }
      end

      context "when the input has both exclusions and tags" do
        let(:input) { 'product name $25 [0100] { tag1, tag2 }' }
        it { is_expected.to eq(['product name $25 [0100] { tag1, tag2 }']) }
      end

      context "when the input does not match" do
        context "without a price" do
          let(:input) { 'product name' }
          it { is_expected.to eq([]) }
        end

        context "with a short name" do
          let(:input) { 'aa $25' }
          it { is_expected.to eq([]) }
        end
      end
    end

    describe "#attributes" do
      let(:products) { interpreter.attributes }
      let(:first_product) { products.first }

      context "when the input is a String" do
        let(:input) { 'product name $25.5 [0101] { tag1, tag2 }'}

        describe "it sets all the attributes" do
          specify {
            expect(products).to be_a(Array)
            expect(products.size).to eq(1)
            expect(first_product).to eq({
              name: 'product name',
              price: '25.5',
              qualify_for_price_discount: false,
              receive_price_discount: true,
              qualify_for_shipping_discount: false,
              receive_shipping_discount: true,
              tags: [{name: 'tag1'}, {name: 'tag2'}]
            })
          }
        end
      end

      context "when the input is a multiline String" do
        let(:input) { "product name $25.5 [0100] { tag1, tag2 }\nproduct name $25.5 [0100] { tag1, tag2 }"}

        describe "there will be more than one" do
          specify {
            expect(products).to be_a(Array)
            expect(products.size).to eq(2)
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n product name  $  25  [ 0 0 0 1 ]  { tag1 ,  tag2 } \n" }

        describe "it still works" do
          specify {
            expect(products).to be_a(Array)
            expect(products.size).to eq(1)
            expect(first_product).to eq({
              name: 'product name',
              price: '25',
              qualify_for_price_discount: false,
              receive_price_discount: false,
              qualify_for_shipping_discount: false,
              receive_shipping_discount: true,
              tags: [{name: 'tag1'}, {name: 'tag2'}]
            })
          }
        end
      end
    end
  end
end
