require 'spec_helper'

module Checkbot
  describe Interpreter do
    let(:interpreter) { Interpreter.new }
    let(:input) {
      %(
        prod1 $20 { wine }
        product 4 $35 { wine, tag }

        mixed pack name [#2P(prod1) & #1P(prod2)]

        $200T(tag)+            -> D-50%
        #2P(product 5 $99)+    -> D-50%
        #1M(mixed pack name)   -> D$79

        #2(mixed pack name)    -> $200 ($158)
        #6(product 3 $25)      -> $150 ($120)
        #6(product 4)
                      discount => -$50
                   sh discount => -$20
                      subtotal => $243
                      shipping => $12
                         total => $12
      )
    }

    before { interpreter.interpret(input) }

    describe "#cart_items" do
      subject { interpreter.cart_items }
      it {
        is_expected.to eq([
          {quantity: 2, item_type: :product, item_name: 'mixed pack name', item_price: nil, price_rrp: '200', price_subtotal: '158'},
          {quantity: 6, item_type: :product, item_name: 'product 3', item_price: '25', price_rrp: '150', price_subtotal: '120'},
          {quantity: 6, item_type: :product, item_name: 'product 4', item_price: nil}
        ])
      }
    end

    describe "#discounts" do
      subject { interpreter.discounts }
      it {
        is_expected.to eq([
          {packables: [{amount: '200', type: :tag, name: 'tag'}], shipping: false, or_more: true, percentage_off: '50'},
          {packables: [{quantity: '2', type: :product, name: 'product 5 $99'}], shipping: false, or_more: true, percentage_off: '50'},
          {packables: [{quantity: '1', type: :mixed_pack, name: 'mixed pack name'}], shipping: false, or_more: false, fixed_price: '79'}
        ])
      }
    end

    describe "#mixed_packs" do
      subject { interpreter.mixed_packs }
      it {
        is_expected.to eq([
          {
            name: 'mixed pack name', packables: [
              {quantity: '2', type: :product, name: 'prod1'},
              {quantity: '1', type: :product, name: 'prod2'}
            ]
          }
        ])
      }
    end

    describe "#products" do
      subject { interpreter.products }
      it {
        is_expected.to eq([
          {name: 'prod1', price: '20', tags: [{name: 'wine'}]},
          {name: 'product 4', price: '35', tags: [{name: 'wine'}, {name: 'tag'}]},
          {name: 'product 5', price: '99'}, {name: 'product 3', price: '25'},
        ])
      }
    end

    describe "#tags" do
      subject { interpreter.tags }
      it {
        is_expected.to eq([{name: 'wine'}, {name: 'wine'}, {name: 'tag'}])
      }
    end

    describe "#tallies" do
      subject { interpreter.tallies }
      it {
        is_expected.to eq([{amount: '50'}, {amount: '20', shipping: true}])
      }
    end

    describe "#totals" do
      subject { interpreter.totals }
      it {
        is_expected.to eq([{subtotal: '243'}, {shipping: '12'}, {total: '12'}])
      }
    end
  end
end
