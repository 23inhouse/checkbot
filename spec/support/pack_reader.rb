module PackReader
  def read_pack_notation(seller, winelist, line, options = {})
    pack_notation = line.match(/^\s*([^\+]+(?:\)(\+)?|\}|\]))(?: => (.+))?$/)
    return unless pack_notation

    packed_products_notation = pack_notation[1]
    or_more                  = pack_notation[2]
    discounts_notation       = pack_notation[3]

    attrs = { :seller => seller }
    attrs[:or_more] = or_more.present?
    attrs.merge!(read_discount_notation(discounts_notation)) if discounts_notation.present?
    if options[:mixed_pack] == true
      attrs[:name] = "mixed pack #{MixedPack.count + 1}"
      pack = MixedPack.new(attrs)
    else
      attrs[:winelist] = winelist if winelist.present?
      pack = Discount.new(attrs)
    end

    read_packed_products_notation(seller, pack, packed_products_notation) if packed_products_notation.present?

    pack
  end

private

  def read_discount_notation(discounts_notation)
    attrs = {}
    discounts_notation.split(' & ').each do |discounts|
      discount_notation = discounts.match(/((?:Sh|D))(?:\$(\d+(?:\.\d+)?)|-\$(\d+(?:\.\d+)?)|-(\d+)\%)/)
      # raise "syntax error in -> #{discounts}" unless discount_notation

      d_type           = discount_notation[1]
      d_price          = discount_notation[2]
      d_amount_off     = discount_notation[3]
      d_percentage_off = discount_notation[4]

      d_type = :discount if d_type == 'D'
      d_type = :shipping if d_type == 'Sh'

      key = :price if d_price.present?
      key = :amount_off if d_amount_off.present?
      key = :percentage_off if d_percentage_off.present?

      attrs["#{d_type}_#{key}".to_sym] = d_price || d_amount_off || d_percentage_off
    end

    attrs
  end

  def read_packed_products_notation(seller, pack, packed_products_notation)
    packed_products = []
    packed_products_notation.split(' & ').each do |products|
      product_notation = products.match(/((?:#|\$))(\d+)((?:P|T))\((.+)\)/)
      return [PackedProduct.new] unless product_notation

      match, pp_unit, pp_value, pp_type, pp_name = product_notation.to_a

      key = :quantity if pp_unit == '#'
      key = :amount if pp_unit == '$'

      packable = case pp_type
      when 'T' then seller.tags
      when 'P' then seller.wines + seller.mixed_packs
      end.select { |p| p.anchor == pp_name }.first

      packed_product = pack.packed_products.build(key => pp_value, :packable => packable)
      packed_products << packed_product
    end

    packed_products
  end
end
