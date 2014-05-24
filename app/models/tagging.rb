class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :product_listing
end
