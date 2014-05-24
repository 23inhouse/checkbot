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

  context "specific 6" do
    context "when the quantity" do
      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine) => D-50%
          ))
        }
        describe "none of the 5 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #5(2008 Merlot $20)  -> $100
                          subtotal => $100
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 6 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $19)  -> $114 ($57)
                          subtotal => $57
            ))
          }
          specify { check_cart(subject) }
        end

        describe "12 get the discount" do
          before {
            @check_bot.cart = read_cart_input(@seller, %(
              #14(2008 Merlot $21)
            ))
            read_cart_output(@seller, %(
              #12(2008 Merlot $21) -> $252 ($126)
              #2(2008 Merlot $21)  -> $42
                          subtotal => $168
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "discount is $50 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine) => D-$50
          ))
        }
        describe "none of the 5 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #5(2008 Merlot $20)  -> $100
                          subtotal => $100
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 6 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $19)  -> $114 ($64)
                          subtotal => $64
            ))
          }
          specify { check_cart(subject) }
        end

        describe "12 get the discount" do
          before {
            @check_bot.cart = read_cart_input(@seller, %(
              #14(2008 Merlot $21)
            ))
            read_cart_output(@seller, %(
              #12(2008 Merlot $21) -> $252 ($152)
              #2(2008 Merlot $21)  -> $42
                          subtotal => $194
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "is $50" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine) => D$50
          ))
        }
        describe "none of the 5 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #5(2008 Merlot $20)  -> $100
                          subtotal => $100
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 6 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $19)  -> $114 ($50)
                          subtotal => $50
            ))
          }
          specify { check_cart(subject) }
        end

        describe "12 get the discount" do
          before {
            @check_bot.cart = read_cart_input(@seller, %(
              #14(2008 Merlot $21)
            ))
            read_cart_output(@seller, %(
              #12(2008 Merlot $21) -> $252 ($100)
              #2(2008 Merlot $21)  -> $42
                          subtotal => $142
            ))
          }
          specify { check_cart(subject) }
        end
      end
    end

    context "when the shipping per item is $2.71" do
      before {
        @check_bot.stub(:shipping_per_item).and_return(2.71.to_d)
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
      }

      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine) => Sh-50%
          ))
        }

        describe "none of the 5 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #5(2008 Merlot $20) sh -> $13.55
                            shipping => $13.55
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 6 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $19) sh -> $16.26 ($8.13)
                            shipping => $8.13
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "12 get the discount" do
          before {
            @check_bot.cart = read_cart_input(@seller, %(
              #14(2008 Merlot $21)
            ))
            read_cart_output(@seller, %(
              #12(2008 Merlot $21)  sh -> $32.52 ($16.26)
              #2(2008 Merlot $21)   sh -> $5.42
                              shipping => $21.68
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "discount is $5 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine) => Sh-$5
          ))
        }

        describe "none of the 5 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #5(2008 Merlot $20) sh -> $13.55
                            shipping => $13.55
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 6 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $19) sh -> $16.26 ($11.26)
                            shipping => $11.26
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "12 get the discount" do
          before {
            @check_bot.cart = read_cart_input(@seller, %(
              #14(2008 Merlot $21)
            ))
            read_cart_output(@seller, %(
              #12(2008 Merlot $21)  sh -> $32.52 ($22.52)
              #2(2008 Merlot $21)   sh -> $5.42
                              shipping => $27.94
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "is $5" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine) => Sh$5
          ))
        }

        describe "none of the 5 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #5(2008 Merlot $20) sh -> $13.55
                            shipping => $13.55
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 6 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $19) sh -> $16.26 ($5)
                            shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "12 get the discount" do
          before {
            @check_bot.cart = read_cart_input(@seller, %(
              #14(2008 Merlot $21)
            ))
            read_cart_output(@seller, %(
              #12(2008 Merlot $21)  sh -> $32.52 ($10)
              #2(2008 Merlot $21)   sh -> $5.42
                              shipping => $15.42
            ))
          }
          specify { check_cart(subject, true) }
        end
      end
    end
  end
end
