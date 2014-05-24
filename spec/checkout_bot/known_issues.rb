# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(nil)
    @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
  }

  context "when condition has shipping discount and reward has price discount" do
    before {
      @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        #1T(Shiraz) => D-50% <- #6T(Merlot) => Sh-50%
      ))
      @check_bot.cart = read_cart(@seller, %(
        #6(2008 Merlot $20)
        #1(2008 Shiraz $15)
                    subtotal => $127.5
                    shipping => $4
      ))
    }

    describe "then 6 Merlot (condition) receives 50% off shipping while 1 Shiraz (reward) receives 50% off price" do
      specify { check_cart(subject) } # NOTE: It cracks
    end
  end

  context "Fixed price or more amount discounts don't always work (because they are not valid)" do
    before {
      @check_bot.stub(:shipping_charges).and_return(nil)
      @check_bot.packs = read_packs(@seller, %(
        $200T(wine)+ => D$100
        #12T(2008)+ => D-80%
      ))
    }

    describe "12 Chardonnay and 12 Merlot operate as expected ($100 fixed price)" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #24(1999 Chardonnay $15)
          #12(2008 Merlot $20)
                      subtotal => $100
        ))
      }
      specify { check_cart(subject) }
    end

    describe "lowering the number of CHARD bottles changes the effective fitness of D$100 pack, thus making it does NOT crack" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #8(1999 Chardonnay $15)
          #14(2008 Merlot $20)
                      subtotal => $100
        ))
      }
      specify { check_cart(subject) } # NOTE: It cracks
    end
  end

  context "when there are TWO competing discounts (D$10 and D-90%)" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #3T(wine) => D$10
        #3T(Merlot) => D-90%
      ))
    }

    context "and all bottles qualify for stronger discount (90% off)" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #3(2008 Merlot $20)
                      subtotal => $6
        ))
      }

      describe "then 90% off wins" do
        specify { check_cart(subject) }
      end
    end

    context "and just one bottle qualify for stronger discount (90% off)" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #1(2008 Merlot $20)
          #2(2008 Shiraz $20)
                      subtotal => $10
        ))
      }

      describe "then the weaker discount wins (because it is better overall)" do
        specify { check_cart(subject) }
      end
    end

    context "and the prices of bottles are relatively low" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #1(2008 Merlot $4)
          #2(2008 Shiraz $4)
                     subtotal => $8.4
        ))
      }

      describe "then it fails to notice that 2*$4 is actually LESS than the $10" do
        specify { check_cart(subject) } # NOTE: It cracks
      end
    end
  end

  describe "when there are $2 and $38 bottles of wine" do
    before {
      @check_bot.cart = read_cart_input(@seller, %(
        #9(2010 Merlot $38)
        #9(2009 Merlot $2)
      ))
    }

    context "and the discount is greater than the $2 bottle ($20) - and there is another discount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(Merlot) => D$20
          #1T(wine)+ => D-0%
        ))
      }

      describe "then the $20 discount is distributed in a ratio matching the price of the bottles" do
        before {
          read_cart_output(@seller, %(
            #3(2009 Merlot $2)  -> $6 ($0.68965517)
            #6(2009 Merlot $2)  -> $12
            #9(2010 Merlot $38) -> $342 ($39.31034483)
                       subtotal => $52
          ))
        }

        specify { check_cart(subject) } # NOTE: It cracks
      end
    end
  end
end
