require 'spec_helper'

module Checkbot
  describe TagBuilder do
    let(:builder) { TagBuilder.new(input) }

    describe "#tag" do
      let(:tag) { builder.tag }

      context "when the input is for a tag" do
        let(:input) { {name: 'tag name'} }

        describe "it sets all the attributes" do
          specify {
            expect(tag).to be_a(Tag)
            expect(tag.name).to eq('tag name')
          }
        end
      end
    end
  end
end
