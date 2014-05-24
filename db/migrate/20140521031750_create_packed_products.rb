class CreatePackedProducts < ActiveRecord::Migration
  def change
    create_table :packed_products do |t|
      t.references :pack, index: true
      t.references :packable, index: true
      t.string :packable_type
      t.decimal :amount
      t.integer :quantity

      t.timestamps
    end
  end
end
