require 'spec_helper'

describe CheckoutBot do
  subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_shipping }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(nil)
    @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
  }

  context "SMP with a fixed price receives correct further non-fixed price discount" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#2P(2008 Merlot) & #2P(2008 Shiraz) & #2P(2008 Chardonnay)] => D$100
        #3T(wine)+ => D-20%
      ))

      @check_bot.cart = read_cart_input(@seller, %(
        #3[#2P(2008 Merlot) & #2P(2008 Shiraz) & #2P(2008 Chardonnay)] [
          #6P(2008 Chardonnay $20)
          #6P(2008 Merlot $20)
          #6P(2008 Shiraz $20)
        ]
      ))

      read_cart_output(@seller, %(
        #3[#2P(2008 Merlot) & #2P(2008 Shiraz) & #2P(2008 Chardonnay)] [
          #6P(2008 Chardonnay $20)
          #6P(2008 Merlot $20)
          #6P(2008 Shiraz $20)
        ]                               -> $300 ($240)
                               subtotal => $240
      ))
    }
    specify { check_cart(subject) }
  end

  context "when a SMP and a discount have the same wine" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D$100
        #12P(2008 Merlot) => D$400
      ))

      @check_bot.cart = read_cart_input(@seller, %(
        #12(2008 Merlot $40)
        #1[#6P(2008 Merlot)] [
          #6(2008 Merlot $40)
        ]
      ))
    }

    describe "then the discount is applied to the loose wine and the SMP gets it's discounted price" do
      before {
        read_cart_output(@seller, %(
          #12(2008 Merlot $40)   -> $480 ($400)
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $40)
          ]                      -> $100
                        subtotal => $500
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "when a SMP has a fixed price discount and there is a weaker 10% of any product discount" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#3P(2006 Merlot) & #3P(2007 Merlot) & #3P(2008 Merlot) & #3P(2009 Merlot)] {Merlot} => D$339
        #1M([#3P(2006 Merlot) & #3P(2007 Merlot) & #3P(2008 Merlot) & #3P(2009 Merlot)]) => D$294
        #12T(Merlot)+ => D-10%
      ))

      @check_bot.cart = read_cart_input(@seller, %(
        #1[#3P(2006 Merlot) & #3P(2007 Merlot) & #3P(2008 Merlot) & #3P(2009 Merlot)] [
          #3(2006 Merlot $24)
          #3(2007 Merlot $26)
          #3(2008 Merlot $29)
          #3(2009 Merlot $34)
        ]
      ))
    }

    describe "then the discount is applied to the loose wine and the SMP gets it's discounted price" do
      before {
        read_cart_output(@seller, %(
          #1[#3P(2006 Merlot) & #3P(2007 Merlot) & #3P(2008 Merlot) & #3P(2009 Merlot)] [
            #3(2006 Merlot $24)
            #3(2007 Merlot $26)
            #3(2008 Merlot $29)
            #3(2009 Merlot $34)
          ]                      -> $339 ($294)
                        subtotal => $294
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Probable winery discounts" do
    context "when there are many discounts and abstract mixed packs and one Christmas SMP" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        read_wines(@seller, %(
          N.V. Cleanskin $7 [0000]
          2008 Merlot $20 {Red, FS}
          2008 Cabernet $25 {Red, FS}
          2009 Shiraz $15 {Red, FS}
          2009 Chardonnay $15 {White, FS}
          2010 Riesling $20 {White, FS}
          1994 Museum $5 {FS}
          2010 Riesling $20 {White, FS}
        ))

        @check_bot.packs = read_packs(@seller, %(
          $200T(FS)+ => Sh-50%
          #24T(FS)+ => Sh-100%
          #12T(wine)+ => D-10%
          #12P(N.V. Cleanskin) [0000] => D$50
          #12P(2010 Riesling) => D-30%
          #12T(Red)+ => D-20%
          #12T(2008) => D-25%
          #12T(2009) => D-25%
          [#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] {wine, FS} => D$150 & Sh-100%
          #1T(White) => D-20% <- #12T(White)
        ))
      }

      describe "Christmas pack receives further General Bulk discount of 10% off" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
          ))

          read_cart_output(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
                       subtotal => $135
                       shipping => $0
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "Christmas Pack counts toward 6 Merlot getting 50% off shipping" do
        before {
          @check_bot.stub(:shipping_charges).and_return(24.0.to_d)
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
            #6(2008 Merlot $20)
          ))

          read_cart_output(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
            #6(2008 Merlot $20)
                       subtotal => $243
                       shipping => $3
          ))
        }
        specify { check_cart(subject, true) }
      end

      context "Christmas Pack counts toward 9 Chardonnay getting 20% price reward AND 50% off shipping" do
        before {
          @check_bot.stub(:shipping_charges).and_return(24.0.to_d)
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
            #9(2009 Chardonnay $15)
          ))

          read_cart_output(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
            #9(2009 Chardonnay $15)
                       subtotal => $256.5
                       shipping => $4.5
          ))
        }
        specify { check_cart(subject, true) }
      end

      context "Christmas Pack counts toward 18 Chardonnay getting free shipping (24 bottles)" do
        before {
          @check_bot.stub(:shipping_charges).and_return(24.0.to_d)
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]
            #12(2009 Chardonnay $15)
            #6(2009 Chardonnay $15)
          ))

          read_cart_output(@seller, %(
            #1[#2P(2008 Merlot) & #2P(2008 Cabernet) & #2P(2009 Shiraz) & #2P(2009 Chardonnay) & #2P(2010 Riesling) & #2P(1994 Museum)] [
              #2(1994 Museum $45)
              #2(2008 Cabernet $25)
              #2(2008 Merlot $20)
              #2(2009 Chardonnay $15)
              #2(2009 Shiraz $15)
              #2(2010 Riesling $20)
            ]                        -> $150 ($135)
            #18(2009 Chardonnay $15) -> $270 ($207)
                            subtotal => $342
                            shipping => $0
          ))
        }

        specify { check_cart(subject, true) } # NOTE : why does this one take so long?
      end
    end
  end
end
