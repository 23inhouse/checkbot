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

  context "Competing SMP price" do
    context "quantity discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$10.01
            #1T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$9.99
            #1T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$9.99
            #1T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$10.01
            #1T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$10
            #1T(wine) => D-$2.01
          ))

          smp_with_2_2008_merlots_subtotal(15.98)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$9.99
            #1T(wine) => D-$2
          ))

          smp_with_2_2008_merlots_subtotal(15.98)
        }
        specify { check_cart(subject) }
      end
    end

    context "quantity or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$20.01
            #1T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(20.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$19.99
            #1T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$9.99
            #1T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$10.01
            #1T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$20
            #1T(wine)+ => D-$20.01
          ))

          smp_with_2_2008_merlots_subtotal(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$19.99
            #1T(wine)+ => D-$20
          ))

          smp_with_2_2008_merlots_subtotal(19.98)
        }
        specify { check_cart(subject) }
      end
    end

    context "200 discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$10.01
            $20T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$9.99
            $20T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$9.99
            $20T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$10.01
            $20T(wine) => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$10
            $20T(wine) => D-$2.01
          ))

          smp_with_2_2008_merlots_subtotal(15.98)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$9.99
            $19T(wine) => D-$2
          ))

          smp_with_2_2008_merlots_subtotal(15.98)
        }
        specify { check_cart(subject) }
      end
    end

    context "200 or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$20.01
            $20T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(20.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$19.99
            $20T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$9.99
            $20T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D-$10.01
            $19T(wine)+ => D-50%
          ))

          smp_with_2_2008_merlots_subtotal(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$20
            $20T(wine)+ => D-$20.01
          ))

          smp_with_2_2008_merlots_subtotal(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => D$19.99
            $20T(wine)+ => D-$20
          ))

          smp_with_2_2008_merlots_subtotal(19.98)
        }
        specify { check_cart(subject) }
      end
    end
  end
end
