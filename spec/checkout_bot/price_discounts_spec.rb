# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  subject { @check_bot.new_cart }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(100.0.to_d)

  }

  before {
    read_wines(@seller, %(
      2008 Merlot $20 {red}
      2008 Chardonnay $15 {white}
    ))
  }

  context "quantity packs" do
    context "when the discount is a percentage off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(red)+ => D-20%
          #6T(white)+ => D-15%
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Merlot $20)
          #8(2008 Chardonnay $15)
                                 subtotal => $230
        ))
      }
      specify { check_cart(subject) }
    end

    context "when the discount is an amount off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(red)+ => D-$20
          #6T(white)+ => D-$15
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Merlot $20)
          #8(2008 Chardonnay $15)
                                 subtotal => $245
        ))
      }
      specify { check_cart(subject) }
    end

    context "when the discount is a fixed amount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(red)+ => D$100
          #6T(white)+ => D$90
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Merlot $20)       -> $160 ($100)
          #8(2008 Chardonnay $15) -> $120 ($90)
                                 subtotal => $190
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "amount packs" do
    context "when the discount is a percentage off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          $100T(red)+ => D-20%
          $100T(white)+ => D-15%
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Chardonnay $15)
          #8(2008 Merlot $20)
                                 subtotal => $230
        ))
      }
      specify { check_cart(subject) }
    end

    context "when the discount is an amount off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          $100T(red)+ => D-$20
          $100T(white)+ => D-$15
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Chardonnay $15)
          #8(2008 Merlot $20)
                                 subtotal => $245
        ))
      }
      specify { check_cart(subject) }
    end

    context "when the discount is a fixed amount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          $100T(red)+ => D$100
          $100T(white)+ => D$90
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Chardonnay $15)   -> $120
          #8(2008 Merlot $20)       -> $160
                           subtotal => $190
        ))
      }
      specify { check_cart(subject) }
    end
  end
end
