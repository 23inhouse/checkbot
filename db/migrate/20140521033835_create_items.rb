class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :cart, index: true
      t.references :winelist, index: true
      t.string :winelist_name
      t.decimal :price
      t.integer :quantity
      t.string :full_name
      t.integer :cart_id
      t.decimal :price_subtotal
      t.decimal :price_discount
      t.integer :price_pack_id
      t.string :price_pack_name
      t.decimal :price_rrp
      t.decimal :shipping_discount
      t.integer :shipping_pack_id
      t.string :shipping_pack_name
      t.decimal :shipping_rrp
      t.decimal :shipping_subtotal
      t.integer :specific_mixed_pack_id
      t.string :specific_mixed_pack_name
      t.integer :purchasable_id
      t.string :purchasable_type
      t.decimal :shipping_price, precision: 10, scale: 2
      t.decimal :specific_mixed_pack_quantity, precision: 10, scale: 4

      t.timestamps
    end
  end
end
