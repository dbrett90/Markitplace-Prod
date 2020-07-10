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

ActiveRecord::Schema.define(version: 2020_07_10_021452) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id"
    t.text "products"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "one_off_product_id"
    t.integer "guest_user_id"
  end

  create_table "guest_users", force: :cascade do |t|
    t.integer "cart_id"
    t.string "name"
    t.string "email"
    t.string "phone_number"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "product_id"
    t.integer "quantity"
    t.string "product_type"
    t.integer "cart_id"
  end

  create_table "one_off_products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.float "price"
    t.string "partner_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_id"
    t.string "product_id"
    t.integer "user_id"
    t.string "is_trial"
    t.integer "cart_id"
    t.integer "calories"
    t.integer "fats"
    t.integer "protein"
    t.integer "servings"
    t.string "prep_time"
    t.text "extended_description"
    t.string "out_of_stock"
    t.string "hide?"
    t.text "included_cities"
    t.text "available_cities"
    t.integer "sort_priority"
  end

  create_table "partner_logos", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "dedicated_link"
    t.string "hide?"
  end

  create_table "partners_tables", force: :cascade do |t|
  end

  create_table "plan_subscription_libraries", force: :cascade do |t|
    t.integer "plan_type_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "stripe_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan_type_id"
    t.integer "product_id"
    t.decimal "price"
    t.text "extended_description"
    t.text "city_delivery"
    t.string "is_trial"
    t.integer "cart_id"
    t.integer "calories"
    t.integer "protein"
    t.integer "servings"
    t.integer "fats"
    t.string "prep_time"
  end

  create_table "product_subscription_libraries", force: :cascade do |t|
    t.integer "product_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.string "plan_type_name"
    t.string "partner_name"
    t.integer "calories"
    t.integer "protein"
    t.integer "servings"
    t.integer "fats"
    t.integer "user_id"
    t.integer "plan_type_id"
  end

  create_table "quantities", force: :cascade do |t|
    t.integer "quantity"
  end

  create_table "stripe_connect_users", force: :cascade do |t|
    t.string "stripe_id"
    t.string "stripe_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname"
    t.string "lastname"
  end

  create_table "stripe_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.text "stripe_id"
    t.text "stripe_subscription_id"
    t.string "card_last4"
    t.integer "card_exp_month"
    t.integer "card_exp_year"
    t.string "card_type"
    t.boolean "subscribed"
    t.text "one_off_id"
    t.integer "cart_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
