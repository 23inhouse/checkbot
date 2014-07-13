require 'spec_helper'

module Checkbot
  describe Percentage do
    let(:percentage) { Percentage.new(input) }

    describe ".new" do
      subject { percentage }
      let(:input) { 99.9 }
      it { is_expected.to be_a(Percentage) }

      context "when the input is an integer 99" do
        let(:input) { 99 }
        it { is_expected.to eq(99.to_d) }
      end

      context "when the input is a float 99.9" do
        let(:input) { 99.9 }
        it { is_expected.to eq('99.9'.to_d) }
      end

      context "when the input is a Big Decimal 99.9" do
        let(:input) { '99.9'.to_d }
        it { is_expected.to eq('99.9'.to_d) }
      end

      context "when the input is a string 99.9" do
        let(:input) { '99.9' }
        it { is_expected.to eq('99.9'.to_d) }
      end
    end

    describe "#to_s" do
      subject { percentage.to_s }
      let(:input) { 99 }
      it { is_expected.to be_a(String) }

      context "with an argument" do
        subject { percentage.to_s('F') }
        it { is_expected.to be_a(String) }
      end

      context "when the input is a whole number 99" do
        let(:input) { 99 }
        it { is_expected.to eq('99%') }
      end

      context "when the input has 1 decimal place 99.5" do
        let(:input) { 99.5 }
        it { is_expected.to eq('99.5%') }
      end

      context "when the input has more than 1 decimal place 44.444" do
        let(:input) { 44.444 }
        it { is_expected.to eq('44.4%') }
      end

      context "when the input has more than 1 decimal place it also rounds and shows a decimal" do
        let(:input) { 99.999 }
        it { is_expected.to eq('100.0%') }
      end
    end

    describe "#inspect" do
      subject { percentage.inspect }
      let(:input) { 99 }
      it { is_expected.to be_a(String) }

      context "when the input is a whole dollar amount 99" do
        let(:input) { 99 }
        it { is_expected.to include("#<Checkbot::Percentage: #<BigDecimal:") }
        it { is_expected.to include("'0.99E2',9(18)> >") }
      end

      context "when the input is a dollar with cents 99.99" do
        let(:input) { 99.99 }
        it { is_expected.to include("#<Checkbot::Percentage: #<BigDecimal:") }
        it { is_expected.to include("'0.9999E2',18(18)> >") }
      end
    end
  end
end
