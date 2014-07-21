require 'spec_helper'

module Checkbot
  describe MixedPackContext do
    let(:context) { MixedPackContext.new }

    describe "#add" do
      subject { context.add(mixed_pack) }

      context "when the input is a mixed_pack" do
        let(:mixed_pack) { MixedPack.new('mixed_pack name') }
        it { is_expected.to be(mixed_pack) }
      end
    end

    describe "#mixed_packs" do
      subject { context.mixed_packs }

      it { is_expected.to be_a(Array) }

      context "when the input is a mixed_pack" do
        let(:input) { MixedPack.new('mixed_pack name') }
        before { context.add(input) }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a mixed_pack" do
        let(:input1) { MixedPack.new('same') }
        let(:input2) { MixedPack.new('different') }
        let(:input3) { MixedPack.new('same') }

        before {
          context.add(input1)
          context.add(input2)
          context.add(input3)
        }

        describe "then the mixed pack is added to the context" do
          specify {
            expect(subject.size).to eq(2)
            expect(subject.first).to be(input1)
            expect(subject.last).to be(input2)
          }
        end
      end
    end
  end
end
