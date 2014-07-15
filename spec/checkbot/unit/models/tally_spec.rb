require 'spec_helper'

module Checkbot
  describe Tally do
    describe ".new" do
      subject { Tally.new(10, options) }
      let(:options) { {} }
      it { is_expected.to be_a(Tally) }

      specify {
        expect(subject.amount).to be_a(Money)
        expect(subject.amount).to eq(10)
        expect(subject.shipping).to be(false)
      }

      context "when it's a shipping tally" do
        let(:options) { {shipping: true} }
        specify {
          expect(subject.shipping).to be(true)
        }
      end
    end

    describe "#to_s" do
      subject { tally.to_s }
      let(:tally) { Tally.new(25) }
      it { is_expected.to be_a(String) }

      context "when it's basic" do
        let(:tally) { Tally.new(25) }
        it { is_expected.to eq('discount => $25') }
      end

      context "when it's a shipping tally" do
        let(:tally) { Tally.new(25, shipping: true) }
        it { is_expected.to eq('sh discount => $25') }
      end
    end
  end
end
