class ConditionalRewardPack < ActiveRecord::Base
  belongs_to :condition, :foreign_key => 'conditional_pack_id', :class_name => 'Discount'
  belongs_to :reward, :foreign_key => 'reward_pack_id', :class_name => 'Discount'
end
