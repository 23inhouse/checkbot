class MixedPack < Pack
  has_many :discounts, :through => :discounted_products
  has_many :discounted_products, :as => :packable

  delegate :winery_website_wine_page, :winery_website, :to => :seller
end
