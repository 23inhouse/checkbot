class CreateWinelists < ActiveRecord::Migration
  def change
    create_table :winelists do |t|
      t.references :seller, index: true

      t.timestamps
    end
  end
end
