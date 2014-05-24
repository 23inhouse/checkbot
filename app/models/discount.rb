class Discount < Pack
  belongs_to :winelist, :touch => true
  has_many :conditional_reward_packs_as_condition, :foreign_key => 'reward_pack_id', :class_name => 'ConditionalRewardPack'
  has_many :conditional_reward_packs_as_reward, :foreign_key => 'conditional_pack_id', :class_name => 'ConditionalRewardPack'
  has_many :conditions, :through => :conditional_reward_packs_as_condition
  has_many :rewards, :through => :conditional_reward_packs_as_reward

  def amount_off
    discount_amount_off || shipping_amount_off
  end

  def fixed_price
    discount_price || shipping_price
  end

  def percentage_off
    discount_percentage_off || shipping_percentage_off
  end
end
