class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.references :seller, index: true
      t.references :winelist, index: true

      t.date :release_date
      t.text :description
      t.decimal :discount_amount_off
      t.decimal :discount_percentage_off
      t.decimal :discount_price
      t.string :name
      t.boolean :or_more, :defaults => false
      t.string :photo
      t.decimal :shipping_amount_off
      t.decimal :shipping_percentage_off
      t.decimal :shipping_price
      t.boolean :qualify_for_price_discount, default: true
      t.boolean :qualify_for_shipping_discount, default: true
      t.boolean :receive_price_discount, default: true
      t.boolean :receive_shipping_discount, default: true
      t.string :type

      t.timestamps
    end
  end
end
