require 'spec_helper'

module Checkbot
  describe TallyInterpreter do
    let(:interpreter) { TallyInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is a price tally" do
        let(:input) { 'discount => $25' }
        it { is_expected.to eq(['discount => $25']) }
      end

      context "when the input is a shipping tally" do
        let(:input) { 'sh discount => $25' }
        it { is_expected.to eq(['sh discount => $25']) }
      end

      context "when the input uses a negative sign" do
        let(:input) { 'discount => -$25' }
        it { is_expected.to eq(['discount => -$25']) }
      end
    end

    describe "#attributes" do
      let(:tallies) { interpreter.attributes }
      let(:first_tally) { tallies.first }

      context "when the input is a String" do
        let(:input) { 'discount => $25.50'}

        describe "it sets all the attributes" do
          specify {
            expect(tallies).to be_a(Array)
            expect(tallies.size).to eq(1)
            expect(first_tally).to eq({amount: '25.50'})
          }
        end
      end

      context "when the input is a multiline String" do
        let(:input) { "discount => $25\nsh discount => $15\ndiscount => $35\nsh discount => $5"}

        describe "there will be more than one" do
          specify {
            expect(tallies).to be_a(Array)
            expect(tallies.size).to eq(4)
            expect(tallies).to eq([
              {amount: '25'},
              {amount: '15', shipping: true},
              {amount: '35'},
              {amount: '5', shipping: true},
            ])
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n sh   discount   =>   $ 15 \n" }

        describe "it still works" do
          specify {
            expect(tallies).to be_a(Array)
            expect(tallies.size).to eq(1)
            expect(first_tally).to eq({amount: '15', shipping: true})
          }
        end
      end
    end
  end
end
