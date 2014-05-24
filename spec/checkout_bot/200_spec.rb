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

  context "specific $200" do
    context "when the price" do
      context "discount is 50% off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => D-50%
          ))
        }
        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20) -> $240
                          subtotal => $140
            ))
          }
          specify { check_cart(subject) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19) -> $437
                          subtotal => $237
            ))
          }
          specify { check_cart(subject) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21) -> $462
                          subtotal => $262
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19) -> $418
              #11(2008 Shiraz $18) -> $198
                          subtotal => $316
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "discount is $50 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => D-$50
          ))
        }
        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20) -> $240
                          subtotal => $190
            ))
          }
          specify { check_cart(subject) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19) -> $437
                          subtotal => $337
            ))
          }
          specify { check_cart(subject) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21) -> $462
                          subtotal => $362
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19) -> $418
              #11(2008 Shiraz $18) -> $198
                          subtotal => $466
            ))
          }
          specify { check_cart(subject) }
        end
      end

      context "is $50" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => D$50
          ))
        }
        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20) -> $240
                          subtotal => $90
            ))
          }
          specify { check_cart(subject) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19) -> $437
                          subtotal => $137
            ))
          }
          specify { check_cart(subject) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21) -> $462
                          subtotal => $162
            ))
          }
          specify { check_cart(subject) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19) -> $418
              #11(2008 Shiraz $18) -> $198
                          subtotal => $166
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
            $200T(wine) => Sh-50%
          ))
        }

        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $12
                              shipping => $7
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $23
                              shipping => $12.473684211
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $22
                              shipping => $12.476190476
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $22
              #11(2008 Shiraz $18)  sh -> $11
                              shipping => $16.928571429
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "discount is $5 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => Sh-$5
          ))
        }

        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $12
                              shipping => $7
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $23
                              shipping => $13
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $22
                              shipping => $12
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $22
              #11(2008 Shiraz $18)  sh -> $11
                              shipping => $18
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "is $5" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => Sh$5
          ))
        }

        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $12
                              shipping => $7
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $23
                              shipping => $11.947368421
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $22
                              shipping => $12.952380952
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $22
              #11(2008 Shiraz $18)  sh -> $11
                              shipping => $15.857142857
            ))
          }
          specify { check_cart(subject, true) }
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
            $200T(wine) => Sh-50%
          ))
        }

        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $32.52
                              shipping => $18.97
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $62.33
                              shipping => $33.803684211
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $59.62
                              shipping => $33.81047619
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $59.62
              #11(2008 Shiraz $18)  sh -> $29.81
                              shipping => $45.876428571
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "discount is $5 off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => Sh-$5
          ))
        }

        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $32.52
                              shipping => $27.52
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $62.33
                              shipping => $52.33
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $59.62
                              shipping => $49.62
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $59.62
              #11(2008 Shiraz $18)  sh -> $29.81
                              shipping => $74.43
            ))
          }
          specify { check_cart(subject, true) }
        end
      end

      context "is $5" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $200T(wine) => Sh$5
          ))
        }

        describe "the first 10 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #12(2008 Merlot $20)  sh -> $32.52
                              shipping => $10.42
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 21 & 1/19 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #23(2008 Merlot $19)  sh -> $62.33
                              shipping => $15.277368421
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "the first 19 & 1/21 get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $21)  sh -> $59.62
                              shipping => $18.000952381
            ))
          }
          specify { check_cart(subject, true) }
        end

        describe "all merlot and the first 10 & 2/18 shiraz get the discount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #22(2008 Merlot $19)  sh -> $59.62
              #11(2008 Shiraz $18)  sh -> $29.81
                              shipping => $17.322857143
            ))
          }
          specify { check_cart(subject, true) }
        end
      end
    end
  end
end
