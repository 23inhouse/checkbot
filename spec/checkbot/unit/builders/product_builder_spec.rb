require 'spec_helper'

module Checkbot
  describe ProductBuilder do
    let(:builder) { ProductBuilder.new(input) }

    describe "#product" do
      let(:product) { builder.product }

      context "when the input is for a product" do
        let(:input) do
          {
            name: 'product name',
            price: '25.5',
            qualify_for_price_discount: false,
            receive_price_discount: true,
            qualify_for_shipping_discount: false,
            receive_shipping_discount: true,
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(product).to be_a(Product)
            expect(product.name).to eq('product name')
            expect(product.price).to eq(25.5)
            expect(product.tags.size).to eq(0)
            expect(product.qualify_for_price_discount).to eq(false)
            expect(product.receive_price_discount).to eq(true)
            expect(product.qualify_for_shipping_discount).to eq(false)
            expect(product.receive_shipping_discount).to eq(true)
          }
        end
      end

      context "when the input is for a product with tags" do
        let(:input) do
          {
            name: 'product name',
            tags: [{name: 'tag1'}, {name: 'tag2'}]
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(product).to be_a(Product)
            expect(product.name).to eq('product name')
            expect(product.tags.size).to eq(2)
            expect(product.tags.first.name).to eq('tag1')
            expect(product.tags.last.name).to eq('tag2')
          }
        end
      end
    end
  end
end
