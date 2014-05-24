DEBUG = false
DEBUG_SPANNER = false
# DEBUG = true
# DEBUG_SPANNER = true

class ViewContext
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
end

def read_cart_input(seller, cart_string = '')
  @input_cart = read_cart(seller, cart_string, false)
end

def read_cart_output(seller, cart_string = '')
  read_cart(seller, cart_string, true)
end

def read_cart(seller, cart_string = '', set_spec_cart = nil)
  if DEBUG == true
    puts
    if set_spec_cart.nil?
      puts '    Cart'
    else
      puts '    Cart' + (set_spec_cart == true ? ' (output)' : ' (input)')
    end
    puts cart_string
  end

  set_spec_cart = true if set_spec_cart.nil?

  @items_in_pack = false

  # add the default wine tag
  seller.tags.build(:name => 'wine') unless seller.tags.collect(&:name).include?('wine')

  cart = Cart.new(:seller => seller)
  cart_string.lines.each do |line|
    next if line.chomp!.blank?
    if detail = line.match(/\#([^\(]+)\(([^\$]+) \$([^\) ]+)\)(?:[\s]+(?:(sh) )?-> \$([^ ]+)(?: \(\$(.+)\))?)?/)
      # p detail

      @items_in_pack ||= false

      wine = seller.wines.select {|w| w.full_name == detail[2] }.first
      if wine.present?
        wine.price = detail[3]
      else
        year_name = detail[2].split(' ', 2)
        year = year_name[0]
        name = year_name[1]
        wine = seller.wines.build(:year => year, :name => name, :price => detail[3].to_d)
      end
      # wine.tags << seller.tags.first # default wine tag
      tags = ((wine.tags || []) + [seller.tags.first]).uniq
      wine.stub(:tags).and_return(tags)

      if @items_in_pack
        if detail[4] == 'sh'
          item = Item.new(:purchasable => wine, :price => wine.price, :quantity => detail[1], :full_name => wine.full_name, :shipping_rrp => (detail[5] || nil), :shipping_subtotal => (detail[6] || detail[5] || nil), :specific_mixed_pack => @items_in_pack[1])
        else
          item = Item.new(:purchasable => wine, :price => wine.price, :quantity => detail[1], :full_name => wine.full_name, :price_rrp => (detail[5] || nil), :price_subtotal => (detail[6] || detail[5] || nil), :specific_mixed_pack => @items_in_pack[1])
        end
        @items_in_pack[2] ||= []
        @items_in_pack[2] << item
      else
        if detail[4] == 'sh'
          item = cart.items.build(:purchasable => wine, :price => wine.price, :quantity => detail[1], :full_name => wine.full_name, :shipping_rrp => (detail[5] || nil), :shipping_subtotal => (detail[6] || detail[5] || nil))
        else
          item = cart.items.build(:purchasable => wine, :price => wine.price, :quantity => detail[1], :full_name => wine.full_name, :price_rrp => (detail[5] || nil), :price_subtotal => (detail[6] || detail[5] || nil))
        end
      end

      wine.full_name.split(' ').each do |tag|
        seller.tags.build(:name => tag) unless seller.tags.collect(&:name).include?(tag)
      end

    # Start the pack
    elsif detail = line.match(/\#(.+)\[([^\]]+)\] \[/)
      if pack = read_pack(@seller, detail[2], false, true)
        @items_in_pack = [detail[1], pack]
      else
        raise "couldn't find this pack: #{detail[2]}"
      end

    # End the pack
    elsif @items_in_pack.is_a?(Array) && detail = line.match(/\](?:[\s]+-> \$([^ ]+)(?: \(\$(.+)\))?)?/)
      if set_spec_cart == true
        pack = @items_in_pack[1]
        cart.items.build(:purchasable => pack, :price => pack.discount_price, :quantity => @items_in_pack[0], :full_name => pack.name, :price_rrp => (detail[1] || nil), :price_subtotal => (detail[2] || detail[1] || nil))
      end
      @items_in_pack[2].each do |item|
        cart.items << item
      end
      @items_in_pack = false

    # Tally discounts
    elsif detail = line.match(/((?:Sh|D)) Tally -> -\$(\d+(?:.\d+)?)/)
      if detail[1] == 'Sh'
        cart.discount_tallies.build(:shipping_discount => detail[2])
      else
        cart.discount_tallies.build(:price_discount => detail[2])
      end

    elsif detail = line.match(/subtotal \=> \$(.*)/)
      cart.price_subtotal = detail[1]
    elsif detail = line.match(/total \=> \$(.*)/)
      cart.total = detail[1]
    elsif detail = line.match(/shipping \=> \$(.*)/)
      cart.shipping_subtotal = detail[1]
    else
      raise "syntax error in -> #{line}"
    end
  end

  if seller.tags
    seller.wines.each do |wine|
      seller.tags.each do |tag|
        if wine.full_name.split(' ').include?(tag.name)
          # wine.tags << tag
          tags = ((wine.tags || []) + [tag]).uniq
          wine.stub(:tags).and_return(tags)
        end
      end
    end
  end

  if set_spec_cart == true
    @spec_cart = Cart.new(cart.attributes)
    cart.items.each { |item| @spec_cart.items << item.clone }
    @spec_cart.discount_tallies = cart.discount_tallies.dup
    cart.discount_tallies = []
  end
  cart
end

def read_packs(seller, pack_string = '')

  if DEBUG_SPANNER == true
    if pack_string[' => Sh'].present?
      pack_string << "\n            #1T(wine) => Sh$10000\n            #1T(wine) => Sh-$0\n            #1T(wine) => Sh-0%"
      pack_string << "\n            #1T(wine)+ => Sh$10000\n            #1T(wine)+ => Sh-$0\n            #1T(wine)+ => Sh-0%"
    end
    pack_string << "\n            #1T(wine) => D$10000\n            #1T(wine) => D-$0\n            #1T(wine) => D-0%"
    pack_string << "\n            #1T(wine)+ => D$10000\n            #1T(wine)+ => D-$0\n            #1T(wine)+ => D-0%"
  end

  if DEBUG == true
    puts
    puts '    Packs'
    puts pack_string
  end

  # add the default wine tag
  seller.tags.build(:name => 'wine') unless seller.tags.collect(&:name).include?('wine')

  pack_string.lines.each do |line|
    next if line.chomp!.blank?
    reward_condition = line.split(' <- ')

    # rewards or normal pack
    reward = read_pack(seller, reward_condition[0])

    if reward_condition[1].present?
      condition = read_pack(seller, reward_condition[1])
      reward.conditions << condition
      condition.rewards << reward
    end
  end

  seller.discounts + seller.specific_mixed_packs
end

def read_pack(seller, line, create = true, smp_only = false)
  line.strip!

  detail = line.match(/^\[([^\]]+)\](\+)?(?: \[(\d{4})\])?(?: \{([^}]+)\})?(?: => (.+))?$/)
  smp = true if detail.present?
  detail ||= line.match(/^([^\)]+(?:\)[^\)]+)?(?:\)[^\)]+)?(?:\)[^\)]+)?(?:\)[^\)]+)?(?:\)[^\)]+)?\))(\+)?(?: \[(\d{4})\])?(?: \{([^}]+)\})?(?: => (.+))?$/)

  raise "syntax error in -> #{line}" unless detail

  products  = detail[1]
  or_more   = detail[2]
  flags     = detail[3]
  tags      = detail[4]
  discounts = detail[5]

  attrs = {}
  attrs[:or_more] = or_more.present?

  # price and shipping discounts
  if discounts.present?
    discounts.split(' & ').each do |discounts|
      discount = discounts.match(/((?:Sh|D))(?:\$(\d+(?:.\d+)?)|-\$(\d+(?:.\d+)?)|-(\d+(?:.\d+)?)\%)/)
      raise "syntax error in -> #{discounts}" unless discount
      if discount[1] == 'Sh'
        if discount[2].present?
          attrs[:shipping_price] = discount[2].to_d
        elsif discount[3].present?
          attrs[:shipping_amount_off] = discount[3].to_d
        elsif discount[4].present?
          attrs[:shipping_percentage_off] = discount[4].to_d
        end
      elsif discount[1] == 'D'
        if discount[2].present?
          attrs[:discount_price] = discount[2].to_d
        elsif discount[3].present?
          attrs[:discount_amount_off] = discount[3].to_d
        elsif discount[4].present?
          attrs[:discount_percentage_off] = discount[4].to_d
        end
      end
    end
  end

  if smp == true
    attrs[:description] = '[' + products + ']'
    if create == true
      pack = seller.specific_mixed_packs.build(attrs)
    else
      pack = MixedPack.new(attrs)
    end

    pack.stub(:tags).and_return([seller.tags.first])
  else
    if create == true
      pack = seller.discounts.build(attrs)
    else
      pack = Discount.new(attrs)
    end
  end

  # packed products
  prod = products.match(/^#\d+M\((.+)\)/)
  if prod = products.match(/^#\d+M\((.+)\)/)
    products = [prod[1]]
    packable = seller.specific_mixed_packs.select { |mp| mp.description == prod[1] }.first
    raise "syntax error in -> #{product}" unless packable

    packed_product = pack.packed_products.build(:quantity => 1)
    packed_product.packable = packable
  else
    products = products.split(' & ').each do |products|
      attrs = {}
      product = products.match(/(\[)?((?:#|\$))(\d+)((?:P|T|M))\((.+)\)/)
      raise "syntax error in -> #{products}" unless product

      if product[2] == '#'
        attrs[:quantity] = product[3].to_i
      elsif product[2] == '$'
        attrs[:amount] = product[3].to_d
      end
      if product[4] == 'P'
        packable = seller.wines.select { |w| w.full_name == product[5] }.first
          year_name = product[5].split(' ', 2)
          year = year_name[0]
          name = year_name[1]
        packable = seller.wines.build(:year => year, :name => name, :price => 9.99) unless packable.present?
      elsif product[4] == 'T'
        packable = seller.tags.select { |t| t.name == product[5] }.first
        packable = seller.tags.build(:name => product[5]) unless packable.present?
      end
      raise "syntax error in -> #{product}" unless packable

      packed_product = pack.packed_products.build(attrs)
      packed_product.packable = packable
    end
  end

  pack.name = DiscountDecorator.new(pack).default_name if pack.name.nil?

  if flags.present?
    pack.qualify_for_price_discount = (flags[0] == '1')
    pack.receive_price_discount = flags[1] == '1'
    pack.qualify_for_shipping_discount = flags[2] == '1'
    pack.receive_shipping_discount = flags[3] == '1'
  end

  if tags.present?
    tags.split(', ').each do |tag_name|
      tag = seller.tags.select { |t| t.name == tag_name }.first
      tag = seller.tags.build(:name => tag_name) unless tag.present?
      # pack.tags << tag
      tags = ((pack.tags || []) + [tag]).uniq
      pack.stub(:tags).and_return(tags)
    end
  end

  return pack if create == true

  all_packs = seller.specific_mixed_packs
  all_packs << seller.packs if smp_only != true
  all_packs.select { |p| p.name =~ /#{pack.name}/ }.first
end

def read_wines(seller, wine_string = '')
  if DEBUG == true
    puts
    puts '    Wine'
    puts wine_string
  end

  @items_in_pack = false

  # add the default wine tag
  seller.tags.build(:name => 'wine') unless seller.tags.collect(&:name).include?('wine')

  wine_string.lines.each do |line|
    next if line.chomp!.blank?
    detail = line.match(/^\s*(.+) (.+) \$([^ ]+)(?: \[([^\]]+)\])?(?: \{([^\}]+)\})?/)
    raise "syntax error in -> #{line}" unless detail

    wine = seller.wines.select { |wine| wine.full_name == detail[1] + ' ' + detail[2] }.first
    wine ||= seller.wines.build(:year => detail[1], :name => detail[2], :price => detail[3])

    if detail[4].present?
      wine.qualify_for_price_discount = (detail[4][0] == '1')
      wine.receive_price_discount = detail[4][1] == '1'
      wine.qualify_for_shipping_discount = detail[4][2] == '1'
      wine.receive_shipping_discount = detail[4][3] == '1'
    end

    if detail[5].present?
      detail[5].split(', ').each do |tag_name|
        tag = seller.tags.select { |t| t.name == tag_name }.first
        tag = seller.tags.build(:name => tag_name) unless tag.present?
        if !wine.tags.include?(tag)
          # wine.tags << tag
          tags = ((wine.tags || []) + [tag]).uniq
          wine.stub(:tags).and_return(tags)
        end
      end
    end
  end
end

def check_cart(cart, shipping = false)

  if DEBUG == true
    if cart.seller.tags
      puts '    Tags'
      puts '          All tags: ' + cart.seller.tags.collect(&:name).join(', ')
      puts
      cart.seller.wines.each do |wine|
        tags = wine.tags ? wine.tags.collect(&:name).sort.join(', ') : ''
        puts (wine.full_name + ' -> ').rjust(35) + tags
      end
      cart.seller.mixed_packs.each do |mixed_pack|
        tags = mixed_pack.tags ? mixed_pack.tags.collect(&:name).sort.join(', ') : ''
        puts (mixed_pack.full_name + ' -> ').rjust(35) + tags
      end
    end

    puts
    puts '==================== new cart ===================='
    puts

    cart.items.each do |item|
      if DEBUG == true
        if item.purchasable.is_a?(Pack)
          line_output = ('          #'+item.quantity.to_s+'['+"#{item.full_name}"+' $'+item.purchasable.full_price.to_s+' ($'+item.price.to_s+')]').ljust(50) + '-> $' +(item.price * item.quantity).to_s.ljust(6)
          line_output << (' ($'+item.price_subtotal.to_s+')').ljust(17) + "#{item.price_pack_name}" if item.price_subtotal.to_f < (item.price * item.quantity).to_f
          puts line_output
        else

          if item.specific_mixed_pack.present?
            line_output = ('            #'+item.quantity.to_s+'('+"#{item.full_name}"+' $'+(shipping == true ? item.shipping_price : item.price).round(2).to_s+')').ljust(40)
          else
            line_output = ('          #'+item.quantity.to_s+'('+"#{item.full_name}"+' $'+(shipping == true ? item.shipping_price : item.price).round(2).to_s+')').ljust(50)+'-> '
            # line_output << (' ($'+item.price_subtotal.to_s+')').ljust(17) + "#{item.price_pack_name}" if item.price_pack.present?
          end

          if shipping == true
            line_output << 'sh $'+(item.shipping_rrp.to_s).ljust(6)
            line_output << (' ($'+item.shipping_subtotal.to_s+')').ljust(17) + "#{item.shipping_pack_name}" if item.shipping_pack.present?
          else
            if item.specific_mixed_pack.present?
              line_output << ('[$'+item.price_rrp.round(2).to_s+']').rjust(9)
              line_output << ' '.ljust(11)
            else
              line_output << '$'+item.price_rrp.to_s.ljust(6)
            end
            line_output << (' ($'+item.price_subtotal.round(2).to_s+')').ljust(17) + "#{item.price_pack_name}" if item.price_pack.present?
          end

          puts line_output
        end
      end
    end

    cart.discount_tallies.each do |t|
      puts "D Tally   -$".rjust(54) + "#{t.price_discount}".ljust(10) + "#{t.price_pack_name}" if t.price_pack.present?
      puts "Sh Tally   -$".rjust(54) + "#{t.shipping_discount}".ljust(10) + "#{t.shipping_pack_name}" if t.shipping_pack.present?
    end

    puts 'subtotal => $'.rjust(54)+cart.price_subtotal.to_s
    puts 'shipping => $'.rjust(54)+cart.shipping_subtotal.to_s
    puts 'total => $'.rjust(54)+cart.total.to_s
    puts '--------------------'
  end

  @spec_cart.items.each_with_index do |item, i|
    cart.items[i].full_name.should eq(item.full_name)
    cart.items[i].quantity.should eq(item.quantity)
    if item.price_rrp
      cart.items[i].price_rrp.should eq(item.price_rrp.to_d)
      if item.price_subtotal
        cart.items[i].price_subtotal.should eq(item.price_subtotal.to_d)
        cart.items[i].price_discount.should eq(item.price_rrp.to_d - item.price_subtotal.to_d)
      end
    end
    if item.shipping_rrp
      cart.items[i].shipping_rrp.should eq(item.shipping_rrp.to_d)
      if item.shipping_subtotal
        cart.items[i].shipping_subtotal.should eq(item.shipping_subtotal.to_d)
        cart.items[i].shipping_discount.should eq(item.shipping_rrp.to_d - item.shipping_subtotal.to_d)
      end
    end
  end

  # tally check
  @spec_cart.discount_tallies.each_with_index do |tally, i|
    cart.discount_tallies[i].price_pack.should eq(tally.price_pack) if tally.price_pack.present?
    cart.discount_tallies[i].price_pack_name.should eq(tally.price_pack_name) if tally.price_pack_name.present?
    cart.discount_tallies[i].price_discount.should eq(tally.price_discount) if tally.price_discount.present?
    cart.discount_tallies[i].shipping_pack.should eq(tally.shipping_pack) if tally.shipping_pack.present?
    cart.discount_tallies[i].shipping_pack_name.should eq(tally.shipping_pack_name) if tally.shipping_pack_name.present?
    cart.discount_tallies[i].shipping_discount.should eq(tally.shipping_discount) if tally.shipping_discount.present?
  end

  cart.price_subtotal.should eq(@spec_cart.price_subtotal.to_d) if @spec_cart.read_attribute(:price_subtotal)
  cart.shipping_subtotal.should eq(@spec_cart.shipping_subtotal.to_d) if @spec_cart.read_attribute(:shipping_subtotal)
  cart.total.should eq(@spec_cart.total.to_d) if @spec_cart.read_attribute(:total)
end
