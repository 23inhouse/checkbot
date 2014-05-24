# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  before {
    @check_bot = CheckoutBot.new
    @check_bot.shipping_charge = 100
  }

  describe "new_cart" do
    subject { @check_bot.new_cart }
    it { should be(nil) }

    before {
      @seller = Seller.new
      @check_bot.seller = @seller
        @check_bot.stub(:shipping_charges).and_return(nil)
      @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
    }

    context "when a wine rounds to an even number" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $16.667) -> $200.004
                          subtotal => $200.004
        ))
      }
      specify { check_cart(subject) }
    end

    context "when there's one wine that gets a discount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(Merlot) => D-20%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $25) -> $150 ($120)
          #6(2008 Shiraz $20) -> $120
                     subtotal => $240
        ))
      }
      specify { check_cart(subject) }
    end

    context "when a wine is split over different packs" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #5T(Merlot) => D-20%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #5(1999 Merlot $25) -> $125 ($100)
          #2(2012 Merlot $25) -> $50
                     subtotal => $150
        ))
      }
      specify { check_cart(subject) }
    end

    context "when many have different prices" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #2(2008 Cabernet $25)  -> $50
          #2(2008 Merlot $35)    -> $70
          #1(2008 Shiraz $50)    -> $50
          #3(2008 Sparkling $10) -> $30
                        subtotal => $200
        ))
      }
      specify { check_cart(subject) }
    end

    context "when there's an abstract pack with many different wines" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #8T(2008) => D-10%
          #5T(Cabernet) => D-20%
        ))

        @check_bot.cart = read_cart(@seller, %(
          #1(2007 Shiraz $50)
          #2(2008 Cabernet $25)
          #2(2008 Merlot $35)
          #1(2008 Shiraz $50)
          #3(2008 Sparkling $10)
          #5(2008 Cabernet $25)
                        subtotal => $330
        ))
      }
      specify { check_cart(subject) }
    end

    context "when there's one wine that gets a shipping discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.packs = read_packs(@seller, %(
          #6T(Merlot) => Sh-20%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $25) -> Sh $6 ($4.8)
          #6(2008 Shiraz $20) -> Sh $6
                     shipping => $10.8
        ))
      }
      specify { check_cart(subject, true) }
    end

    context "when there's an abstract pack" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(Merlot) => D$10
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $25) -> $150 ($11.111111111)
          #6(2009 Merlot $20) -> $120 ($8.888888889)
                     subtotal => $20
        ))
      }
      specify { check_cart(subject) }
    end

    context "when there are 2 discounts with the same percentage off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(Merlot) => D-5%
          #6T(2009) => D-15%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $25) -> $150 ($142.5)
          #6(2009 Merlot $20) -> $120 ($102)
        ))
      }
      specify { check_cart(subject) }
    end

    context "Cart sorting and compacting" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => D-10%
          #6T(Shiraz)+ => D-25%
          #6T(Cabernet)+ => D-25%
          #1T(wine)+ => Sh-50%
          #6T(Shiraz) => Sh-100%
          #3T(Merlot) => D-50%
        ))

        @check_bot.cart = read_cart(@seller, %(
          #3(1999 Sparkling $125) -> $375 ($337.5)
          #2(2008 Merlot $19)     -> $38 ($34.2)
          #8(2008 Cabernet $24)   -> $192 ($144)
          #6(2008 Merlot $19)     -> $114 ($57)
          #6(2008 Shiraz $18)     -> $108 ($81)
          #2(2008 Shiraz $18)     -> $36 ($27)
                         subtotal => $680.7
        ))
      }
      specify { check_cart(subject) }
    end

    context "when there are a lot of packs" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6P(2008 Merlot) & #6P(2008 Shiraz)+ => Sh-50%
          #6T(Whites) & #6T(Reds)+ => Sh$0
          #6P(2008 Merlot) & #6P(2008 Shiraz)+ => Sh-$10
          #12T(wine)+ => D-20%
          #3T(Whites)+ => D-$18
          #12T(wine)+ => Sh-50%
          #12T(Reds)+ => Sh-$17
          $200T(Reds)+ => D-10%
          $200T(Reds)+ => D-$8
          $200T(Reds)+ => Sh-10%
          $200T(wine)+ => Sh-$20
          #6P(2009 Merlot)+ => D-33%
          #6P(2010 Merlot)+ => D-$3
          #6P(2011 Merlot)+ => Sh-20%
          #6P(2012 Merlot)+ => Sh-$10
          $200P(2007 Merlot)+ => D-10%
          $200P(2006 Merlot)+ => D-$8
          $200P(2005 Merlot)+ => Sh-10%
          $200P(2004 Merlot)+ => Sh-$7
          #12T(Reds) => D-30%
          #12T(Reds) => D$6
          #12T(Reds) => D-$8
          #12T(Reds) => Sh-10%
          #12T(Reds) => Sh$5
          #12T(Reds) => Sh-$7
          $200T(Reds) => D-10%
          $200T(Reds) => D-$8
          $200T(Reds) => Sh-10%
          $200T(Reds) => Sh-$7
          #6P(2008 Merlot) => D-10%
          #6P(2009 Merlot) => D$6
          #6P(2010 Merlot) => D-$8
          #6P(2011 Merlot) => Sh-10%
          #6P(2012 Merlot) => Sh$5
          #6P(2013 Merlot) => Sh-$7
          $200P(2008 Merlot) => D$5
          $200P(2007 Merlot) => D-$8
          $200P(2006 Merlot) => Sh$5
          $200P(2005 Merlot) => Sh-$7
          #6P(2008 Merlot) & #6P(2008 Shiraz) => Sh-50%
          #6P(2008 Merlot) & #6P(2008 Shiraz) => Sh-$20
          #6T(Whites) & #6T(Reds) => Sh$0
        ))
      }

      context "when the user starts shopping" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #4(2008 Cabernet $20)
            #2(2008 Chardonnay $20)
            #6(2008 Merlot $20)
            #2(2008 Reisling $20)
            #4(2008 Shiraz $20)
          ))
        }

        specify { check_cart(subject) }
      end
    end
  end
end
