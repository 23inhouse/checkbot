require 'spec_helper'

module Checkbot
  describe TotalsInterpreter do
    let(:interpreter) { TotalsInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is a subtotal" do
        let(:input) { 'subtotal => $25' }
        it { is_expected.to eq(['subtotal => $25']) }
      end

      context "when the input is a shippng subtotal" do
        let(:input) { 'shipping => $25' }
        it { is_expected.to eq(['shipping => $25']) }
      end

      context "when the input is the cart total" do
        let(:input) { 'total => $25' }
        it { is_expected.to eq(['total => $25']) }
      end
    end

    describe "#attributes" do
      let(:totals) { interpreter.attributes }
      let(:first_total) { totals.first }

      context "when the input is a String" do
        let(:input) { 'total => $25.50'}

        describe "it sets all the attributes" do
          specify {
            expect(totals).to be_a(Array)
            expect(totals.size).to eq(1)
            expect(first_total).to eq({total: '25.50'})
          }
        end
      end

      context "when the input is a multiline String" do
        let(:input) { "subtotal => $25\nshipping => $15\ntotal => $35"}

        describe "there will be more than one" do
          specify {
            expect(totals).to be_a(Array)
            expect(totals.size).to eq(3)
            expect(totals).to eq([{subtotal: '25'}, {shipping: '15'}, {total: '35'}])
          }
        end
      end

      context "when it is malformed" do
        let(:input) { "\n  subtotal   =>   $ 15  \n" }

        describe "it still works" do
          specify {
            expect(totals).to be_a(Array)
            expect(totals.size).to eq(1)
            expect(first_total).to eq({subtotal: '15'})
          }
        end
      end

      context "when it's invalid" do
        let(:input) { "invalidtotal => $15" }

        describe "it doesn't work" do
          specify {
            expect(totals).to be_a(Array)
            expect(totals.size).to eq(0)
          }
        end
      end
    end
  end
end
