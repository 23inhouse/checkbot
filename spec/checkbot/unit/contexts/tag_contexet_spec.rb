require 'spec_helper'

module Checkbot
  describe TagContext do
    let(:context) { TagContext.new }

    describe "#add" do
      subject { context.add(tag) }

      context "when the input is a tag" do
        let(:tag) { Tag.new('tag name') }
        it { is_expected.to be(tag) }
      end
    end

    describe "#tags" do
      subject { context.tags }

      it { is_expected.to be_a(Array) }

      context "when the input is a tag" do
        let(:input) { Tag.new('tag name') }
        before { context.add(input) }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a tag" do
        let(:input1) { Tag.new('same') }
        let(:input2) { Tag.new('different') }
        let(:input3) { Tag.new('same') }

        before {
          context.add(input1)
          context.add(input2)
          context.add(input3)
        }

        describe "then the tag is added to the context" do
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
