# DEBUG = true

require 'spec_helper'

describe CheckoutBot do
  subject { @check_bot.new_cart }

  before {
    @check_bot = CheckoutBot.new


    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(nil)
  }

  context "when wines are excluded from qualifing or receiving discounts" do
    before {
      read_wines(@seller, %(
        2009 Cleanskin $5 [0000]
        2010 Cleanskin $5 [0101]
        2010 Merlot $10 [1111]
        2010 Premium $50 [1010]
      ))

      @check_bot.packs = read_packs(@seller, %(
        #4T(wine)+ => D-50%
      ))
    }

    describe "they qualify and receive" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #2(2009 Cleanskin $5) -> $10
          #2(2010 Premium $20)  -> $40
          #2(2010 Cleanskin $5) -> $10 ($5)
          #2(2010 Merlot $10)   -> $20 ($10)
                       subtotal => $65
        ))
      }
      specify { check_cart(subject) }
    end
  end

  context "when packs are excluded from qualifing or receiving discounts" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }

    context "when a pack qualifys for and receives discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => D-10%
          [#12P(N.V. Cleanskin)] [1111] => D$50
        ))
      }

      describe "it gets the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50 ($45)
                             subtotal => $45
          ))
        }
        specify { check_cart(subject) }
      end

      describe "both get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1P(2008 Merlot $20)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #1P(2008 Merlot $20)      -> $20 ($18)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50 ($45)
                             subtotal => $63
          ))
        }
        specify { check_cart(subject) }
      end
    end

    context "when a pack is excluded from discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => D-10%
          [#12P(N.V. Cleanskin)] [0000] => D$50
        ))
      }

      describe "it doesn't get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50
                             subtotal => $50
          ))
        }
        specify { check_cart(subject) }
      end

      describe "only it doesn't get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #6P(2008 Merlot $20)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #6P(2008 Merlot $20)      -> $120 ($108)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50
                             subtotal => $158
          ))
        }
        specify { check_cart(subject) }
      end
    end

    context "when a pack is excluded from qualifying from discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => D-10%
          [#12P(N.V. Cleanskin)] [1010] => D$50
        ))
      }

      describe "it doesn't get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50
                             subtotal => $50
          ))
        }
        specify { check_cart(subject) }
      end

      describe "only it doesn't get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1P(2008 Merlot $20)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #1P(2008 Merlot $20)      -> $20 ($18)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50
                             subtotal => $68
          ))
        }
        specify { check_cart(subject) }
      end
    end

    context "when a pack is excluded from receiving discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => D-10%
          [#12P(N.V. Cleanskin)] [1010] => D$50
        ))
      }

      describe "it doesn't get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50
                             subtotal => $50
          ))
        }
        specify { check_cart(subject) }
      end

      describe "only it doesn't get the discount" do
        before {
          @check_bot.cart = read_cart_input(@seller, %(
            #1P(2008 Merlot $20)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]
          ))

          read_cart_output(@seller, %(
            #1P(2008 Merlot $20)      -> $20 ($18)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> $50
                             subtotal => $68
          ))
        }
        specify { check_cart(subject) }
      end
    end
  end
end
