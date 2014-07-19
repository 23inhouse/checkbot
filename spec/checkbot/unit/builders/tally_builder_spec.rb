require 'spec_helper'

module Checkbot
  describe TallyBuilder do
    let(:builder) { TallyBuilder.new(input) }

    describe "#tally" do
      let(:tally) { builder.tally }

      context "when the input is for a tally" do
        let(:input) do
          {amount: '25.5'}
        end

        describe "it sets all the attributes" do
          specify {
            expect(tally).to be_a(Tally)
            expect(tally.amount).to eq(25.5)
            expect(tally.shipping).to be(false)
          }
        end
      end

      context "when the input is for a shipping tally" do
        let(:input) do
          {amount: '25.5', shipping: true}
        end

        describe "it sets all the attributes" do
          specify {
            expect(tally).to be_a(Tally)
            expect(tally.amount).to eq(25.5)
            expect(tally.shipping).to be(true)
          }
        end
      end
    end
  end
end
