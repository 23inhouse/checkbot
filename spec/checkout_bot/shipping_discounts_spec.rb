# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  subject { @check_bot.new_cart }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
    @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
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
          #6T(red)+ => Sh-20%
          #6T(white)+ => Sh-15%
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Merlot $20)
          #8(2008 Chardonnay $15)
                         shipping => $13.2
        ))
      }
      specify { check_cart(subject, true) }
    end

    context "when the discount is an amount off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(red)+ => Sh-$3
          #6T(white)+ => Sh-$2
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Merlot $20)
          #8(2008 Chardonnay $15)
                         shipping => $11
        ))
      }
      specify { check_cart(subject, true) }
    end

    context "when the discount is a fixed amount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(red)+ => Sh$5
          #6T(white)+ => Sh$4
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Merlot $20)
          #8(2008 Chardonnay $15)
                         shipping => $9
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "amount packs" do
    context "when the discount is a percentage off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          $100T(red)+ => Sh-20%
          $100T(white)+ => Sh-15%
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Chardonnay $15)
          #8(2008 Merlot $20)
                         shipping => $13.2
        ))
      }
      specify { check_cart(subject, true) }
    end

    context "when the discount is an amount off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          $100T(red)+ => Sh-$5
          $100T(white)+ => Sh-$4
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Chardonnay $15)
          #8(2008 Merlot $20)
                         shipping => $7
        ))
      }
      specify { check_cart(subject, true) }
    end

    context "when the discount is a fixed amount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          $100T(red)+ => Sh$5
          $100T(white)+ => Sh$4
        ))

        @check_bot.cart = read_cart(@seller, %(
          #8(2008 Chardonnay $15)
          #8(2008 Merlot $20)
                         shipping => $9
        ))
      }
      specify { check_cart(subject, true) }
    end
  end
end
