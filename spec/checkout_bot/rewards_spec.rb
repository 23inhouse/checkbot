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

  describe "Rewards" do
    context "when reward is different to condition" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $127.5
        ))
      }

      describe "then apply discount to reward" do
        specify { check_cart(subject) }
      end
    end

    context "when reward is identical as condition" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Merlot) => D-50% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Merlot $15)
                      subtotal => $127.5
        ))
        read_cart_output(@seller, %(
          #7(2008 Merlot $20)
                      subtotal => $70
        ))
      }

      describe "then apply discount to reward" do
        specify { check_cart(subject) }
      end
    end

    context "when condition has no discount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $127.5
        ))
      }

      describe "then only reward is applied" do
        specify { check_cart(subject) }
      end
    end

    context "when has a discount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot) => D-20%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $103.5
        ))
      }

      describe "then both reward and condition's discount are applied" do
        specify { check_cart(subject) }
      end
    end

    context "when condition offers greater benefit than reward" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Merlot) => D-10% <- #6T(Merlot) => D-20%
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Merlot $20)
                      subtotal => $114
        ))
      }

      describe "then 6 Merlot (condition) receive 20% and 1 Merlot (reward) receives 10%" do
        specify { check_cart(subject) }
      end
    end

    context "when there are multiple conditions and one is not satisfied" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot) & #6T(Cabernet)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $135
        ))
      }

      describe "then no reward is applied" do
        specify { check_cart(subject) }
      end
    end

    context "when there are multiple conditions and both are satisfied" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot) & #6T(Cabernet)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Cabernet $20)
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $247.5
        ))
      }

      describe "then the reward receives discount" do
        specify { check_cart(subject) }
      end
    end

    context "when there are multiple rewards" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% & #1T(Cabernet) => D-20% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Cabernet $15)
          #1(2008 Shiraz $15)
                      subtotal => $144
        ))
      }

      describe "then both rewards are applied" do
        specify { check_cart(subject) }
      end
    end

    context "when there is a price reward" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $127.5
        ))
      }

      describe "then 1 Shiraz (reward) receives 50% off price" do
        specify { check_cart(subject) }
      end
    end

    context "when there is a shipping reward" do
      before {
        @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => Sh-50% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $135
                      shipping => $6.5
        ))
      }

      describe "then 1 Shiraz (reward) receives 50% off shipping" do
        specify { check_cart(subject) }
      end
    end

    context "when condition is on quantity" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $127.5
        ))
      }

      describe "then 1 Shiraz (reward) receives discount" do
        specify { check_cart(subject) }
      end
    end

    context "when condition is on amount" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- $100T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #6(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $127.5
        ))
      }

      describe "then 1 Shiraz receives discount" do
        specify { check_cart(subject) }
      end
    end

    # REMOVED the context "when condition is a specific mixed pack"

    context "when condition has or_more flag set to true" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-50% <- #5T(Merlot)+
        ))
        @check_bot.cart = read_cart(@seller, %(
          #20(2008 Merlot $20)
          #1(2008 Shiraz $15)
                      subtotal => $407.5
        ))
      }

      describe "then 1 Shiraz (reward) receives discount (only once)" do
        specify { check_cart(subject) }
      end
    end

    context "when same condition is met multiple times" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1T(Shiraz) => D-$2 <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #20(2008 Merlot $20)
          #2(2008 Shiraz $15)
                      subtotal => $426
        ))
      }

      describe "then the reward is applied multiple times" do
        specify { check_cart(subject) }
      end
    end

    context "when the condition is NOT met" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #1P(2008 Shiraz) => D-100% <- #6T(Merlot)
        ))
        @check_bot.cart = read_cart(@seller, %(
          #2(2008 Shiraz $15)
                      subtotal => $30
        ))
      }

      describe "then the reward is NOT applied" do
        specify { check_cart(subject) }
      end
    end
  end
end
