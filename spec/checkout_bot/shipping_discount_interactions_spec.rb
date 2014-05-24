require 'spec_helper'

describe CheckoutBot do
  subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_shipping }

  before {
    @check_bot = CheckoutBot.new

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(40.0.to_d)
    @check_bot.stub(:shipping_per_item).and_return(20.0.to_d)
  }

  context "Competing shipping" do
    before {
      @check_bot.cart = read_cart_input(@seller, %(
        #2(2008 Merlot $20)
      ))
    }

    context "quantity discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => Sh$10.01
            #1T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => Sh$9.99
            #1T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => Sh-$9.99
            #1T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => Sh-$10.01
            #1T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => Sh$10
            #1T(wine) => Sh-$10.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => Sh$9.99
            #1T(wine) => Sh-$10
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end
    end

    context "quantity or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => Sh$20.01
            #1T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => Sh$19.99
            #1T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => Sh-$19.99
            #1T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => Sh-$20.01
            #1T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => Sh$20
            #1T(wine)+ => Sh-$20.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => Sh$19.99
            #1T(wine)+ => Sh-$20
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end
    end

    context "200 discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => Sh$10.01
            $20T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => Sh$9.99
            $20T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => Sh-$9.99
            $20T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => Sh-$10.01
            $20T(wine) => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => Sh$10
            $20T(wine) => Sh-$10.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => Sh$9.99
            $20T(wine) => Sh-$10
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.98
          ))
        }
        specify { check_cart(subject, true) }
      end
    end

    context "200 or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => Sh$20.01
            $20T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => Sh$19.99
            $20T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => Sh-$19.99
            $20T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $20
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => Sh-$20.01
            $20T(wine)+ => Sh-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => Sh$20
            $20T(wine)+ => Sh-$20.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => Sh$19.99
            $20T(wine)+ => Sh-$20
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          shipping => $19.99
          ))
        }
        specify { check_cart(subject, true) }
      end
    end
  end

  context "Cooperating shipping discounts" do
    context "when the specific discount is greater than the generic discount" do
      before {
        @check_bot.stub(:shipping_charges).and_return(30.0.to_d)
        @check_bot.stub(:shipping_per_item).and_return(10.0.to_d)

        @check_bot.cart = read_cart(@seller, %(
          #2(1999 Chardonnay $15)
          #1(2008 Merlot $20)
                     shipping => $11
        ))
      }

      context "and it's an amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $1T(wine)+ => Sh-$10
            #1T(2008)+ => Sh-90%
          ))
        }

        describe "then the amount off is limited to the specific wine" do
          specify { check_cart(subject, true) }
        end
      end

      context "and it's a fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $1T(wine)+ => Sh$10
            #1T(2008)+ => Sh-90%
          ))
        }

        describe "then the fixed price is limited to the specific wine" do
          specify { check_cart(subject, true) }
        end
      end
    end

    context "when there is a 200 or more discount" do
      context "and there is a quantity discount" do
        describe "both discounts are applied (tally does NOT disqualify percentage off)" do
          before {
            @check_bot.stub(:shipping_charges).and_return(240.0.to_d)
            @check_bot.stub(:shipping_per_item).and_return(10.0.to_d)

            @check_bot.packs = read_packs(@seller, %(
              $100T(wine)+ => Sh-$30
              #6P(2008 Merlot) => Sh-50%
            ))
            @check_bot.cart = read_cart(@seller, %(
              #6(2008 Merlot $10)   sh -> $60 ($30)
              #18(2008 Shiraz $10)  sh -> $180
                              Sh Tally -> -$30
            ))
          }
          specify { check_cart(subject, true) }
        end
      end
    end
  end
end
