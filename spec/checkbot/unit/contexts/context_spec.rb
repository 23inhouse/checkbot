require 'spec_helper'

module Checkbot
  describe Context do
    let(:context) { Context.new }

    describe "#add" do
      subject { context.add(type, input) }

      context "when the input is a cart" do
        let(:type) { :cart }
        let(:input) { Cart.new }
        it { is_expected.to be(input) }
      end

      context "when the input is a discount" do
        let(:type) { :discount }
        let(:input) { Discount.new }
        it { is_expected.to be(input) }
      end

      context "when the input is a mixed pack" do
        let(:type) { :mixed_pack }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to be(input) }
      end

      context "when the input is a product" do
        let(:type) { :product }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to be(input) }
      end

      context "when the input is a tag" do
        let(:type) { :tag }
        let(:input) { Tag.new('name') }
        it { is_expected.to be(input) }
      end
    end

    describe "#carts" do
      subject { context.carts }

      before { context.add(type, input)}

      context "when the input is a cart" do
        let(:type) { :cart }
        let(:input) { Cart.new }
        it { is_expected.to eq([input]) }
      end
    end

    describe "#mixed_packs" do
      subject { context.mixed_packs }

      before { context.add(type, input)}

      context "when the input is a mixed pack" do
        let(:type) { :mixed_pack }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a cart" do
        let(:type) { :cart }
        let(:input) { Cart.new(items) }
        let(:items) { [ CartItem.new(mixed_pack1), CartItem.new(mixed_pack2) ] }
        let(:mixed_pack1) { MixedPack.new('mixed pack 1') }
        let(:mixed_pack2) { MixedPack.new('mixed pack 2') }

        describe "then they are added to the context" do
          it { is_expected.to eq([mixed_pack1, mixed_pack2]) }
        end

        describe "then the cart mixed packs are replaced with the context mixed packs" do
          specify {
            expect(input.items.collect(&:item)).to eq(context.mixed_packs)
          }
        end

        context "when the cart contains items with the same name" do
          let(:mixed_pack3) { MixedPack.new('mixed pack 1') }
          let(:items) { [ CartItem.new(mixed_pack1), CartItem.new(mixed_pack2), CartItem.new(mixed_pack3) ] }

          describe "then the duplicates are NOT added to the context" do
            it { is_expected.to eq([mixed_pack1, mixed_pack2]) }

            describe "and the duplicates are replaced with the originals in the cart" do
              specify {
                expect(input.items.size).to eq(3)
                expect(input.items[0].item).to be(mixed_pack1)
                expect(input.items[1].item).to be(mixed_pack2)
                expect(input.items[2].item).to be(mixed_pack1) # mixed_pack3 is replaced with mixed_pack1
              }
            end
          end
        end
      end

      context "when the input is a discount with mixed packs" do
        let(:type) { :discount }
        let(:input) { Discount.new(packables: packables) }
        let(:packables) {
          [
            Packable.new(mixed_pack1, quantity: 1),
            Packable.new(mixed_pack2, quantity: 1),
          ]
        }
        let(:mixed_pack1) { MixedPack.new('mixed pack 1') }
        let(:mixed_pack2) { MixedPack.new('mixed pack 2') }

        describe "then they are added to the context" do
          it { is_expected.to eq([mixed_pack1, mixed_pack2]) }
        end

        describe "then the discount mixed packs are replaced with the context mixed packs" do
          specify {
            expect(input.packables.collect(&:packable)).to eq(context.mixed_packs)
          }
        end

        context "when the discount contains mixed packs with the same name" do
          let(:mixed_pack3) { MixedPack.new('mixed pack 1') }
          let(:packables) {
            [
              Packable.new(mixed_pack1, quantity: 1),
              Packable.new(mixed_pack2, quantity: 1),
              Packable.new(mixed_pack3, quantity: 1),
            ]
          }

          describe "then the duplicates are NOT added to the context" do
            it { is_expected.to eq([mixed_pack1, mixed_pack2]) }
          end
        end
      end
    end

    describe "#products" do
      subject { context.products }

      before { context.add(type, input)}

      context "when the input is a product" do
        let(:type) { :product }
        let(:input) { MixedPack.new('name') }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a cart" do
        let(:type) { :cart }
        let(:input) { Cart.new(items) }
        let(:items) { [ CartItem.new(product1), CartItem.new(product2) ] }
        let(:product1) { Product.new('product1') }
        let(:product2) { Product.new('product2') }

        describe "then they are added to the context" do
          it { is_expected.to eq([product1, product2]) }
        end

        describe "then the cart products are replaced with the context products" do
          specify {
            expect(input.items.collect(&:item)).to eq(context.products)
          }
        end

        context "when the cart contains items with the same name" do
          let(:product3) { Product.new('product1') }
          let(:items) { [ CartItem.new(product1), CartItem.new(product2), CartItem.new(product3) ] }

          describe "then the duplicates are NOT added to the context" do
            it { is_expected.to eq([product1, product2]) }

            describe "and the duplicates are replaced with the originals in the cart" do
              specify {
                expect(input.items.size).to eq(3)
                expect(input.items[0].item).to be(product1)
                expect(input.items[1].item).to be(product2)
                expect(input.items[2].item).to be(product1) # product3 is replaced with product1
              }
            end
          end
        end
      end

      context "when the input is a discount with products" do
        let(:type) { :discount }
        let(:input) { Discount.new(packables: packables) }
        let(:packables) {
          [
            Packable.new(product1, quantity: 1),
            Packable.new(product2, quantity: 1),
          ]
        }
        let(:product1) { Product.new('product 1') }
        let(:product2) { Product.new('product 2') }

        describe "then they are added to the context" do
          it { is_expected.to eq([product1, product2]) }
        end

        describe "then the discount products are replaced with the context products" do
          specify {
            expect(input.packables.collect(&:packable)).to eq(context.products)
          }
        end

        context "when the discount contains products with the same name" do
          let(:product3) { Product.new('product 1') }
          let(:packables) {
            [
              Packable.new(product1, quantity: 1),
              Packable.new(product2, quantity: 1),
              Packable.new(product3, quantity: 1),
            ]
          }

          describe "then the duplicates are NOT added to the context" do
            it { is_expected.to eq([product1, product2]) }
          end
        end
      end
    end

    describe "#tags" do
      subject { context.tags }

      before { context.add(type, input)}

      context "when the input is a tag" do
        let(:type) { :tag }
        let(:input) { Tag.new('name') }
        it { is_expected.to eq([input]) }
      end

      context "when the input is a discount with tags" do
        let(:type) { :discount }
        let(:input) { Discount.new(packables: packables) }
        let(:packables) {
          [
            Packable.new(tag1, quantity: 1),
            Packable.new(tag2, quantity: 1),
          ]
        }
        let(:tag1) { Tag.new('tag 1') }
        let(:tag2) { Tag.new('tag 2') }

        describe "then they are added to the context" do
          it { is_expected.to eq([tag1, tag2]) }
        end

        describe "then the discount tags are replaced with the context tags" do
          specify {
            expect(input.packables.collect(&:packable)).to eq(context.tags)
          }
        end

        context "when the discount contains tags with the same name" do
          let(:tag3) { Tag.new('tag 1') }
          let(:tags) { [tag1, tag2, tag3] }

          describe "then the duplicates are NOT added to the context" do
            it { is_expected.to eq([tag1, tag2]) }
          end
        end
      end
    end
  end
end
