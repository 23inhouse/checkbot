require 'spec_helper'

module Checkbot
  describe DiscountableInterpreter do
    let(:interpreter) { DiscountableInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input has discount_codes" do
        let(:input) { '[1011]' }
        it { is_expected.to eq(['[1011]']) }
      end
      context "when the input has multiple lines of discount_codes" do
        let(:input) { "[1101]\n[1110]" }
        it { is_expected.to eq(['[1101]','[1110]']) }
      end
    end

    describe "#attributes" do
      let(:discount_codes) { interpreter.attributes }
      let(:first_discount_code) { discount_codes.first }

      context "when the input is a String" do
        let(:input) { '[0000]'}

        describe "it returns the hash of attributes" do
          specify {
            expect(discount_codes).to be_a(Array)
            expect(first_discount_code).to be_a(Hash)
            expect(first_discount_code).to eq({
              qualify_for_price_discount: false,
              qualify_for_shipping_discount: false,
              receive_price_discount: false,
              receive_shipping_discount: false,
            })
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n  [  1   0   0   0    ] \n" }

        describe "it still works" do
          specify {
            expect(discount_codes).to be_a(Array)
            expect(first_discount_code).to be_a(Hash)
            expect(first_discount_code).to eq({
              qualify_for_price_discount: true,
              qualify_for_shipping_discount: false,
              receive_price_discount: false,
              receive_shipping_discount: false,
            })
          }
        end
      end
    end
  end
end
