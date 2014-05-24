class PackedProduct < ActiveRecord::Base
  belongs_to :pack
  belongs_to :packable, :polymorphic => true

  delegate :anchor, :full_name, :generated?, :price, :to => :packable, :allow_nil => true

  def merchandise?
    packable_type == 'Merchandise'
  end

  def mixed_pack?
    packable_type == 'Pack'
  end

  def product?
    wine? || mixed_pack? || merchandise?
  end

  def tag?
    packable_type == 'Tag'
  end

  def wine?
    packable_type == 'Wine'
  end
end
