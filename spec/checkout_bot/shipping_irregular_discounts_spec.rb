# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  subject { @check_bot.new_cart }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
    @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
  }

  context "when the discount is greater than the discountable amount" do
    context "on quantity" do
      context "and it's an amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(Merlot) => Sh-$20
          ))
        }

        context "and the are both below the discountable amount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9 ($0)
              #9(2010 Merlot $2) sh -> $9 ($0)
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        context "and the are both below the discountable amount with another wine" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9 ($0)
              #9(2010 Merlot $2) sh -> $9 ($0)
              #1(2009 Shiraz $2) sh -> $1
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        # context "with price both above below the discountable amount" do
        #   before {
        #     @check_bot.cart = read_cart(@seller, %(
        #       #9(2009 Merlot $2)  -> $18 ($15)
        #       #9(2010 Merlot $38) -> $342 ($285)
        #     ))
        #   }

        #   describe "then the discount is divided according to the price" do
        #     specify { check_cart(subject, true) }
        #   end
        # end
      end

      context "and it's a fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #6T(Melot) => Sh$20
          ))
        }

        context "and the are both below the discountable amount" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9
              #9(2010 Merlot $2) sh -> $9
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        context "and the are both below the discountable amount with another wine" do
          before {
            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9
              #1(2009 Shiraz $2) sh -> $1
              #9(2010 Merlot $2) sh -> $9
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        # context "with price both above below the discountable amount" do
        #   before {
        #     @check_bot.cart = read_cart(@seller, %(
        #       #6(2009 Merlot $2)  -> $12
        #       #3(2009 Merlot $2)  -> $6   ($1)
        #       #3(2010 Merlot $38) -> $114 ($19)
        #       #6(2010 Merlot $38) -> $228 ($20)
        #     ))
        #   }

        #   describe "then the discount is divided according to the price" do
        #     specify { check_cart(subject, true) }
        #   end
        # end
      end
    end

    context "on amount" do
      context "and it's an amount off" do
        context "and the are both below the discountable amount" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              $12T(Merlot) => Sh-$20
            ))

            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9
              #9(2010 Merlot $2) sh -> $9
                           Sh Tally -> -$18
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        context "and the are both below the discountable amount with another wine" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              $12T(Merlot) => Sh-$20
            ))

            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9
              #1(2009 Shiraz $2) sh -> $1
              #9(2010 Merlot $2) sh -> $9
                           Sh Tally -> -$18
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        # context "with price both above below the discountable amount" do
        #   before {
        #     @check_bot.packs = read_packs(@seller, %(
        #       $120T(Merlot) => Sh-$20
        #     ))

        #     @check_bot.cart = read_cart(@seller, %(
        #       #9(2009 Merlot $2)  -> $18
        #       #9(2010 Merlot $38) -> $342
        #                   D Tally -> -$60
        #     ))
        #   }

        #   describe "then the discount is divided according to the price" do
        #     specify { check_cart(subject, true) }
        #   end
        # end
      end

      context "and it's a fixed price" do
        context "and the are both below the discountable amount" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              $12T(Merlot) => Sh$20
            ))

            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9
              #9(2010 Merlot $2) sh -> $9
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        context "and the are both below the discountable amount with another wine" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              $12T(Merlot) => Sh$20
            ))

            @check_bot.cart = read_cart(@seller, %(
              #9(2009 Merlot $2) sh -> $9
              #1(2009 Shiraz $2) sh -> $1
              #9(2010 Merlot $2) sh -> $9
            ))
          }

          describe "then both are discounted as much as possible" do
            specify { check_cart(subject, true) }
          end
        end

        # context "with price both above below the discountable amount" do
        #   before {
        #     @check_bot.packs = read_packs(@seller, %(
        #       $120T(Merlot) => Sh$20
        #     ))

        #     @check_bot.cart = read_cart(@seller, %(
        #       #9(2009 Merlot $2)  -> $18
        #       #9(2010 Merlot $38) -> $342
        #                   D Tally -> -$300
        #     ))
        #   }

        #   describe "then the discount is divided according to the price" do
        #     specify { check_cart(subject, true) }
        #   end
        # end
      end
    end
  end
end
