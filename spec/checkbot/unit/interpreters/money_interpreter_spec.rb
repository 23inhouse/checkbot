require 'spec_helper'

module Checkbot
  describe MoneyInterpreter do
    let(:interpreter) { MoneyInterpreter.new(input) }

    describe ".regex" do
      subject { MoneyInterpreter.regex.source }

      context "when it has no arguments" do
        it { is_expected.to include('money') }
      end

      context "when the argument is named widget" do
        subject { MoneyInterpreter.regex('widget').source }
        it { is_expected.to include('widget') }
      end
    end

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input has money" do
        let(:input) { '$20' }
        it { is_expected.to eq(['$20']) }
      end

      context "when the input has multiple lines of money" do
        let(:input) { "$44.90\n$89.5" }
        it { is_expected.to eq(['$44.90','$89.5']) }
      end
    end

    describe "#attributes" do
      let(:money) { interpreter.attributes }
      let(:first_money) { money.first }

      context "when the input is a String" do
        let(:input) { '$28.90' }

        specify {
          expect(money).to be_a(Array)
          expect(first_money[:money]).to be_a(Money)
          expect(first_money[:money]).to eq(28.9)
        }
      end

      context "and it is malformed" do
        let(:input) { "\n  $  22.5 \n" }

        specify {
          expect(money).to be_a(Array)
          expect(first_money[:money]).to be_a(Money)
          expect(first_money[:money]).to eq(22.5)
        }
      end
    end
  end
end
