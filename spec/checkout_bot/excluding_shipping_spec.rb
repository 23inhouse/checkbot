require 'spec_helper'

describe CheckoutBot do
  subject { @check_bot.new_cart }

  before {
    @check_bot = CheckoutBot.new
    @check_bot.shipping_charge = 100

    @seller = Seller.new
    @check_bot.seller = @seller
    @check_bot.stub(:shipping_charges).and_return(100.0.to_d)
    @check_bot.stub(:shipping_per_item).and_return(1.0.to_d)
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
        #4T(wine)+ => Sh-50%
      ))
    }

    describe "they qualify and receive" do
      before {
        @check_bot.cart = read_cart(@seller, %(
          #2(2009 Cleanskin $5) sh -> $2
          #2(2010 Premium $20)  sh -> $2
          #2(2010 Cleanskin $5) sh -> $2 ($1)
          #2(2010 Merlot $10)   sh -> $2 ($1)
                       shipping => $6
        ))
      }
      specify { check_cart(subject, true) }
    end
  end

  context "when packs are excluded from qualifing or receiving discounts" do
    subject { CartDecorator.new(@check_bot.new_cart).generate_cart_by_price }

    context "when a pack qualifys for and receives discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => Sh-10%
          [#12P(N.V. Cleanskin)] [1111] => Sh$50
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
            ]                         -> Sh $50 ($45)
                             shipping => $45
          ))
        }
        specify { check_cart(subject, true) }
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
            #1P(2008 Merlot $20)      -> Sh $1 ($0.9)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> Sh $50 ($45)
                             shipping => $45.9
          ))
        }
        specify { check_cart(subject, true) }
      end
    end

    context "when a pack is excluded from discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => Sh-10%
          [#12P(N.V. Cleanskin)] [0000] => Sh$50
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
            ]                         -> Sh $50
                             shipping => $50
          ))
        }
        specify { check_cart(subject, true) }
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
            #6P(2008 Merlot $20)      -> Sh $6 ($5.4)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> Sh $50
                             shipping => $55.4
          ))
        }
        specify { check_cart(subject, true) }
      end
    end

    context "when a pack is excluded from qualifying from discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => Sh-10%
          [#12P(N.V. Cleanskin)] [1010] => Sh$50
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
            ]                         -> Sh $50
                             shipping => $50
          ))
        }
        specify { check_cart(subject, true) }
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
            #1P(2008 Merlot $20)      -> Sh $1 ($0.9)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> Sh $50
                             shipping => $50.9
          ))
        }
        specify { check_cart(subject, true) }
      end
    end

    context "when a pack is excluded from receiving discounts" do
      before {
        @check_bot.packs = read_packs(@seller, %(
          #6T(wine)+ => Sh-10%
          [#12P(N.V. Cleanskin)] [1010] => Sh$50
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
            ]                         -> Sh $50
                             shipping => $50
          ))
        }
        specify { check_cart(subject, true) }
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
            #1P(2008 Merlot $20)      -> Sh $1 ($0.9)
            #1[#12P(N.V. Cleanskin)] [
              #12P(N.V. Cleanskin $7)
            ]                         -> Sh $50
                             shipping => $50.9
          ))
        }
        specify { check_cart(subject, true) }
      end
    end
  end
end
