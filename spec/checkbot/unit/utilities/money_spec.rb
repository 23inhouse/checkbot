require 'spec_helper'

module Checkbot
  describe Money do
    let(:money) { Money.new(input) }

    describe ".new" do
      subject { money }
      let(:input) { 99.9 }
      it { is_expected.to be_a(Money) }

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
      subject { money.to_s }
      let(:input) { 99 }
      it { is_expected.to be_a(String) }

      context "with an argument" do
        subject { money.to_s('F') }
        it { is_expected.to be_a(String) }
      end

      context "when the input is a whole dollar amount 99" do
        let(:input) { 99 }
        it { is_expected.to eq('$99') }
      end

      context "when the input is a half dollar amount 99.5" do
        let(:input) { 99.5 }
        it { is_expected.to eq('$99.50') }
      end

      context "when the input is a dollar with cents 99.99" do
        let(:input) { 99.99 }
        it { is_expected.to eq('$99.99') }
      end
    end

    describe "#inspect" do
      subject { money.inspect }
      let(:input) { 99 }
      it { is_expected.to be_a(String) }

      context "when the input is a whole dollar amount 99" do
        let(:input) { 99 }
        it { is_expected.to include("#<Checkbot::Money: #<BigDecimal:") }
        it { is_expected.to include("'0.99E2',9(18)> >") }
      end

      context "when the input is a dollar with cents 99.99" do
        let(:input) { 99.99 }
        it { is_expected.to include("#<Checkbot::Money: #<BigDecimal:") }
        it { is_expected.to include("'0.9999E2',18(18)> >") }
      end
    end
  end
end
