module Checkbot
  class ProductContext
    include Contextable

    alias_method :products, :contextables

    def add(product)
      product.tags = product.tags.collect { |tag| context.add(:tag, tag) }.uniq

      if existing_product = find(product.name)
        existing_product.price = product.price if product.price > 0

        return existing_product
      end

      products << product
      product
    end
  end
end
