require 'spec_helper'

module Checkbot
  describe MixedPackInterpreter do
    let(:interpreter) { MixedPackInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is a mixed_pack" do
        let(:input) { 'mixed pack 2 [#2P(product 1) & #1P(product 2)] -> D$20' }
        it { is_expected.to eq(['mixed pack 2 [#2P(product 1) & #1P(product 2)] -> D$20']) }
      end

      context "when the input is a mixed_pack without a price" do
        let(:input) { 'mixed pack 2 [#2P(product 1) & #1P(product 2)]' }
        it { is_expected.to eq(['mixed pack 2 [#2P(product 1) & #1P(product 2)]']) }
      end

      context "when the input has exclusions set" do
        let(:input) { 'mixed pack 2 [#2P(product 1)] [0100]' }
        it { is_expected.to eq(['mixed pack 2 [#2P(product 1)] [0100]']) }
      end

      context "when the input has tags" do
        let(:input) { 'mixed pack 2 [#2P(product 1)] { tag1, tag2 }' }
        it { is_expected.to eq(['mixed pack 2 [#2P(product 1)] { tag1, tag2 }']) }
      end

      context "when the input has both exclusions and tags" do
        let(:input) { 'mixed pack 2 [#2P(product 1)] [0100] { tag1, tag2 }' }
        it { is_expected.to eq(['mixed pack 2 [#2P(product 1)] [0100] { tag1, tag2 }']) }
      end
    end

    describe "#attributes" do
      let(:mixed_packs) { interpreter.attributes }
      let(:first_mixed_pack) { mixed_packs.first }

      context "when the input is a String" do
        let(:input) { 'mixed pack name [#2P(product 1) & #1P(product 2)] [0100] { tag 1, tag 2 } -> D-50%'}

        describe "it sets all the attributes" do
          specify {
            expect(mixed_packs).to be_a(Array)
            expect(mixed_packs.size).to eq(1)
            expect(first_mixed_pack).to eq({
              name: 'mixed pack name',
              packables: [
                {quantity: '2', type: :product, name: 'product 1'},
                {quantity: '1', type: :product, name: 'product 2'}
              ],
              percentage_off: '50',
              qualify_for_price_discount: false,
              qualify_for_shipping_discount: false,
              receive_price_discount: true,
              receive_shipping_discount: false,
              or_more: false,
              shipping: false,
              tags: [
                {name: 'tag 1'},
                {name: 'tag 2'}
              ]
            })
          }
        end
      end

      context "when the input is a multiline String" do
        let(:input) { "mixed pack name [#2P(product 1) & #1P(product 2)] -> D-50%\n[#2P(product 1) & #1P(product 2)] -> D-50%"}

        describe "there will be more than one" do
          specify {
            expect(mixed_packs).to be_a(Array)
            expect(mixed_packs.size).to eq(2)
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n mixed pack name   [  #  2  P  (  product 1  ) & #  1  P  (  product 2  )  ]   ->   D  -  50  % \n" }

        describe "it still works" do
          specify {
            expect(mixed_packs).to be_a(Array)
            expect(mixed_packs.size).to eq(1)
            expect(first_mixed_pack).to eq({
              name: 'mixed pack name',
              packables: [
                {quantity: '2', type: :product, name: 'product 1'},
                {quantity: '1', type: :product, name: 'product 2'}
              ],
              percentage_off: '50',
              or_more: false,
              shipping: false
            })
          }
        end
      end
    end
  end
end
