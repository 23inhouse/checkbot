class CreateConditionalRewardPacks < ActiveRecord::Migration
  def change
    create_table :conditional_reward_packs do |t|
      t.integer :conditional_pack_id
      t.integer :reward_pack_id

      t.timestamps
    end
  end
end
