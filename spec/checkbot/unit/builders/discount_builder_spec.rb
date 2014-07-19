require 'spec_helper'

module Checkbot
  describe DiscountBuilder do
    let(:builder) { DiscountBuilder.new(input) }

    describe "#discount" do
      let(:discount) { builder.discount }

      context "when the input is for a discount" do
        let(:input) do
          {
            packables: [
              {quantity: '2', type: :product, name: 'product 1'},
              {quantity: '1', type: :product, name: 'product 2'}
            ],
            percentage_off: '50',
            or_more: true,
            shipping: true,
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(discount).to be_a(Discount)
            expect(discount.percentage_off).to eq(50)
            expect(discount.or_more).to eq(true)
            expect(discount.shipping).to eq(true)
            expect(discount.packables.first.packable).to be_a(Product)
            expect(discount.packables.first.name).to eq('product 1')
            expect(discount.packables.first.quantity).to eq(2)
            expect(discount.packables.last.packable).to be_a(Product)
            expect(discount.packables.last.name).to eq('product 2')
            expect(discount.packables.last.quantity).to eq(1)
          }
        end
      end
    end
  end
end
