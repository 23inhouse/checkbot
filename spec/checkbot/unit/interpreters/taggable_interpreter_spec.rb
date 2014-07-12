require 'spec_helper'

module Checkbot
  describe TaggableInterpreter do
    let(:interpreter) { TaggableInterpreter.new(input) }

    describe "#matches" do
      subject { interpreter.matches }

      context "when the input has tags" do
        let(:input) { '{ tag1, tag2 }' }
        it { is_expected.to eq(['{ tag1, tag2 }']) }
      end
      context "when the input has multiple lines of tags" do
        let(:input) { "{ tag1, tag2 }\n{ tag3, tag4 }" }
        it { is_expected.to eq(['{ tag1, tag2 }','{ tag3, tag4 }']) }
      end
    end

    describe "#attributes" do
      let(:tags) { interpreter.attributes }
      let(:first_tag) { tags.first }
      let(:last_tag) { tags.last }

      context "when the input is a String" do
        let(:input) { '{ tag1, tag2 }'}

        describe "it returns the array of tags" do
          specify {
            expect(tags).to be_a(Array)
            expect(tags.size).to eq(2)
            expect(first_tag).to eq({name: 'tag1'})
            expect(last_tag).to eq({name: 'tag2'})
          }
        end
      end

      context "and it is malformed" do
        let(:input) { "\n  { tag1 ,  tag2 } \n" }

        describe "it still works" do
          specify {
            expect(tags).to be_a(Array)
            expect(tags.size).to eq(2)
            expect(first_tag).to eq({name: 'tag1'})
            expect(last_tag).to eq({name: 'tag2'})
          }
        end
      end
    end
  end
end
