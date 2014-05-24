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

  context "Basic SMP on price" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D$50
      ))
    }
    describe "all Merlot get the discount" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $50
                      subtotal => $50
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Basic SMP on shipping" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => Sh-50%
      ))
    }
    describe "all Merlot get the discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $120
                      subtotal => $120
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "Basic SMP on both price and shipping" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D-10% & Sh-50%
      ))
    }
    describe "all Merlot get price and shipping discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $108
                      subtotal => $108
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "SMP with extra price discount on top of it" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D-10%
        #1T(wine) => D-50%
      ))
    }
    describe "all Merlot receive further discount" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $108 ($54)
                      subtotal => $54
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "SMP with extra shipping discount on top of it" do
    before {
      @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] {Merlot} => D-10%
        #1T(Merlot) => Sh-50%
      ))
    }
    describe "all Merlot receive further shipping discount" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $108
                      subtotal => $108
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "SMP doesn't get exploded" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D-10%
        [#2P(2008 Merlot)] => D-50%
      ))
    }
    describe "none gets the better discount" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $108
                      subtotal => $108
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "SMP doesn't get created" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#12P(2008 Merlot)] => D-20%
      ))
    }
    describe "none gets the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #11(2008 Merlot $20) -> $220
                      subtotal => $220
        ))
      }
      specify { check_cart(subject) }
    end

    describe "none gets the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $19) -> $228
                      subtotal => $228
        ))
      }
      specify { check_cart(subject) }
    end

    describe "none gets the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #17(2008 Merlot $21) -> $357
                      subtotal => $357
        ))
      }
      specify { check_cart(subject) }
    end

    describe "none gets the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #27(2008 Merlot $19) -> $513
                      subtotal => $513
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "SMP has it's own discount" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#12P(2008 Merlot)] => D$100
        #1M([#12P(2008 Merlot)]) => D$80
      ))

      @check_bot.cart = read_cart_input(@seller, %(
        #2[#12P(2008 Merlot)] [
          #24(2008 Merlot $10)
        ]
      ))
    }

    describe "then the discount is applied" do
      before {
        read_cart_output(@seller, %(
          #2[#12P(2008 Merlot)] [
            #24(2008 Merlot $10)
          ]                       -> $200 ($160)
                         subtotal => $160
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Discount on multiple SMP or more" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D-50%
      ))
    }
    describe "all Merlot get the discount" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #3[#6P(2008 Merlot)] [
            #18(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #3[#6P(2008 Merlot)] [
            #18(2008 Merlot $20)
          ]                    -> $180
                      subtotal => $180
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Price SMP receives further shipping discount" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] {Merlot} => D-20%
        #6T(Merlot)+ => Sh-50%
      ))
    }
    describe "all Merlot get price and shipping discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $96
                      subtotal => $96
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "Shipping SMP receives further price discount" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] {Merlot} => Sh-50%
        #6T(Merlot)+ => D-20%
      ))
    }
    describe "all Merlot get price and shipping discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $120 ($96)
                      subtotal => $96
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "Both price and shipping SMP with further price discount" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] {Merlot} => D-20% & Sh-50%
        #6T(Merlot)+ => D-20%
      ))
    }
    describe "all Merlot get further price discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $96 ($76.8)
                      subtotal => $76.8
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "Both price and shipping SMP with further shipping discount" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] {Merlot} => D-20% & Sh-50%
        #6T(Merlot)+ => Sh-20%
      ))
    }
    describe "all Merlot get further price discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(6.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]                    -> $96
                      subtotal => $96
                      shipping => $2.4
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "SMP does NOT receive partial price discounts" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#2P(2007 Merlot) & #1P(2008 Merlot)] => D-20%
        #1T(2007)+ => D-50%
        #1P(2008 Merlot)+ => D-50%
      ))
    }

    describe "all Merlot don't receive any further price discount" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#2P(2007 Merlot) & #1P(2008 Merlot)] [
            #2(2007 Merlot $20)
            #1(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#2P(2007 Merlot) & #1P(2008 Merlot)] [
            #2(2007 Merlot $20)
            #1(2008 Merlot $20)
          ]                    -> $48
                      subtotal => $48
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "SMP does NOT receive partial shipping discounts" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#2P(2007 Merlot) & #1P(2008 Merlot)] => D-20%
        #1T(2007)+ => Sh-50%
        #1P(2008 Merlot)+ => Sh-50%
      ))
    }

    describe "all Merlot don't receive any further price discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(3.0.to_d)
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#2P(2007 Merlot) & #1P(2008 Merlot)] [
            #2(2007 Merlot $20)
            #1(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #1[#2P(2007 Merlot) & #1P(2008 Merlot)] [
            #2(2007 Merlot $20)
            #1(2008 Merlot $20)
          ]                    -> $48
                      subtotal => $48
                      shipping => $3
        ))
      }
      specify { check_cart(subject, true) }
    end
  end
end
