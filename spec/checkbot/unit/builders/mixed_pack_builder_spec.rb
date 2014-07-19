require 'spec_helper'

module Checkbot
  describe MixedPackBuilder do
    let(:builder) { MixedPackBuilder.new(input) }

    describe "#mixed_pack" do
      let(:mixed_pack) { builder.mixed_pack }

      context "when the input is for a mixed pack" do
        let(:input) do
          {
            name: 'mixed pack name',
            packables: [
              {quantity: '2', type: :product, name: 'product 1'},
              {quantity: '1', type: :product, name: 'product 2'}
            ],
            percentage_off: '50',
            or_more: false,
            shipping: false,
            receive_price_discount: false
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(mixed_pack).to be_a(MixedPack)
            expect(mixed_pack.name).to eq('mixed pack name')
            expect(mixed_pack.percentage_off).to eq(50)
            expect(mixed_pack.or_more).to eq(false)
            expect(mixed_pack.shipping).to eq(false)
            expect(mixed_pack.receive_price_discount).to eq(false)
            expect(mixed_pack.packables.first.packable).to be_a(Product)
            expect(mixed_pack.packables.first.name).to eq('product 1')
            expect(mixed_pack.packables.first.quantity).to eq(2)
            expect(mixed_pack.packables.last.packable).to be_a(Product)
            expect(mixed_pack.packables.last.name).to eq('product 2')
            expect(mixed_pack.packables.last.quantity).to eq(1)
            expect(mixed_pack.tags.size).to eq(0)
          }
        end
      end

      context "when the input is for a mixed pack with tags" do
        let(:input) do
          {
            name: 'mixed pack name',
            packables: [
              {quantity: '2', type: :product, name: 'product 1'},
              {quantity: '1', type: :product, name: 'product 2'}
            ],
            tags: [{name: 'tag 1'}, {name: 'tag 2'}],
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(mixed_pack).to be_a(MixedPack)
            expect(mixed_pack.name).to eq('mixed pack name')
            expect(mixed_pack.tags.size).to eq(2)
            expect(mixed_pack.tags.first).to be_a(Tag)
            expect(mixed_pack.tags.first.name).to eq('tag 1')
            expect(mixed_pack.tags.last).to be_a(Tag)
            expect(mixed_pack.tags.last.name).to eq('tag 2')
          }
        end
      end
    end
  end
end
