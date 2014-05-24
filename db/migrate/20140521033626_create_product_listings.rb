class CreateProductListings < ActiveRecord::Migration
  def change
    create_table :product_listings do |t|
      t.references :seller, index: true
      t.integer :listable_id
      t.string :listable_type
      t.integer :minimum_per_order
      t.integer :maximum_per_order
      t.integer :number_available
      t.integer :position
      t.boolean :hidden, default: false

      t.timestamps
    end
  end
end
