class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.decimal :handling_charges

      t.timestamps
    end
  end
end
