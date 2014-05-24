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

  context "Competing SMP price" do
    context "quantity discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$10.01
            #1T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$9.99
            #1T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$9.99
            #1T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$10.01
            #1T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$20
            #1T(wine) => Sh-$10.01
          ))

          smp_with_2_2008_merlots_shipping(19.98)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$9.99
            #1T(wine) => Sh-$2
          ))

          smp_with_2_2008_merlots_shipping(15.98)
        }
        specify { check_cart(subject) }
      end
    end

    context "quantity or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$20.01
            #1T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(20.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$19.99
            #1T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$9.99
            #1T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$10.01
            #1T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$20
            #1T(wine)+ => Sh-$20.01
          ))

          smp_with_2_2008_merlots_shipping(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$19.99
            #1T(wine)+ => Sh-$20
          ))

          smp_with_2_2008_merlots_shipping(19.98)
        }
        specify { check_cart(subject) }
      end
    end

    context "200 discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$10.01
            $20T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$9.99
            $20T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$9.99
            $20T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$10.01
            $20T(wine) => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$10
            $20T(wine) => Sh-$2.01
          ))

          smp_with_2_2008_merlots_shipping(15.98)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$9.99
            $20T(wine) => Sh-$2
          ))

          smp_with_2_2008_merlots_shipping(15.98)
        }
        specify { check_cart(subject) }
      end
    end

    context "200 or more discounts" do
      describe "stronger percentage off beats weaker fixed price" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$20.01
            $20T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(20.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$19.99
            $20T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger percentage off beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$9.99
            $20T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(10.01)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker percentage off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh-$10.01
            $20T(wine)+ => Sh-50%
          ))

          smp_with_2_2008_merlots_shipping(9.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger amount off beats weaker fixed price discount" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$20
            $20T(wine)+ => Sh-$20.01
          ))

          smp_with_2_2008_merlots_shipping(19.99)
        }
        specify { check_cart(subject) }
      end

      describe "stronger fixed price discount beats weaker amount off" do
        before {
          @check_bot.packs = read_packs(@seller, %(
            [#1P(2008 Merlot)] => Sh$19.99
            $20T(wine)+ => Sh-$20
          ))

          smp_with_2_2008_merlots_shipping(19.98)
        }
        specify { check_cart(subject) }
      end
    end
  end
end
