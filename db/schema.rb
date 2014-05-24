# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140521034628) do

  create_table "carts", force: true do |t|
    t.integer  "seller_id"
    t.string   "postcode"
    t.decimal  "handling_charges"
    t.decimal  "price_discount"
    t.decimal  "price_rrp"
    t.decimal  "price_subtotal"
    t.integer  "quantity"
    t.decimal  "shipping_charges"
    t.decimal  "shipping_discount"
    t.decimal  "shipping_rrp"
    t.decimal  "shipping_subtotal"
    t.decimal  "total"
    t.decimal  "total_rrp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carts", ["seller_id"], name: "index_carts_on_seller_id"

  create_table "conditional_reward_packs", force: true do |t|
    t.integer  "conditional_pack_id"
    t.integer  "reward_pack_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discount_tallies", force: true do |t|
    t.integer  "cart_id"
    t.integer  "price_pack_id"
    t.string   "price_pack_name"
    t.decimal  "price_discount"
    t.integer  "shipping_pack_id"
    t.string   "shipping_pack_name"
    t.decimal  "shipping_discount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discount_tallies", ["cart_id"], name: "index_discount_tallies_on_cart_id"

  create_table "items", force: true do |t|
    t.integer  "cart_id"
    t.integer  "winelist_id"
    t.string   "winelist_name"
    t.decimal  "price"
    t.integer  "quantity"
    t.string   "full_name"
    t.decimal  "price_subtotal"
    t.decimal  "price_discount"
    t.integer  "price_pack_id"
    t.string   "price_pack_name"
    t.decimal  "price_rrp"
    t.decimal  "shipping_discount"
    t.integer  "shipping_pack_id"
    t.string   "shipping_pack_name"
    t.decimal  "shipping_rrp"
    t.decimal  "shipping_subtotal"
    t.integer  "specific_mixed_pack_id"
    t.string   "specific_mixed_pack_name"
    t.integer  "purchasable_id"
    t.string   "purchasable_type"
    t.decimal  "shipping_price",               precision: 10, scale: 2
    t.decimal  "specific_mixed_pack_quantity", precision: 10, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["cart_id"], name: "index_items_on_cart_id"
  add_index "items", ["winelist_id"], name: "index_items_on_winelist_id"

  create_table "packed_products", force: true do |t|
    t.integer  "pack_id"
    t.integer  "packable_id"
    t.string   "packable_type"
    t.decimal  "amount"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packed_products", ["pack_id"], name: "index_packed_products_on_pack_id"
  add_index "packed_products", ["packable_id"], name: "index_packed_products_on_packable_id"

  create_table "packs", force: true do |t|
    t.integer  "seller_id"
    t.integer  "winelist_id"
    t.date     "release_date"
    t.text     "description"
    t.decimal  "discount_amount_off"
    t.decimal  "discount_percentage_off"
    t.decimal  "discount_price"
    t.string   "name"
    t.boolean  "or_more"
    t.string   "photo"
    t.decimal  "shipping_amount_off"
    t.decimal  "shipping_percentage_off"
    t.decimal  "shipping_price"
    t.boolean  "qualify_for_price_discount",    default: true
    t.boolean  "qualify_for_shipping_discount", default: true
    t.boolean  "receive_price_discount",        default: true
    t.boolean  "receive_shipping_discount",     default: true
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packs", ["seller_id"], name: "index_packs_on_seller_id"
  add_index "packs", ["winelist_id"], name: "index_packs_on_winelist_id"

  create_table "product_listings", force: true do |t|
    t.integer  "seller_id"
    t.integer  "listable_id"
    t.string   "listable_type"
    t.integer  "minimum_per_order"
    t.integer  "maximum_per_order"
    t.integer  "number_available"
    t.integer  "position"
    t.boolean  "hidden",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_listings", ["seller_id"], name: "index_product_listings_on_seller_id"

  create_table "sellers", force: true do |t|
    t.decimal  "handling_charges"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.integer  "seller_id"
    t.string   "name"
    t.boolean  "generated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "winelists", force: true do |t|
    t.integer  "seller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "winelists", ["seller_id"], name: "index_winelists_on_seller_id"

  create_table "wines", force: true do |t|
    t.integer  "seller_id"
    t.string   "year",                          limit: 4
    t.string   "name"
    t.date     "release_date"
    t.decimal  "price"
    t.integer  "number_of_cases_produced"
    t.decimal  "alcohol",                                 precision: 4, scale: 2
    t.decimal  "acid",                                    precision: 4, scale: 2
    t.decimal  "pH",                                      precision: 4, scale: 2
    t.decimal  "residual_sugar",                          precision: 6, scale: 2
    t.decimal  "volatile_acids",                          precision: 4, scale: 1
    t.integer  "sulphur"
    t.text     "tasting_notes"
    t.text     "vintage_report"
    t.text     "maturation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",                                                        default: false
    t.boolean  "qualify_for_price_discount",                                      default: true
    t.boolean  "qualify_for_shipping_discount",                                   default: true
    t.boolean  "receive_price_discount",                                          default: true
    t.boolean  "receive_shipping_discount",                                       default: true
    t.decimal  "standard_drinks",                         precision: 4, scale: 2
    t.string   "photo"
    t.decimal  "weight",                                  precision: 5, scale: 3
    t.integer  "ships_as"
    t.string   "bottle_name",                                                     default: "bottle"
  end

  add_index "wines", ["seller_id"], name: "index_wines_on_seller_id"

end
