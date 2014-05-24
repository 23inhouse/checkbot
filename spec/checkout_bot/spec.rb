# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  subject { @check_bot.new_cart }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(nil)
    @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
  }

  describe "Pre-existing scenarios (Scarpantoni-sh)" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #6T(2008)+ => D-5%
        #12T(2008)+ => D-10%
        #18T(wine)+ => Sh-100%
        #12P(2008 Merlot)+ => D-20%
      ))
    }
    context "when there are 12 Merlot and 6 Cabernet in the cart" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Cabernet $25)
          #12(2008 Merlot $20)
                     subtotal => $327
                     shipping => $0
        ))
      }
      describe "6 Cabernet get 10% off for 2008 vintage 12 pack while 12 Merlot get 20% for 2008 Merlot" do
        specify { check_cart(subject) }
      end
    end

    context "when there are 6 Merlot and 6 Cabernet in the cart" do
      before {
        @check_bot.stub(:shipping_charges).and_return(12.0.to_d)
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Cabernet $25)
          #6(2008 Merlot $20)
                     subtotal => $243
                     shipping => $12
        ))
      }
      describe "all bottles receive 10% off for 2008 vintage 12 pack" do
        specify { check_cart(subject) }
      end
    end

    context "when there are 12 Cleanskin and 6 Cabernet in the cart" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Cabernet $25)
          #12(1999 Cleanskin $5)
                     subtotal => $202.5
                     shipping => $0
        ))
      }
      describe "6 Cabernet get 5% for 2008 vintage 6 pack" do
        specify { check_cart(subject) }
      end
    end

    context "when there are 6 Museum and 6 Cabernet in the cart" do
      before {
        @check_bot.stub(:shipping_charges).and_return(12.0.to_d)
        @check_bot.cart = read_cart(@seller, %(
          #6(1999 Museum $45)
          #6(2008 Cabernet $25)
                     subtotal => $412.5
                     shipping => $12
        ))
      }
      describe "6 Cabernet get 5% off for 2008 vintage 6 pack" do
        specify { check_cart(subject) }
      end
    end

    context "when there are 12 Cabernet and 12 Merlot in the cart" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Cabernet $25)
          #12(2008 Merlot $20)
                     subtotal => $462
                     shipping => $0
        ))
      }
      describe "all Cabernet get 10% for 2008 vintage 12 pack and all Merlot get 20% off for 2008 Merlot 12 pack" do
        specify { check_cart(subject) }
      end
    end
  end

  describe "Probable winery discounts" do
    context "when there are many discounts and abstract mixed packs" do
      subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }
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
          [#12P(2020 Cleanskin)] [0000] => D$50
        ))
      }

      describe "12 2008 Merlot get 25% off for being 2008 (specific abstract pack)" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #12(2008 Merlot $20)
                       subtotal => $180
          ))
        }
        specify { check_cart(subject) }
      end

      describe "12 2008 Merlot get 25% off for being 2008 and 1 Merlot get 20% for being RED" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #12(2008 Merlot $20)
            #1(2008 Merlot $20)
                       subtotal => $196
          ))
        }
        specify { check_cart(subject) }
      end

      describe "Cabernet and Merlot get 25% off (RED), 6 Shiraz get 10% off (General Bulk)" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #6(2008 Cabernet $25)
            #6(2008 Merlot $20)
            #6(2008 Shiraz $15)
                       subtotal => $283.5
                       shipping => $12
          ))
        }
        specify { check_cart(subject) }
      end

      describe "6 Cabernet and 6 Merlot get 25% off (2008 12 pack), 6 Chard get 10% off (General Bulk) and Cleanskin's cost is $50" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #6(2008 Cabernet $25)
            #6(2008 Chardonnay $15)
            #6(2008 Melot Red FS $20)
            #1[#12P(2020 Cleanskin)] [
              #12(2020 Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #6(2008 Cabernet $25)
            #6(2008 Chardonnay $15)
            #6(2008 Melot Red FS $20)
            #1[#12P(2020 Cleanskin)] [
              #12(2020 Cleanskin $7)
            ]
                       subtotal => $333.5
                       shipping => $24
          ))
        }
        specify { check_cart(subject) }
      end

      describe "6 Cabernet is not enough to qualify for any discount" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #6(2008 Cabernet $25)
                       subtotal => $150
          ))
        }
        specify { check_cart(subject) }
      end

      describe "12 Cleanskin cost $50" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#12P(2020 Cleanskin)] [
              #12(2020 Cleanskin $7)
            ]
                       subtotal => $50
          ))

          read_cart_output(@seller, %(
            #1[#12P(2020 Cleanskin)] [
              #12(2020 Cleanskin $7)
            ]
                       subtotal => $50
          ))
        }
        specify { check_cart(subject) }
      end

      describe "12 Chardonnay get 25% off AND count toward 3 Cabernet and 3 Merlot getting 10% off (General Bulk)" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #3(2008 Cabernet $25)
            #3(2008 Merlot $20)
            #12(2009 Chardonnay $15)
                       subtotal => $256.5
                       shipping => $9
          ))
        }
        specify { check_cart(subject) }
      end
    end
  end

  context "when there are 3 shipping discounts with different fitness" do
    before {
      @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        #24T(wine)+ => Sh-50%
        #12T(2008)+ => Sh-100%
        #12T(wine)+ => Sh-25%
      ))
    }

    describe "on 12 2008 the strongest shipping discount is applied" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $20)
                     shipping => $0
        ))
      }
      specify { check_cart(subject, true) }
    end

    describe "12 2008 count towards 24 bottles of Wine for 50%" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $20)
          #12(1999 Chardonnay $15)
                     shipping => $6
        ))
      }
      specify { check_cart(subject, true) } # NOTE: 200 shipping error
    end

    describe "12 2008 bottles get 100% off and 24 other bottles get 50% off" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $20)
          #12(1999 Chardonnay $15)
          #12(1999 Riesling $15)
                     shipping => $12
        ))
      }
      specify { check_cart(subject, true) } # NOTE: 200 shipping error
    end
  end

  context "when a SMP has a tag" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#12P(2008 Merlot)] {special} => D$100
        #12T(special) => D-50%
      ))

      @check_bot.cart = read_cart_input(@seller, %(
        #1[#12P(2008 Merlot)] [
          #12(2008 Merlot $10)
        ]
      ))
    }

    describe "then discounts with that tag are applied" do
      before {
        read_cart_output(@seller, %(
          #1[#12P(2008 Merlot)] [
            #12(2008 Merlot $10)
          ]
                        subtotal => $50
        ))
      }
      specify { check_cart(subject) }
    end
  end
end
