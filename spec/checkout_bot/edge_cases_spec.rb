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

  describe "Ficticious scenarios: what is going to happen" do
    context "when there is a strange discount/SMP, such as: #6T(Reds) and #6P(Merlot) => D-10%" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(2008) & #6P(1999 Merlot) => D-10%
        ))
      }

      describe "3 shiraz, 3 cabernet and 6 merlot all receive 10% off" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #6(1999 Merlot $19)
            #3(2008 Cabernet $24)
            #3(2008 Shiraz $18)
                       subtotal => $216
          ))
        }
        specify { check_cart(subject) }
      end

      describe "3 shiraz, 3 cabernet and 5 merlot don't receive any discount" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #5(1999 Merlot $19)
            #3(2008 Cabernet $24)
            #3(2008 Shiraz $18)
                       subtotal => $221
          ))
        }
        specify { check_cart(subject) }
      end
    end
  end

  describe "SMP interaction with other discounts" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }
    context "when 6 Cab and 6 Chard SMP is at 20% off and there are General Bulk discount and 2008 vintage discount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          [#6P(2008 Cabernet) & #6P(1999 Chardonnay)] => D-20%
          #12T(2008)+ => D-25%
          #12T(wine)+ => D-10%
        ))
      }
      context "and there is SMP and 6 Merlot in the cart" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#6P(2008 Cabernet) & #6P(1999 Chardonnay)] [
              #6(2008 Cabernet $15)
              #6(1999 Chardonnay $25)
            ]
            #6(2008 Merlot $20)
          ))
          read_cart_output(@seller, %(
            #1[#6P(2008 Cabernet) & #6P(1999 Chardonnay)] [
              #6(1999 Chardonnay $15)
              #6(2008 Cabernet $25)
            ]                   -> $192 ($172.8)
            #6(2008 Merlot $20) -> $120 ($108)
                       subtotal => $280.8
          ))
        }
        describe "SMP receive additional 2008 vintage discount of 25%" do
          specify { check_cart(subject) }
        end
      end

      context "and there is SMP and 6 2009 Merlot in the cart" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#6P(2008 Cabernet) & #6P(1999 Chardonnay)] [
              #6(2008 Cabernet $15)
              #6(1999 Chardonnay $25)
            ]
            #6(2009 Merlot $20)
          ))
          read_cart_output(@seller, %(
            #1[#6P(2008 Cabernet) & #6P(1999 Chardonnay)] [
              #6(1999 Chardonnay $15)
              #6(2008 Cabernet $25)
            ]                   -> $192 ($172.8)
            #6(2009 Merlot $20) -> $120 ($108)
                       subtotal => $280.8
          ))
        }
        describe "SMP receive additional General Bulk discount of 10%" do
          specify { check_cart(subject) }
        end
      end
    end
  end

  context "when wines qualify for both fixed price and amount off price" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #12T(wine)+ => D$100
        $200T(wine)+ => D-$100
      ))
    }
    describe "it does NOT crack" do
      before {
        @check_bot.stub(:shipping_charges).and_return(40.0.to_d)
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $20) -> $240 ($100)
                      subtotal => $100
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "when wines qualify for both fixed price and amount off price" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #36T(wine)+ => D$10
        $200T(wine)+ => D-$10
      ))
    }
    describe "it does NOT crack" do
      before {
        @check_bot.stub(:shipping_charges).and_return(nil)
        @check_bot.cart = read_cart(@seller, %(
          #40(2008 Merlot $10)
                    subtotal => $10
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "when wines qualify for both fixed shipping price and amount off shipping" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #36T(wine)+ => Sh$10
        $200T(wine)+ => Sh-$10
      ))
    }
    describe "it does NOT crack" do
      before {
        @check_bot.stub(:shipping_charges).and_return(40.0.to_d)
        @check_bot.cart = read_cart(@seller, %(
          #40(2008 Merlot $10)
                    shipping => $10
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "Competing price discounts" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        $200T(wine)+ => D$10
        #12T(2008)+ => D-$100
      ))
    }
    context "see what happens" do
      before {
        @check_bot.stub(:shipping_charges).and_return(nil)
        @check_bot.cart = read_cart(@seller, %(
          #24(1999 Chardonnay $15)
          #12(2008 Merlot $20)
                      subtotal => $10
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Competing shipping discounts" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        $200T(wine)+ => Sh$10
        #12T(2008)+ => Sh-$100
      ))
    }
    context "see what happens" do
      before {
        @check_bot.stub(:shipping_charges).and_return(40.0.to_d)
        @check_bot.cart = read_cart(@seller, %(
          #24(1999 Chardonnay $15)
          #12(2008 Merlot $20)
                      shipping => $10
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "Fitness of shipping packs can be compromised" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_shipping }
    before {
      @check_bot.stub(:shipping_charges).and_return(600.0.to_d)
      @check_bot.stub(:shipping_per_item).and_return(16.6666.to_d)
      @check_bot.packs = read_packs(@seller, %(
        $200T(wine)+ => Sh$100
        #12T(2008)+ => Sh-80%
      ))
    }

    describe "12 Chardonnay and 12 Merlot operate as expected ($10 fixed shipping price)" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #24(1999 Chardonnay $15)
          #12(2008 Merlot $20)
                     shipping => $100
        ))
      }
      specify { check_cart(subject, true) }
    end

    describe "lowering the number of CHARD bottles changes the effective fitness of Sh$10 pack, thus making it does NOT crack" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(1999 Chardonnay $15)
          #24(2008 Merlot $20)
                     shipping => $100
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "when there is a $200 shipping discount" do
    before {
      @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        $200T(wine)+ => Sh-100%
        #12T(wine)+ => D-20%
      ))
    }

    context "and another discount lowers subtotal below $200 threshold" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $20) -> $240 ($192)
                      subtotal => $192
                      shipping => $12
        ))
      }
      describe "then shipping is NOT free" do
        specify { check_cart(subject) }
      end
    end

    context "and another discount does NOT lower subtotal below $200 threshold" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #13(2008 Merlot $20) -> $260 ($208)
                      subtotal => $208
                      shipping => $0
        ))
      }
      describe "then shipping is free" do
        specify { check_cart(subject) }
      end
    end
  end

  describe "Price and Shipping discount" do
    context "when $200 pack has price discount and free shipping" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.packs = read_packs(@seller, %(
           $200T(wine)+ => D-50% & Sh-100%
        ))
      }
      describe "all wines receive price discount and free shipping" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #12(2008 Merlot $20) -> $240
                        subtotal => $120
                        shipping => $0
          ))
        }
        specify { check_cart(subject, true) }
      end
    end
  end

  describe "Rewards" do
    context "when condition has price discount and reward has shipping discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => Sh-50% <- #6T(Merlot) => D-20%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $111
                      shipping => $6.5
        ))
      }

      describe "then 6 Merlot (condition) receives 20% off the price while 1 Shiraz (reward) receives 50% off shipping" do
        specify { check_cart(subject, true) }
      end
    end
  end

  describe "Real scenario with amount off" do
    before {
      @check_bot.stub(:shipping_charges).and_return(nil)
      # @check_bot.stub(:shipping_per_item).and_return(0.625)
      @check_bot.packs = read_packs(@seller, %(
        #3T(white)+ => D-$18
        #3T(white)+ => D-$18
        #3T(white)+ => D-$18
        $200T(red)+ => D-$40
        $200T(red)+ => D-10%
        #12T(wine)+ => D-20%
      ))
      read_wines(@seller, %(
        2009 Unwooded $14 {white, standard wine}
      ))
      @check_bot.cart = read_cart_input(@seller, %(
        #12(2009 Unwooded $14)
                      subtotal => $400
      ))
      read_cart_output(@seller, %(
        #12(2009 Unwooded $14)
                      subtotal => $134.40
      ))
    }
    specify { check_cart(subject) }
  end

  describe "Real scenario with amount off shipping" do
    before {
      @check_bot.stub(:shipping_charges).and_return(168.0.to_d)
      @check_bot.stub(:shipping_per_item).and_return(14.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        #3T(white)+ => Sh-$18
        #3T(white)+ => Sh-$18
        #3T(white)+ => Sh-$18
        $200T(red)+ => Sh-$40
        $200T(red)+ => Sh-10%
        #12T(wine)+ => Sh-20%
      ))
      read_wines(@seller, %(
        2009 Unwooded $14 {white, standard wine}
      ))
      @check_bot.cart = read_cart_input(@seller, %(
        #12(2009 Unwooded $14)
      ))
      read_cart_output(@seller, %(
        #12(2009 Unwooded $14)
                      shipping => $134.40
      ))
    }
    specify { check_cart(subject, true) }
  end

  describe "Real scenario with specified price" do
    before {
      @check_bot.stub(:shipping_charges).and_return(nil)
      # @check_bot.stub(:shipping_per_item).and_return(0.625)
      @check_bot.packs = read_packs(@seller, %(
        #3T(white)+ => D$140
        #3T(white)+ => D$140
        #3T(white)+ => D$140
        $200T(red)+ => D-$40
        $200T(red)+ => D-10%
        #12T(wine)+ => D-50%
      ))
      read_wines(@seller, %(
        2009 Unwooded $14 {white, standard wine}
      ))
      @check_bot.cart = read_cart_input(@seller, %(
        #12(2009 Unwooded $14)
                      subtotal => $400
      ))
      read_cart_output(@seller, %(
        #12(2009 Unwooded $14)
                      subtotal => $84
      ))
    }
    specify { check_cart(subject) }
  end

  describe "Real scenario with specified shipping price" do
    before {
      @check_bot.stub(:shipping_charges).and_return(168.0.to_d)
      @check_bot.stub(:shipping_per_item).and_return(14.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        #3T(white)+ => Sh$140
        #3T(white)+ => Sh$140
        #3T(white)+ => Sh$140
        $200T(red)+ => Sh-$40
        $200T(red)+ => Sh-10%
        #12T(wine)+ => Sh-50%
      ))
      read_wines(@seller, %(
        2009 Unwooded $14 {white, standard wine}
      ))
      @check_bot.cart = read_cart_input(@seller, %(
        #12(2009 Unwooded $14)
      ))
      read_cart_output(@seller, %(
        #12(2009 Unwooded $14)
                      shipping => $84
      ))
    }
    specify { check_cart(subject, true) }
  end

  describe "Cart decorator and cart generator assign correct quantities" do
    before {
      @check_bot.stub(:shipping_charges).and_return(20.0)
      @check_bot.stub(:shipping_per_item).and_return(1.0)

      @check_bot.cart = read_cart_input(@seller, %(
        #7(2008 Merlot $20)
      ))
    }

    context "in database domain" do
      subject { @check_bot.new_cart }

      before {
        @check_bot.packs = read_packs(@seller, %(
          #4T(wine) => Sh-50%
          #3T(wine) => D-50%
        ))

        read_cart_output(@seller, %(
          #4(2008 Merlot $20) -> $80 ($40)
          #2(2008 Merlot $20) -> $40 ($20)
          #1(2008 Merlot $20) -> $20
                     subtotal => $80
        ))
      }

      specify { check_cart(subject) }
    end

    context "in database domain" do
      subject { @check_bot.new_cart }

      before {
        @check_bot.packs = read_packs(@seller, %(
          #4T(wine) => Sh-50%
          #3T(wine) => D-50%
        ))

        read_cart_output(@seller, %(
          #4(2008 Merlot $20) sh -> $4 ($2)
          #2(2008 Merlot $20) sh -> $2
          #1(2008 Merlot $20) sh -> $1
                        shipping => $5
        ))
      }

      specify { check_cart(subject, true) }
    end

    context "in price domain" do
      subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }

      before {
        @check_bot.packs = read_packs(@seller, %(
          #4T(wine) => Sh-50%
          #3T(wine) => D-50%
        ))

        read_cart_output(@seller, %(
          #6(2008 Merlot $20) -> $120 ($60)
          #1(2008 Merlot $20) -> $20
                     subtotal => $80
                     shipping => $5
        ))
      }

      specify { check_cart(subject) }
    end

    describe "in shipping domain" do
      subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_shipping }

      before {
        @check_bot.packs = read_packs(@seller, %(
          #4T(wine) => D-50%
          #3T(wine) => Sh-50%
        ))

        read_cart_output(@seller, %(
          #6(2008 Merlot $20) sh -> $6 ($3)
          #1(2008 Merlot $20) sh -> $1
                     subtotal => $100
                     shipping => $4
        ))
      }

      specify { check_cart(subject, true) }
    end
  end

  describe "Pack sorter can cause divide by zero error" do
    before {
      @check_bot.stub(:shipping_charges).and_return(24.0.to_d)
      @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        $10T(wine)+ => Sh-$5
        $10T(wine)+ => D-$5
        #1P(2008 Shiraz)+ => D-50%
        #1P(2008 Shiraz)+ => Sh-60%
      ))
      @check_bot.cart = read_cart(@seller, %(
        #6(2008 Merlot $10)
      ))
    }

    specify { check_cart(subject, true) }
  end

  describe "multi fixed price discounts" do
    context "when there's a discount for 12 and 1" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1P(2008 Merlot) => D$50
          #12P(2008 Merlot) => D$570
        ))

        @check_bot.cart = read_cart_input(@seller, %(
          #18(2008 Merlot $75)
        ))

        read_cart_output(@seller, %(
          #12(2008 Merlot $75) -> $900 ($570)
          #6(2008 Merlot $75)  -> $450 ($300)
                      subtotal => $870
        ))
      }
      specify { check_cart(subject) }
    end

    context "when there's a discount for 12, 6 and 1" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1P(2008 Merlot) => D$50
          #6P(2008 Merlot) => D$290
          #12P(2008 Merlot) => D$570
        ))

        @check_bot.cart = read_cart_input(@seller, %(
          #19(2008 Merlot $75)
        ))

        read_cart_output(@seller, %(
          #12(2008 Merlot $75) -> $900 ($570)
          #6(2008 Merlot $75)  -> $450 ($290)
          #1(2008 Merlot $75)  -> $75 ($50)
                      subtotal => $910
        ))
      }
      specify { check_cart(subject) }
    end
  end

  describe "lots of discounts" do
    context "when there are items with the same price" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(Merlot) => D-5%
          #12T(2012) => D-10%
          #12T(2011)+ => D-15%
          #12T(Merlot) => D-10%
        ))

        @check_bot.cart = read_cart_input(@seller, %(
          #12(2008 Merlot $20)
          #12(2009 Merlot $20)
          #18(2010 Merlot $20)
          #12(2011 Shiraz $9)
          #12(2012 Shiraz $8)
        ))

        read_cart_output(@seller, %(
          #12(2008 Merlot $20) -> $240 ($216)
          #12(2009 Merlot $20) -> $240 ($216)
          #12(2010 Merlot $20) -> $240 ($216)
          #6(2010 Merlot $20)  -> $120 ($114)
          #12(2011 Shiraz $9)  -> $108 ($91.80)
          #12(2012 Shiraz $8)  -> $96 ($86.40)
                      subtotal => $940.20
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "when their is mixed pack with big price differences" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#2P(2008 A) & #1P(2008 B) & #1P(2008 C) & #1P(2008 D) & #1P(2008 E)] => D$220
      ))
      @check_bot.cart = read_cart_input(@seller, %(
        #2[#2P(2008 A) & #1P(2008 B) & #1P(2008 C) & #1P(2008 D) & #1P(2008 E)] [
          #4P(2008 A $20)
          #2P(2008 B $60)
          #2P(2008 C $35)
          #2P(2008 D $35)
          #2P(2008 E $50)
        ]
      ))

      read_cart_output(@seller, %(
        #2[#2P(2008 A) & #1P(2008 B) & #1P(2008 C) & #1P(2008 D) & #1P(2008 E)] [
          #4P(2008 A $20)
          #2P(2008 B $60)
          #2P(2008 C $35)
          #2P(2008 D $35)
          #2P(2008 E $50)
        ]                               -> $440 ($398)
                               subtotal => $398
      ))
    }

    context "and the discount is a fixed price" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1M([#2P(2008 A) & #1P(2008 B) & #1P(2008 C) & #1P(2008 D) & #1P(2008 E)]) => D$199
        ))
      }

      specify { check_cart(subject) }
    end

    context "and the discount is an amount off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1M([#2P(2008 A) & #1P(2008 B) & #1P(2008 C) & #1P(2008 D) & #1P(2008 E)]) => D-$21
        ))
      }

      specify { check_cart(subject) }
    end

    context "and the discount is a percentage off" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1M([#2P(2008 A) & #1P(2008 B) & #1P(2008 C) & #1P(2008 D) & #1P(2008 E)]) => D-9.5454545454%
        ))
      }

      specify { check_cart(subject) }
    end
  end
end
