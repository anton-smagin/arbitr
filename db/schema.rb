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

ActiveRecord::Schema.define(version: 20180328155540) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arbitrage_statistics", force: :cascade do |t|
    t.float "percent"
    t.string "symbol"
    t.string "first_market"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "second_market"
    t.boolean "notified", default: false
  end

  create_table "arbitrages", force: :cascade do |t|
    t.string "from_price"
    t.string "to_price"
    t.string "from_market"
    t.string "to_market"
    t.string "symbol"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buys", force: :cascade do |t|
    t.string "price"
    t.string "symbol"
    t.bigint "arbitrage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arbitrage_id"], name: "index_buys_on_arbitrage_id"
  end

  create_table "sells", force: :cascade do |t|
    t.string "price"
    t.string "symbol"
    t.bigint "arbitrage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arbitrage_id"], name: "index_sells_on_arbitrage_id"
  end

  create_table "spread_trades", force: :cascade do |t|
    t.string "exchange"
    t.string "symbol"
    t.string "status"
    t.bigint "buy_order_id"
    t.float "buy_price"
    t.float "buy_amount"
    t.bigint "sell_order_id"
    t.float "sell_price"
    t.float "sell_amount"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.string "address"
    t.string "coin"
    t.bigint "arbitrage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arbitrage_id"], name: "index_transactions_on_arbitrage_id"
  end

end
