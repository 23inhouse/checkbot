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

  context "$200 or more" do
    context "when the price" do
      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => D-50%
          ))
        }
        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20) -> $240
                          subtotal => $120
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19) -> $437
                          subtotal => $218.5
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21) -> $462
                          subtotal => $231
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19) -> $418
              #11(2008 Shiraz $18) -> $198
                          subtotal => $308
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "discount is $50 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => D-$50
          ))
        }
        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20) -> $240
                          subtotal => $190
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19) -> $437
                          subtotal => $387
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21) -> $462
                          subtotal => $412
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19) -> $418
              #11(2008 Shiraz $18) -> $198
                          subtotal => $566
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "is $50" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => D$50
          ))
        }
        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20) -> $240
                          subtotal => $50
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19) -> $437
                          subtotal => $50
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21) -> $462
                          subtotal => $50
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19) -> $418
              #11(2008 Shiraz $18) -> $198
                          subtotal => $50
            ))
          }
          specify { check_cart(subject) }
        end
      end
    end

    context "when the shipping" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
      }
      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => Sh-50%
          ))
        }

        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $12
                              shipping => $6
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $23
                              shipping => $11.5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $22
                              shipping => $11
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $22
              #11(2008 Shiraz $18)  sh -> $11
                              shipping => $16.5
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "discount is $5 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => Sh-$5
          ))
        }

        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $12
                              shipping => $7
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $23
                              shipping => $18
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $22
                              shipping => $17
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $22
              #11(2008 Shiraz $18)  sh -> $11
                              shipping => $28
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "is $5" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => Sh$5
          ))
        }

        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $12
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $23
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $22
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $22
              #11(2008 Shiraz $18)  sh -> $11
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end
      end
    end

    context "when the shipping per item is $2.71" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.stub(:shipping_per_item).and_return(2.71.to_d)
      }

      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => Sh-50%
          ))
        }

        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $32.52
                              shipping => $16.26
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $62.33
                              shipping => $31.165
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $59.62
                              shipping => $29.81
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $59.62
              #11(2008 Shiraz $18)  sh -> $29.81
                              shipping => $44.715
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "discount is $5 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => Sh-$5
          ))
        }

        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $32.52
                              shipping => $27.52
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $62.33
                              shipping => $57.33
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $59.62
                              shipping => $54.62
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $59.62
              #11(2008 Shiraz $18)  sh -> $29.81
                              shipping => $84.43
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "is $5" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine)+ => Sh$5
          ))
        }

        describe "all 12 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $32.52
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 23 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $62.33
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 22 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $59.62
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all 33 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $59.62
              #11(2008 Shiraz $18)  sh -> $29.81
                              shipping => $5
            ))
          }
          specify { check_cart(subject, true) }
        end
      end
    end
  end
end
