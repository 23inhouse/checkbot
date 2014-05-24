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

  context "Competing price" do
    before {
      @check_bot.cart = read_cart_input(@seller, %(
        #2(2008 Merlot $20)
      ))
    }

    context "quantity discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => D$10.01
            #1T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => D$9.99
            #1T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => D-$9.99
            #1T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => D-$10.01
            #1T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => D$10
            #1T(wine) => D-$10.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot) => D$9.99
            #1T(wine) => D-$10
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end
    end

    context "quantity or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => D$20.01
            #1T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => D$19.99
            #1T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => D-$19.99
            #1T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => D-$20.01
            #1T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => D$20
            #1T(wine)+ => D-$20.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            #1T(Merlot)+ => D$19.99
            #1T(wine)+ => D-$20
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end
    end

    context "200 discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => D$10.01
            $20T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => D$9.99
            $20T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => D-$9.99
            $20T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => D-$10.01
            $20T(wine) => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => D$10
            $20T(wine) => D-$10.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot) => D$9.99
            $20T(wine) => D-$10
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.98
          ))
        }
        specify { check_cart(subject) }
      end
    end

    context "200 or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => D$20.01
            $20T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => D$19.99
            $20T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => D-$19.99
            $20T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $20
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => D-$20.01
            $20T(wine)+ => D-50%
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => D$20
            $20T(wine)+ => D-$20.01
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            $20T(Merlot)+ => D$19.99
            $20T(wine)+ => D-$20
          ))

          read_cart_output(@seller, %(
            #2(2008 Merlot $20)
                          subtotal => $19.99
          ))
        }
        specify { check_cart(subject) }
      end
    end
  end

  context "Cooperating price" do
    before {
      @check_bot.cart = read_cart(@seller, %(
        #2(1999 Chardonnay $10)
        #1(2008 Merlot $20)
                   subtotal => $12
      ))
    }

    context "when the specific discount is greater than the generic" do
      context "quantity discount" do
        context "and it's an amount off" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              #1T(wine)+ => D-$10
              #1T(2008)+ => D-90%
            ))
          }

          describe "then the amount off is limited to the specific wine" do
            specify { check_cart(subject) }
          end
        end

        context "and it's a fixed price" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              #1T(wine)+ => D$10
              #1T(2008)+ => D-90%
            ))
          }

          describe "then the fixed price is limited to the specific wine" do
            specify { check_cart(subject) }
          end
        end
      end

      context "amount discount" do
        context "and it's an amount off" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              $10T(wine)+ => D-$10
              $10T(2008)+ => D-90%
            ))
          }

          describe "then the amount off is limited to the specific wine" do
            specify { check_cart(subject) }
          end
        end

        context "and it's a fixed price" do
          before {
            @check_bot.packs = read_packs(@seller, %(
              $10T(wine)+ => D$10
              $10T(2008)+ => D-90%
            ))
          }

          describe "then the fixed price is limited to the specific wine" do
            specify { check_cart(subject) }
          end
        end
      end
    end
  end
end
