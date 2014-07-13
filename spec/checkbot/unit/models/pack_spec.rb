require 'spec_helper'

module Checkbot
  describe Pack do
    describe ".new" do
      subject { Pack.new(:type, 'pack name', options) }

      let(:options) { {} }
      it { is_expected.to be_a(Pack) }
      specify {
        expect(subject.name).to eq('pack name')
        expect(subject.or_more).to be(false)
        expect(subject.shipping).to be(false)
      }

      context "when it's an amount off" do
        let(:options) { { amount_off: 10 } }
        specify {
          expect(subject.amount_off).to be_a(Money)
          expect(subject.amount_off).to eq(10)
        }
      end

      context "when it's an fixed price" do
        let(:options) { { fixed_price: 11 } }
        specify {
          expect(subject.fixed_price).to be_a(Money)
          expect(subject.fixed_price).to eq(11)
        }
      end

      context "when it's an Percentage off" do
        let(:options) { { percentage_off: 12 } }
        specify {
          expect(subject.percentage_off).to be_a(Percentage)
          expect(subject.percentage_off).to eq(12)
        }
      end

      context "when the optional arguments are set" do
        let(:options) do
          {
            or_more: true,
            shipping: true,
          }
        end

        it { is_expected.to be_a(Pack) }
        specify {
          expect(subject.or_more).to be(true)
          expect(subject.shipping).to be(true)
        }
      end

      context "when invalid options are passed" do
        let(:options) do
          {
            amount_off: 10,
            fixed_price: 11,
            percentage_off: 12,
          }
        end
        specify {
          expect { subject }.to raise_exception(Pack::InvalidDiscount, /The options contain more than one key/)
          expect { subject }.to raise_exception(Pack::InvalidDiscount, /amount_off/)
          expect { subject }.to raise_exception(Pack::InvalidDiscount, /fixed_price/)
          expect { subject }.to raise_exception(Pack::InvalidDiscount, /percentage_off/)
        }
      end
    end

    describe "#to_s" do
      subject { mixed_pack.send(:to_s) }

      let(:options) { {} }
      let(:mixed_pack) { Pack.new(:type, 'pack name', options) }
      it { is_expected.to be_a(String) }

      context "when the input is an amount off" do
        let(:options) { { amount_off: 20.1 } }
        it { is_expected.to eq(' -> D-$20.10') }
      end

      context "when the input is a fixed price" do
        let(:options) { { fixed_price: 20.1 } }
        it { is_expected.to eq(' -> D$20.10') }
      end

      context "when the input is a percentage off" do
        let(:options) { { percentage_off: 20.1 } }
        it { is_expected.to eq(' -> D-20.1%') }
      end

      context "when the input is a shipping amount off" do
        let(:options) { { shipping: true, amount_off: 20 } }
        it { is_expected.to eq(' -> Sh-$20') }
      end

      context "when the input is a shipping fixed price" do
        let(:options) { { shipping: true, fixed_price: 20 } }
        it { is_expected.to eq(' -> Sh$20') }
      end

      context "when the input is a shipping percentage off" do
        let(:options) { { shipping: true, percentage_off: 20 } }
        it { is_expected.to eq(' -> Sh-20%') }
      end

      context "when the savings can be applied to any number 'or more' of the discountable items" do
        let(:options) { { or_more: true, amount_off: 20 } }
        it { is_expected.to eq('+ -> D-$20') }
      end
    end
  end
end
