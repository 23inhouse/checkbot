require 'spec_helper'

describe CheckoutBot do
  subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(nil)
  }

  context "when there is a Specific Mixed Pack" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#3P(2008 Merlot)] => D$30
       ))
    }

    context "when adding a Wine" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #3(2008 Merlot $30)
        ))
      }

      describe "it is never added to a Specific Mixed Pack" do
        before {
          read_cart_output(@seller, %(
            #3(2008 Merlot $30) -> $90
                       subtotal => $90
          ))
        }

        specify { check_cart(subject) }
      end
    end

    context "when adding a Specific Mixed Pack" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#3P(2008 Merlot)] [
            #3(2008 Merlot $30)
          ]
        ))
      }

      describe "it is never broken apart" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#3P(2008 Merlot)] => D$10
           ))

          read_cart_output(@seller, %(
            #1[#3P(2008 Merlot)] [
              #3(2008 Merlot $30)
            ]                     -> $30
                         subtotal => $30
          ))
        }

        specify { check_cart(subject) }
      end
    end
  end

  context "when tallies are present" do
    before {
      @check_bot.stub(:shipping_charges).and_return(48.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        $100T(wine)+ => D-10%
        $100T(Merlot)+ => D-25%
        $100T(wine)+ => Sh-100%
      ))

      @check_bot.cart = read_cart(@seller, %(
        #8(2008 Cabernet $20)
        #8(2008 Merlot $20)
        #8(2008 Shiraz $20)
                     D Tally -> -$40
                     D Tally -> -$32
                    Sh Tally -> -$48
                    subtotal => $408
      ))
    }

    describe "then it shows and checks the tallies" do
      specify { check_cart(subject) }
    end
  end
end
