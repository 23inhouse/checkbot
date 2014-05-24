require 'spec_helper'

describe DiscountDecorator do
  include PackReader

  let(:discount_decorator) { DiscountDecorator.new(@discount) }
  let(:seller) { Seller.new }
  let(:winelist) { Winelist.new(:seller => seller) }
  let(:wine) { seller.wines.first }
  let(:tag) { seller.tags.build(:seller => seller, :name => 'holiday special') }

  before {
    seller.wines.build(:year => 2008, :name => 'Merlot', :price => 20)
    seller.tags.build(:name => 'red wine')
    seller.tags.build(:name => 'wine')
  }

  describe "default_buy_component" do
    subject { discount_decorator.default_buy_component }

    context "is quantity" do
      context "with or more flag" do
        before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D-20%') }
        it { should eq('6 or more') }
      end

      context "without or more flag" do
        before { @discount = read_pack_notation(seller, winelist, '#12T(red-wine) => D-20%') }
        it { should eq('12') }
      end
    end

    context "is amount" do
      context "with or more flag" do
        before { @discount = read_pack_notation(seller, winelist, '$200P(2008-merlot)+ => D-20%') }
        it { should eq('$200 or more') }
      end

      context "without or more flag" do
        before { @discount = read_pack_notation(seller, winelist, '$200T(red-wine) => D-20%') }
        it { should eq('$200') }
      end
    end
  end

  describe "default_discount_component" do
    subject { discount_decorator.default_discount_component }

    context "when there is a #6 amount off price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D-$12') }
      it { should eq('$12 off') }
    end

    context "when there is a #6 amount off shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => Sh-$12') }
      it { should eq('$12 off shipping for') }
    end

    context "when there is a $200 amount off price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$120P(2008-merlot)+ => D-$12') }
      it { should eq('$12 off') }
    end

    context "when there is a $200 amount off shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$120P(2008-merlot)+ => Sh-$12') }
      it { should eq('$12 off shipping for') }
    end

    context "when there is a #6 percentage off price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D-20%') }
      it { should eq('20% off') }
    end

    context "when there is a #6 percentage off shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => Sh-20%') }
      it { should eq('20% off shipping for') }
    end

    context "when there is a $200 percentage off price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$100P(2008-merlot)+ => D-20%') }
      it { should eq('20% off') }
    end

    context "when there is a $200 percentage off shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$100P(2008-merlot)+ => Sh-20%') }
      it { should eq('20% off shipping for') }
    end

    context "when there is a #6 fixed price price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D$72') }
      it { should eq('$72 for') }
    end

    context "when there is a #6 fixed price shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => Sh$72') }
      it { should eq('$72 shipping for') }
    end

    context "when there is a $200 fixed price price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$120P(2008-merlot)+ => D$84') }
      it { should eq('$84 for') }
    end

    context "when there is a $200 fixed price shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$120P(2008-merlot)+ => Sh$84') }
      it { should eq('$84 shipping for') }
    end

    context "when there is a #6 free shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => Sh-100%') }
      it { should eq('free shipping for') }
    end
  end

  describe "default_item_component" do
    subject { discount_decorator.default_item_component }

    context "on products" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D-20%') }

      describe "with single item" do
        it { should eq('of the 2008 Merlot') }
      end
    end

    context "on tags" do
      before { @discount = read_pack_notation(seller, winelist, '#6T(red-wine)+ => D-20%') }

      describe "with colour Red tag" do
        it { should eq('of any red wine') }
      end
    end
  end

  describe "data_name" do
    subject { discount_decorator.data_name }

    context "when there's a wine price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200P(2008-merlot)+ => D-20%') }
      it { should eq('20% off $200 or more of the 2008 Merlot') }
    end

    context "when there's a wine shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping for 6 of the 2008 Merlot') }
    end

    context "when there's a tag price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12T(red-wine)+ => D-$20') }
      it { should eq('$20 off 12 or more of any red wine') }
    end

    context "when there's a tag shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200T(wine) => Sh-10%') }
      it { should eq('10% off shipping for $200 of any wine') }
    end

    context "when there's a wine price discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot)+ => D-20%') }
      it { should eq('20% off 1 or more of the 2008 Merlot') }
    end

    context "when there's a wine shipping discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping for 1 of the 2008 Merlot') }
    end

    context "when there's a tag price discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1T(red-wine)+ => D-$20') }
      it { should eq('$20 off 1 or more of any red wine') }
    end

    context "when there's a tag shipping discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1T(wine) => Sh-10%') }
      it { should eq('10% off shipping for 1 of any wine') }
    end

    context "Free wine" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot) => D-100%') }
      it { should eq('100% off 1 of the 2008 Merlot') }
    end

    context "Free shipping" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot) => Sh-100%') }
      it { should eq('free shipping for 1 of the 2008 Merlot') }
    end
  end

  describe "default_name" do
    subject { discount_decorator.default_name }

    context "when there's a wine price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200P(2008-merlot)+ => D-20%') }
      it { should eq('20% off $200 or more of the 2008 Merlot') }
    end

    context "when there's a wine shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping for 6 of the 2008 Merlot') }
    end

    context "when there's a tag price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12T(red-wine)+ => D-$20') }
      it { should eq('$20 off 12 or more of any red wine') }
    end

    context "when there's a tag shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200T(wine) => Sh-10%') }
      it { should eq('10% off shipping for $200 of any wine') }
    end

    context "when there's a wine price discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot)+ => D-20%') }
      it { should eq('20% off any 2008 Merlot') }
    end

    context "when there's a wine shipping discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping for any 2008 Merlot') }
    end

    context "when there's a tag price discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1T(red-wine)+ => D-$20') }
      it { should eq('$20 off any red wine') }
    end

    context "when there's a tag shipping discount for 1" do
      before { @discount = read_pack_notation(seller, winelist, '#1T(wine) => Sh-10%') }
      it { should eq('10% off shipping for any wine') }
    end

    context "Free wine" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot) => D-100%') }
      it { should eq('100% off any 2008 Merlot') }
    end

    context "Free shipping" do
      before { @discount = read_pack_notation(seller, winelist, '#1P(2008-merlot) => Sh-100%') }
      it { should eq('free shipping for any 2008 Merlot') }
    end
  end

  describe "google_name" do
    subject { discount_decorator.google_name(wine) }

    context "when there's a wine price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200P(2008-merlot)+ => D-20%') }
      it { should eq('$16 each for $200 or more of the 2008 Merlot') }
    end

    context "when there's a wine shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping for 6 of the 2008 Merlot') }
    end

    context "when there's a tag price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12T(red-wine)+ => D$200') }
      it { should eq('$16.67 each for 12 or more of any red wine') }
    end

    context "when there's a tag shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200T(wine) => Sh-10%') }
      it { should eq('10% off shipping for $200 of any wine') }
    end
  end

  describe "google_short_name" do
    subject { discount_decorator.google_short_name(wine) }

    context "when there's a wine price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200P(2008-merlot)+ => D-20%') }
      it { should eq('$16 each for $200 or more') }
    end

    context "when there's a wine shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping for 6') }
    end

    context "when there's a tag price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12T(red-wine)+ => D-10%') }
      it { should eq('$18 each for 12 or more') }
    end

    context "when there's a tag shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200T(wine) => Sh-10%') }
      it { should eq('10% off shipping for $200') }
    end
  end

  describe "log" do
    subject { discount_decorator.log }
    before { @discount = Discount.new }

    describe "price discount" do
      before { @discount.packed_products.build(:quantity => 12, :packable => wine) }

      context "when it's a fixed price" do
        before { @discount.discount_price = 100.12345 }
        it { should eq(' D $100.1235 #12P(2008-merlot)') }
      end

      context "when it's an amount off" do
        before { @discount.discount_amount_off = 10.12345 }
        it { should eq(' D-$10.1235 #12P(2008-merlot)') }
      end

      context "when it's an percentage off" do
        before { @discount.discount_percentage_off = 15.12345 }
        it { should eq(' D-15.1235% #12P(2008-merlot)') }
      end
    end

    describe "shipping discount" do
      before { @discount.packed_products.build(:quantity => 12, :packable => wine) }

      context "when it's a fixed price" do
        before { @discount.shipping_price = 100 }
        it { should eq('Sh $100 #12P(2008-merlot)') }
      end

      context "when it's an amount off" do
        before { @discount.shipping_amount_off = 10 }
        it { should eq('Sh-$10 #12P(2008-merlot)') }
      end

      context "when it's an percentage off" do
        before { @discount.shipping_percentage_off = 15 }
        it { should eq('Sh-15% #12P(2008-merlot)') }
      end
    end

    context "when it's an amount discount" do
      before { @discount.discount_price = 50 }

      context "and it's very precise" do
        before { @discount.packed_products.build(:amount => 100, :packable => wine) }
        it { should eq(' D $50 $100P(2008-merlot)') }
      end

      context "and it's very precise" do
        before { @discount.packed_products.build(:amount => 100.12345, :packable => wine) }
        it { should eq(' D $50 $100.1235P(2008-merlot)') }
      end
    end

    context "when it's or more" do
      context "when it's a fixed price" do
        before {
          @discount.discount_price = 100.1
          @discount.or_more = true
          @discount.packed_products.build(:quantity => 12, :packable => wine)
        }

        it { should eq(' D $100.1 #12P(2008-merlot)+') }
      end
    end

    context "when it's a tag" do
      context "when it's a fixed price" do
        before {
          @discount.discount_price = 100
          @discount.packed_products.build(:quantity => 12, :packable => tag)
        }
        it { should eq(' D $100 #12T(holiday-special)') }
      end
    end
  end

  describe "name_for_customer" do
    subject { discount_decorator.name_for_customer(wine) }

    context "when there's a wine price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot)+ => D-20%') }
      it { should eq('12 or more for $192') }
    end

    context "when there's a wine price discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200P(2008-merlot)+ => D-20%') }
      it { should eq('$200 or more for $160') }
    end

    context "when there's a wine shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot) => Sh$10') }
      it { should eq('$10 shipping when you buy 6') }
    end

    context "when there's a tag price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6T(red-wine)+ => D-$20') }
      it { should eq('6 or more for $100') }
    end

    context "when there's a tag shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '$200T(wine) => Sh-10%') }
      it { should eq('10% off shipping when you spend $200') }
    end

    context "when there's a wine price discount with a discount less than $1 per bottle" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot)+ => D-1%') }
      it { should eq('12 or more for $237.60') }
    end
  end

  describe "notation" do
    subject { discount_decorator.notation }
    before { @discount = Discount.new }

    describe "price discount" do
      before { @discount.packed_products.build(:quantity => 12, :packable => wine) }

      context "when it's a fixed price" do
        before { @discount.discount_price = 100.12345 }
        it { should eq('#12P(2008-merlot) => D$100.1235') }
      end

      context "when it's an amount off" do
        before { @discount.discount_amount_off = 10.12345 }
        it { should eq('#12P(2008-merlot) => D-$10.1235') }
      end

      context "when it's an percentage off" do
        before { @discount.discount_percentage_off = 15.12345 }
        it { should eq('#12P(2008-merlot) => D-15.1235%') }
      end
    end

    describe "shipping discount" do
      before { @discount.packed_products.build(:quantity => 12, :packable => wine) }

      context "when it's a fixed price" do
        before { @discount.shipping_price = 100 }
        it { should eq('#12P(2008-merlot) => Sh$100') }
      end

      context "when it's an amount off" do
        before { @discount.shipping_amount_off = 10 }
        it { should eq('#12P(2008-merlot) => Sh-$10') }
      end

      context "when it's an percentage off" do
        before { @discount.shipping_percentage_off = 15 }
        it { should eq('#12P(2008-merlot) => Sh-15%') }
      end
    end

    context "when it's an amount discount" do
      before { @discount.discount_price = 50 }

      context "and it's very precise" do
        before { @discount.packed_products.build(:amount => 100, :packable => wine) }
        it { should eq('$100P(2008-merlot) => D$50') }
      end

      context "and it's very precise" do
        before { @discount.packed_products.build(:amount => 100.12345, :packable => wine) }
        it { should eq('$100.1235P(2008-merlot) => D$50') }
      end
    end

    context "when it's or more" do
      context "when it's a fixed price" do
        before {
          @discount.discount_price = 100.1
          @discount.or_more = true
          @discount.packed_products.build(:quantity => 12, :packable => wine)
        }

        it { should eq('#12P(2008-merlot)+ => D$100.1') }
      end
    end

    context "when it's a tag" do
      context "when it's a fixed price" do
        before {
          @discount.discount_price = 100
          @discount.packed_products.build(:quantity => 12, :packable => tag)
        }
        it { should eq('#12T(holiday-special) => D$100') }
      end
    end
  end

  describe "savings_component" do
    subject { discount_decorator.save_component }

    context "price amount off discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot) => D-$20') }
      it { should eq('(save $1.67 per bottle)') }
    end

    context "price fixed price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot) => D$200') }
      it { should eq('(save $3.33 per bottle)') }
    end

    context "price percentage off discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot) => D-20%') }
      it { should eq('(save $4 per bottle)') }
    end

    context "or more price amount off discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot)+ => D-$20') }
      it { should eq('(save $1.67 per bottle)') }
    end
    context "or more price fixed price discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot)+ => D$200') }
      it { should eq('(save $3.33 per bottle)') }
    end
    context "or more price percentage off discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot)+ => D-20%') }
      it { should eq('(save $4 per bottle)') }
    end

    context "shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#12P(2008-merlot) => Sh-100%') }
      it { should be_nil }
    end
  end

  describe "unit_shipping_discount_component" do
    subject { discount_decorator.unit_shipping_discount_component }

    context "when there is a #6 free shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => Sh-100%') }
      it { should eq('free shipping for') }
    end
  end

  describe "unit_price_component" do
    subject { discount_decorator.unit_price_component }

    context "when it's a shipping discount" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot) => Sh-$12') }
      it { should be_nil }
    end

    context "when it's tag discount without a wine reference" do
      before { @discount = read_pack_notation(seller, winelist, '#6P(wine)+ => D-$12') }
      it { should be_nil }
    end

    context "when the discount is on a wine" do
      context "and it's a #6 amount off discount" do
        before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D-$12') }
        it { should eq('$18') }
      end

      context "and it's a $200 amount off discount" do
        before { @discount = read_pack_notation(seller, winelist, '$120P(2008-merlot)+ => D-$12') }
        it { should eq('$18') }
      end

      context "and it's a #6 percentage off discount" do
        before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D-20%') }
        it { should eq('$16') }
      end

      context "and it's a $200 percentage off discount" do
        before { @discount = read_pack_notation(seller, winelist, '$100P(2008-merlot)+ => D-20%') }
        it { should eq('$16') }
      end

      context "and it's a #6 fixed price discount" do
        before { @discount = read_pack_notation(seller, winelist, '#6P(2008-merlot)+ => D$72') }
        it { should eq('$12') }
      end

      context "and it's a $200 fixed price discount" do
        before { @discount = read_pack_notation(seller, winelist, '$120P(2008-merlot)+ => D$84') }
        it { should eq('$14') }
      end
    end

    context "when the discount is on a tag with a wine reference" do
      subject { discount_decorator.unit_price_component(wine) }

      context "and it's a #6 amount off discount" do
        before { @discount = read_pack_notation(seller, winelist, '#6P(wine)+ => D-$12') }
        it { should eq('$18') }
      end
    end
  end
end
