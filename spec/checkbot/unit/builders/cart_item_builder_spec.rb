require 'spec_helper'

module Checkbot
  describe CartItemBuilder do
    let(:builder) { CartItemBuilder.new(input) }

    describe "#cart_item" do
      let(:cart_item) { builder.cart_item }

      context "when the input is a for an product" do
        let(:input) do
          {
            item_type: :product,
            item_name: 'item name',
            item_price: '20.50',
            price_rrp: '41',
            price_subtotal: '35',
            shipping_rrp: '10',
            shipping_subtotal: '0'
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(cart_item).to be_a(CartItem)
            expect(cart_item.item).to be_a(Product)
            expect(cart_item.name).to eq('item name')
            expect(cart_item.price).to eq(20.5)
            expect(cart_item.price_rrp).to be_a(Money)
            expect(cart_item.price_rrp).to eq(41)
            expect(cart_item.price_subtotal).to be_a(Money)
            expect(cart_item.price_subtotal).to eq(35)
            expect(cart_item.shipping_rrp).to be_a(Money)
            expect(cart_item.shipping_rrp).to eq(10)
            expect(cart_item.shipping_subtotal).to be_a(Money)
            expect(cart_item.shipping_subtotal).to eq(0)
          }
        end
      end

      context "when the input is a for an mixed pack" do
        let(:input) do
          {
            item_type: :mixed_pack,
            item_name: 'item name',
            item_price: '20.50',
            price_rrp: '41',
            price_subtotal: '35',
            shipping_rrp: '10',
            shipping_subtotal: '0'
          }
        end

        describe "it sets all the attributes" do
          specify {
            expect(cart_item).to be_a(CartItem)
            expect(cart_item.item).to be_a(MixedPack)
            expect(cart_item.name).to eq('item name')
            expect(cart_item.price).to eq(20.5)
            expect(cart_item.price_rrp).to be_a(Money)
            expect(cart_item.price_rrp).to eq(41)
            expect(cart_item.price_subtotal).to be_a(Money)
            expect(cart_item.price_subtotal).to eq(35)
            expect(cart_item.shipping_rrp).to be_a(Money)
            expect(cart_item.shipping_rrp).to eq(10)
            expect(cart_item.shipping_subtotal).to be_a(Money)
            expect(cart_item.shipping_subtotal).to eq(0)
          }
        end
      end
    end
  end
end
