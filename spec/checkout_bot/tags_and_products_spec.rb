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

  context "Discount with a Product" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #12P(2008 Merlot)+ => D-20%
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

    describe "all 12 get the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $19) -> $228 ($182.4)
                      subtotal => $182.4
        ))
      }
      specify { check_cart(subject) }
    end

    describe "all 27 get the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #27(2008 Merlot $19) -> $513 ($410.4)
                      subtotal => $410.4
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Discount with a TAG" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #12T(Merlot)+ => D-20%
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

    describe "all 12 get the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #12(2008 Merlot $19) -> $228 ($182.4)
                      subtotal => $182.4
        ))
      }
      specify { check_cart(subject) }
    end

    describe "all 12 (6 * 2008 Merlot AND 6 * 2009 Merlot) get the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $19)  -> $114 ($91.2)
          #6(2009 Merlot $19)  -> $114 ($91.2)
                      subtotal => $182.4
        ))
      }
      specify { check_cart(subject) }
    end

    describe "all 27 get the discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #27(2008 Merlot $19) -> $513 ($410.4)
                      subtotal => $410.4
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "CHB chooses TAG if TAG is better" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #6T(Merlot)+ => D-20%
        #4P(2008 Merlot)+ => D-10%
      ))
    }
    describe "no discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #3(2008 Merlot $20)  -> $60
                      subtotal => $60
        ))
      }
      specify { check_cart(subject) }
    end

    describe "Merlot receives Product discount as it does not qualify for TAG discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #5(2008 Merlot $20)  -> $100 ($90)
                      subtotal => $90
        ))
      }
      specify { check_cart(subject) }
    end

    describe "Merlot receives TAG discount as it quailfies for both Product and TAG discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #7(2008 Merlot $20)  -> $140 ($112)
                      subtotal => $112
        ))
      }
      specify { check_cart(subject) }
    end

    context "and there is another tag discount" do
      before {
        @check_bot.packs += read_packs(@seller, %(
          #8T(2009)+ => D-25%
        ))
      }
      describe "the best TAG is selected" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #6(2009 Merlot $20) -> $120 ($90)
            #2(2009 Shiraz $20) -> $40 ($30)
                       subtotal => $120
          ))
        }
        specify { check_cart(subject) }
      end
    end
  end

  context "CHB chooses Product if Product is better" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #4T(Merlot)+ => D-10%
        #6P(2008 Merlot)+ => D-20%
      ))
    }
    describe "no discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #3(2008 Merlot $20)  -> $60
                      subtotal => $60
        ))
      }
      specify { check_cart(subject) }
    end

    describe "Merlot receives TAG discount as it does not qualify for Product discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #5(2008 Merlot $20)  -> $100 ($90)
                      subtotal => $90
        ))
      }
      specify { check_cart(subject) }
    end

    describe "Merlot receives Product discount as it quailfies for both Product and TAG discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #7(2008 Merlot $20)  -> $140 ($112)
                      subtotal => $112
        ))
      }
      specify { check_cart(subject) }
    end

    context "and there is another product discount" do
      before {
        @check_bot.packs += read_packs(@seller, %(
          #8P(2008 Merlot)+ => D-25%
        ))
      }
      describe "the best product is selected" do
        before {
          @check_bot.cart = read_cart(@seller, %(
            #8(2008 Merlot $20) -> $160 ($120)
                       subtotal => $120
          ))
        }
        specify { check_cart(subject) }
      end
    end
  end

  context "When TAG is not applicable to any product" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        #1T(ChristmasSpecial)+ => D-50%
      ))
    }

    describe "no discount" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #2(2008 Merlot $20)  -> $40
                      subtotal => $40
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "TAG interact with SMP" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] => D$50
        #8T(wine)+ => D-10%
      ))
    }

    describe "no further discount on single SMP" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #6(2008 Merlot $20)  -> $50
                      subtotal => $50
        ))
      }
      specify { check_cart(subject) }
    end

    describe "further discount on two SMPs" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #2[#6P(2008 Merlot)] [
            #12(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #12(2008 Merlot $20) -> $100 ($90)
                      subtotal => $90
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "Product interact with SMP" do
    before {
      @check_bot.packs = read_packs(@seller, %(
        [#6P(2008 Merlot)] {Merlot} => D$50
        #8T(Merlot)+ => D-10%
      ))
    }

    describe "no further discount on single SMP" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #1[#6P(2008 Merlot)] [
            #6(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #6(2008 Merlot $20)  -> $50
                      subtotal => $50
        ))
      }
      specify { check_cart(subject) }
    end

    describe "further discount on two SMPs" do
      before {
        @check_bot.cart = read_cart_input(@seller, %(
          #2[#6P(2008 Merlot)] [
            #12(2008 Merlot $20)
          ]
        ))
        read_cart_output(@seller, %(
          #12(2008 Merlot $20) -> $100 ($90)
                      subtotal => $90
        ))
      }
      specify { check_cart(subject) }
    end
  end

# Product interaction with SMP

end
