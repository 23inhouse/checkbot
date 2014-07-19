require 'spec_helper'

module Checkbot
  describe PackableBuilder do
    let(:builder) { PackableBuilder.new(input) }

    describe "#packable" do
      let(:packable) { builder.packable }

      context "when the input is a quantity" do
        context "and it's a product" do
          let(:input) do
            {quantity: '2', type: :product, name: 'product'}
          end

          describe "it sets all the attributes" do
            specify {
              expect(packable).to be_a(Packable)
              expect(packable.quantity).to eq(2)
              expect(packable.packable).to be_a(Product)
              expect(packable.packable.name).to eq('product')
            }
          end
        end

        context "and it's a mixed pack" do
          let(:input) do
            {quantity: '2', type: :mixed_pack, name: 'mixed pack'}
          end

          describe "it sets all the attributes" do
            specify {
              expect(packable).to be_a(Packable)
              expect(packable.quantity).to eq(2)
              expect(packable.packable).to be_a(MixedPack)
              expect(packable.packable.name).to eq('mixed pack')
            }
          end
        end

        context "and it's a tag" do
          let(:input) do
            {quantity: '2', type: :tag, name: 'tag'}
          end

          describe "it sets all the attributes" do
            specify {
              expect(packable).to be_a(Packable)
              expect(packable.quantity).to eq(2)
              expect(packable.packable).to be_a(Tag)
              expect(packable.packable.name).to eq('tag')
            }
          end
        end
      end

      context "when the input is an amount" do
        context "and it's a product" do
          let(:input) do
            {amount: '20', type: :product, name: 'product'}
          end

          describe "it sets all the attributes" do
            specify {
              expect(packable).to be_a(Packable)
              expect(packable.amount).to eq(20)
              expect(packable.packable).to be_a(Product)
              expect(packable.packable.name).to eq('product')
            }
          end
        end

        context "and it's a mixed pack" do
          let(:input) do
            {amount: '20', type: :mixed_pack, name: 'mixed pack'}
          end

          describe "it sets all the attributes" do
            specify {
              expect(packable).to be_a(Packable)
              expect(packable.amount).to eq(20)
              expect(packable.packable).to be_a(MixedPack)
              expect(packable.packable.name).to eq('mixed pack')
            }
          end
        end

        context "and it's a tag" do
          let(:input) do
            {amount: '20', type: :tag, name: 'tag'}
          end

          describe "it sets all the attributes" do
            specify {
              expect(packable).to be_a(Packable)
              expect(packable.amount).to eq(20)
              expect(packable.packable).to be_a(Tag)
              expect(packable.packable.name).to eq('tag')
            }
          end
        end
      end
    end
  end
end
