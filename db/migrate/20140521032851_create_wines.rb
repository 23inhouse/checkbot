class CreateWines < ActiveRecord::Migration
  def change
    create_table :wines do |t|
      t.references :seller, index: true
      t.string :year, limit: 4
      t.string :name
      t.date :release_date
      t.decimal :price
      t.integer :number_of_cases_produced
      t.decimal :alcohol, precision: 4, scale: 2
      t.decimal :acid, precision: 4, scale: 2
      t.decimal :pH, precision: 4, scale: 2
      t.decimal :residual_sugar, precision: 6, scale: 2
      t.decimal :volatile_acids, precision: 4, scale: 1
      t.integer :sulphur
      t.text :tasting_notes
      t.text :vintage_report
      t.text :maturation
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean :disabled, default: false
      t.boolean :qualify_for_price_discount, default: true
      t.boolean :qualify_for_shipping_discount, default: true
      t.boolean :receive_price_discount, default: true
      t.boolean :receive_shipping_discount, default: true
      t.decimal :standard_drinks, precision: 4, scale: 2
      t.string :photo
      t.decimal :weight, precision: 5, scale: 3
      t.integer :ships_as
      t.string :bottle_name, default: 'bottle'

      t.timestamps
    end
  end
end
