require 'spec_helper'

module Checkbot
  describe SavingsInterpreter do
    let(:interpreter) { SavingsInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input is an amount off" do
        let(:input) { '-> D-$20.1' }
        it { is_expected.to eq(['-> D-$20.1']) }
      end

      context "when the input is a fixed price" do
        let(:input) { '-> D$20.1' }
        it { is_expected.to eq(['-> D$20.1']) }
      end

      context "when the input is a percentage off" do
        let(:input) { '-> D-20.1%' }
        it { is_expected.to eq(['-> D-20.1%']) }
      end

      context "when the input is a shipping amount off" do
        let(:input) { '-> Sh-$20' }
        it { is_expected.to eq(['-> Sh-$20']) }
      end

      context "when the input is a shipping fixed price" do
        let(:input) { '-> Sh$20' }
        it { is_expected.to eq(['-> Sh$20']) }
      end

      context "when the input is a shipping percentage off" do
        let(:input) { '-> Sh-20%' }
        it { is_expected.to eq(['-> Sh-20%']) }
      end

      context "when the savings can be applied to any number 'or more' of the discountable items" do
        let(:input) { '+ -> D-20%' }
        it { is_expected.to eq(['+ -> D-20%']) }
      end
    end

    describe "#attributes" do
      let(:savings) { interpreter.attributes }
      let(:first_saving) { savings.first }
      let(:last_saving) { savings.last }

      context "when the input is a percentage off" do
        let(:input) { '-> D-50%'}

        describe "it sets all the attributes" do
          specify {
            expect(savings).to be_a(Array)
            expect(savings.size).to eq(1)
            expect(first_saving).to eq({percentage_off: '50', or_more: false, shipping: false})
          }
        end
      end

      context "when the input is a shipping amount off" do
        let(:input) { '-> Sh-$50'}

        describe "it sets all the attributes" do
          specify {
            expect(savings).to be_a(Array)
            expect(savings.size).to eq(1)
            expect(first_saving).to eq({amount_off: '50', or_more: false, shipping: true})
          }
        end
      end

      context "when the input is an or more with a shipping fixed price" do
        let(:input) { '+ -> Sh$40'}

        describe "it sets all the attributes" do
          specify {
            expect(savings).to be_a(Array)
            expect(savings.size).to eq(1)
            expect(first_saving).to eq({fixed_price: '40', or_more: true, shipping: true})
          }
        end
      end

      context "when the input is an or more with a amount off" do
        let(:input) { '+ -> D-$33.3'}

        describe "it sets all the attributes" do
          specify {
            expect(savings).to be_a(Array)
            expect(savings.size).to eq(1)
            expect(first_saving).to eq({amount_off: '33.3', or_more: true, shipping: false})
          }
        end
      end

      context "when it is malformed" do
        let(:input) { "\n +->D-$20 \n  +  ->  Sh  $  19 \n" }

        describe "it still works" do
          specify {
            expect(savings).to be_a(Array)
            expect(savings.size).to eq(2)
            expect(first_saving).to eq({amount_off: '20', or_more: true, shipping: false})
            expect(last_saving).to eq({fixed_price: '19', or_more: true, shipping: true})
          }
        end
      end
    end
  end
end
