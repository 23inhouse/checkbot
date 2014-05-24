class PackedProducts < ActiveRecord::Base
  belongs_to :pack
  belongs_to :packable
end
