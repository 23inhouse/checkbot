class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :seller, index: true
      t.string   :postcode
      t.decimal  :handling_charges
      t.decimal  :price_discount
      t.decimal  :price_rrp
      t.decimal  :price_subtotal
      t.integer  :quantity
      t.decimal  :shipping_charges
      t.decimal  :shipping_discount
      t.decimal  :shipping_rrp
      t.decimal  :shipping_subtotal
      t.decimal  :total
      t.decimal  :total_rrp

      t.timestamps
    end
  end
end
