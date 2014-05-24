require 'spec_helper'

describe CheckoutBot do
  let(:seller) { Seller.new }
  let(:cart) { Cart.new }
  let(:packs) { [] }
  let(:check_bot) { CheckoutBot.new(seller, cart, packs) }

  # describe "handling_charges" do
  #   subject { check_bot.handling_charges }
  #   it { should be_a(BigDecimal) }
  #   it { should eq(0) }

  #   context "when handling_as_percentage is false" do
  #     before {
  #       seller.handling_as_percentage = false
  #       seller.handling_charges = 5.55
  #     }
  #     it { should eq(5.55) }
  #   end

  #   context "when handling_as_percentage is true" do
  #     before {
  #       seller.handling_as_percentage = true
  #       seller.handling_charges = 3.15
  #     }
  #     it { should eq(0) }

  #     context "when handling_charge is 3.15" do
  #       before {
  #         check_bot.stub(:total_price_rrp).and_return(100.0.to_d)
  #       }
  #       it { should eq(3.15) }

  #       context "when the cart's subtotal is 165.37" do
  #         before {
  #           check_bot.stub(:total_price_rrp).and_return(165.37.to_d)
  #         }
  #         it { should eq(5.209155) }
  #       end
  #     end
  #   end
  # end

  describe "number_of_bottles" do
    subject { check_bot.number_of_bottles }

    context "whene there are no items" do
      it { should eq(0) }
    end

    context "when the cart has items" do
      before {
        cart.items.build(:quantity => 3)
        cart.items.build(:quantity => 2)
      }
      it { should eq(5) }
    end

    context "when the cart has a mixed pack item" do
      let(:mixed_pack) { MixedPack.new }
      before {
        mixed_pack.stub(:quantity).and_return(3)
        cart.items.build(:quantity => 3)
        cart.items.build(:quantity => 2, :purchasable => mixed_pack)
      }
      it { should eq(9) }
    end
  end

  describe "scd_charges" do
    subject { check_bot.scd_charges }
    it { should be_a(BigDecimal) }

    context "when transaction_charge is 3.5% and price_subtotal is $100" do
      before {
        check_bot.stub(:total_price).and_return(100)
        cart.stub(:transaction_charge).and_return(0.035.to_d)
      }
      it { should eq(3.5) }
    end
  end

  describe "shipping_charges" do
    subject { check_bot.shipping_charges }

    context "when there are no postcodes" do
      before {
        cart.stub(:shipping_charges).and_return(nil)
      }
      it { should be_nil }
    end

    context "when there are items an normal" do
      before {
        cart.stub(:shipping_charges).and_return(9.99)
      }
      it { should eq(9.99) }
    end
  end
end
