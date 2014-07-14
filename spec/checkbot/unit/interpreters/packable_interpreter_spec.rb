require 'spec_helper'

module Checkbot
  describe PackableInterpreter do
    let(:interpreter) { PackableInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the unit is a quantity" do
        context "and the packable is a mixed pack" do
          let(:input) { '#2M(mixed pack 1)' }
          it { is_expected.to eq(['#2M(mixed pack 1)']) }
        end

        context "and the packable is a product" do
          let(:input) { '#2P(product 1)' }
          it { is_expected.to eq(['#2P(product 1)']) }
        end

        context "and the packable is a tag" do
          let(:input) { '#2T(tag 1)' }
          it { is_expected.to eq(['#2T(tag 1)']) }
        end
      end

      context "when the unit is an amount" do
        context "and the packable is a mixed pack" do
          let(:input) { '$20.50M(mixed pack 1)' }
          it { is_expected.to eq(['$20.50M(mixed pack 1)']) }
        end

        context "and the packable is a product" do
          let(:input) { '$20.50P(product 1)' }
          it { is_expected.to eq(['$20.50P(product 1)']) }
        end

        context "and the packable is a tag" do
          let(:input) { '$20.50T(tag 1)' }
          it { is_expected.to eq(['$20.50T(tag 1)']) }
        end
      end
    end

    describe "#attributes" do
      let(:packables) { interpreter.attributes }
      let(:first_packable) { packables.first }

      context "when the input is a String" do
        let(:input) { '#2P(product 1)'}

        describe "it sets all the attributes" do
          specify {
            expect(packables).to be_a(Array)
            expect(packables.size).to eq(1)
            expect(first_packable).to eq({quantity: '2', type: :product, name: 'product 1'})
          }
        end
      end

      context "when the input has mulitple packables" do
        let(:input) { "#2M(mp1) & #2P(p1) & #2T(t1) & $20M(mp1) & $20P(p1) & $20T(t1)"}

        describe "there will be more than one" do
          specify {
            expect(packables).to be_a(Array)
            expect(packables.size).to eq(6)
          }

          let(:first_packable)  { packables.shift }
          let(:second_packable) { packables.shift }
          let(:third_packable)  { packables.shift }
          let(:fourth_packable) { packables.shift }
          let(:fifth_packable)  { packables.shift }
          let(:sixth_packable)  { packables.shift }

          specify {
            expect(first_packable).to  eq({quantity: '2', type: :mixed_pack, name: 'mp1'})
            expect(second_packable).to eq({quantity: '2', type: :product, name: 'p1'})
            expect(third_packable).to  eq({quantity: '2', type: :tag, name: 't1'})
            expect(fourth_packable).to eq({amount: '20', type: :mixed_pack, name: 'mp1'})
            expect(fifth_packable).to  eq({amount: '20', type: :product, name: 'p1'})
            expect(sixth_packable).to  eq({amount: '20', type: :tag, name: 't1'})
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n #  2  M  (  mixed pack 099  ) \n" }

        describe "it still works" do
          specify {
            expect(packables).to be_a(Array)
            expect(packables.size).to eq(1)
            expect(first_packable).to eq({quantity: '2', type: :mixed_pack, name: 'mixed pack 099'})
          }
        end
      end
    end
  end
end
