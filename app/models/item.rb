class Item < ActiveRecord::Base
  belongs_to :cart
  belongs_to :price_pack, :class_name => 'Pack'
  belongs_to :purchasable, :polymorphic => true
  belongs_to :shipping_pack, :class_name => 'Pack'
  belongs_to :specific_mixed_pack, :class_name => 'Pack'
  belongs_to :winelist

  delegate :seller, :to => :cart
  delegate :bottle_name, :full_price, :ships_as, :to => :purchasable
end
