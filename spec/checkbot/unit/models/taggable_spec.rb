require 'spec_helper'

module Checkbot
  describe Taggable do
    before(:all) {
      class Widget
        include Taggable
        def initialize(tags = [])
          set_tags(tags)
        end
      end
    }
    let(:widget) { Widget.new(tags) }
    let(:tags) { [] }

    describe "#tag_names" do
      subject { widget.tag_names }
      it { is_expected.to be_a(String) }
      it { is_expected.to eq('') }

      context "when there is one tag" do
        let(:tags) { [Tag.new('tag1')] }
        it { is_expected.to eq('{ tag1 }') }
      end

      context "when there are multiple tags" do
        let(:tags) { [Tag.new('tag1'), Tag.new('tag2'), Tag.new('tag3')] }
        it { is_expected.to eq('{ tag1, tag2, tag3 }') }
      end
    end

    describe "#tags?" do
      subject { widget.tags? }
      it { is_expected.to eq(false) }

      context "when there are tags" do
        let(:tags) { [Tag.new('tag1')] }
        it { is_expected.to eq(true) }
      end
    end
  end
end
