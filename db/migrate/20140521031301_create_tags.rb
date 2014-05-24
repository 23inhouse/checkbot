class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :seller
      t.string :name
      t.boolean :generated

      t.timestamps
    end
  end
end
