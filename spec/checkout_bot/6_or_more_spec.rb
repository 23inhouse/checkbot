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

  context "6 or more" do
    context "when the quantity" do
      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine)+ => D-50%
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

        describe "all 14 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #14(2008 Merlot $21) -> $294 ($147)
                          subtotal => $147
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "discount is $50 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine)+ => D-$50
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

        describe "all 14 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #14(2008 Merlot $21) -> $294 ($244)
                          subtotal => $244
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "is $50" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine)+ => D$50
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

        describe "all 14 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #14(2008 Merlot $21) -> $294 ($50)
                          subtotal => $50
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
            #6T(wine)+ => Sh-50%
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

        describe "all 14 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #14(2008 Merlot $21)  sh -> $37.94 ($18.97)
                              shipping => $18.97
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "discount is $5 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine)+ => Sh-$5
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

        describe "all 14 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #14(2008 Merlot $21)  sh -> $37.94 ($32.94)
                              shipping => $32.94
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "is $5" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(wine)+ => Sh$5
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

        describe "all 14 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #14(2008 Merlot $21)  sh -> $37.94 ($5)
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end
      end
    end
  end
end
