require 'spec_helper'

module Checkbot
  describe PercentageInterpreter do
    let(:interpreter) { PercentageInterpreter.new(input) }

    describe ".regex" do
      subject { PercentageInterpreter.regex.source }

      context "when it has no arguments" do
        it { is_expected.to include('percentage') }
      end

      context "when the argument is named widget" do
        subject { PercentageInterpreter.regex('widget').source }
        it { is_expected.to include('widget') }
      end
    end

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input has percentage" do
        let(:input) { '20%' }
        it { is_expected.to eq(['20%']) }
      end

      context "when the input has multiple lines of percentage" do
        let(:input) { "44.90%\n89.555%" }
        it { is_expected.to eq(['44.90%','89.555%']) }
      end
    end

    describe "#attributes" do
      let(:percentages) { interpreter.attributes }
      let(:first_percentage) { percentages.first }

      context "when the input is a String" do
        let(:input) { '28.91919%'}

        specify {
          expect(percentages).to be_a(Array)
          expect(first_percentage[:percentage]).to be_a(Percentage)
          expect(first_percentage[:percentage]).to eq(28.91919)
        }
      end

      context "and it is malformed" do
        let(:input) { "\n  22.587  % \n" }

        specify {
          expect(percentages).to be_a(Array)
          expect(first_percentage[:percentage]).to be_a(Percentage)
          expect(first_percentage[:percentage]).to eq(22.587)
        }
      end
    end
  end
end
