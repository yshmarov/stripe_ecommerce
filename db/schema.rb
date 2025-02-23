# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_17_211711) do
  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 0, null: false
    t.bigint "total_price", default: 0, null: false
    t.bigint "price", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["slug"], name: "index_order_items_on_slug", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.string "status", default: "draft", null: false
    t.string "user_id", null: false
    t.integer "rating"
    t.text "delivery_details"
    t.bigint "total_price", default: 0, null: false
    t.integer "order_items_quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_orders_on_slug", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.bigint "price"
    t.string "image_url"
    t.string "category", default: "food", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "stripe_price_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
end
