class CreateDiscountTallies < ActiveRecord::Migration
  def change
    create_table :discount_tallies do |t|
      t.references :cart, index: true
      t.integer :price_pack_id
      t.string :price_pack_name
      t.decimal :price_discount
      t.integer :shipping_pack_id
      t.string :shipping_pack_name
      t.decimal :shipping_discount

      t.timestamps
    end
  end
end
