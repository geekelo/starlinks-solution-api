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

ActiveRecord::Schema[7.1].define(version: 2025_02_25_021549) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "starlink_kit_renewals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "deadline", null: false
    t.uuid "starlink_kit_id", null: false
    t.uuid "starlink_user_wallet_id", null: false
    t.uuid "starlink_user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "status", default: "invoice"
    t.boolean "credit_admin", default: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.date "date_of_renewal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starlink_kit_id"], name: "index_starlink_kit_renewals_on_starlink_kit_id"
    t.index ["starlink_user_id"], name: "index_starlink_kit_renewals_on_starlink_user_id"
    t.index ["starlink_user_wallet_id"], name: "index_starlink_kit_renewals_on_starlink_user_wallet_id"
  end

  create_table "starlink_kits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "kit_number", null: false
    t.string "address", null: false
    t.string "nin", null: false
    t.string "company_name"
    t.string "company_number"
    t.string "status", default: "pending", null: false
    t.string "service_line_number"
    t.uuid "starlink_plan_id", null: false
    t.uuid "starlink_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starlink_plan_id"], name: "index_starlink_kits_on_starlink_plan_id"
    t.index ["starlink_user_id"], name: "index_starlink_kits_on_starlink_user_id"
  end

  create_table "starlink_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "status", default: "optional", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "starlink_kit_id"
    t.index ["starlink_kit_id"], name: "index_starlink_plans_on_starlink_kit_id", unique: true
  end

  create_table "starlink_user_wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "starlink_user_id", null: false
    t.string "wallet_id", limit: 6, null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starlink_user_id"], name: "index_starlink_user_wallets_on_starlink_user_id"
    t.index ["wallet_id"], name: "index_starlink_user_wallets_on_wallet_id", unique: true
  end

  create_table "starlink_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "phone_number"
    t.string "name", null: false
    t.string "whatsapp_number"
    t.boolean "email_confirmed", default: false
    t.boolean "whatsapp_number_confirmed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "role", default: "user", null: false
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string "whatsapp_confirmation_token"
    t.datetime "whatsapp_confirmation_sent_at"
    t.boolean "otsp", default: false
    t.index ["confirmation_token"], name: "index_starlink_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_starlink_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_starlink_users_on_reset_password_token", unique: true
  end

  create_table "starlink_wallet_fundings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "starlink_user_id", null: false
    t.uuid "starlink_user_wallet_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.string "paid", default: "no", null: false
    t.string "reference", null: false
    t.string "payment_method", null: false
    t.string "transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_starlink_wallet_fundings_on_reference", unique: true
    t.index ["starlink_user_id"], name: "index_starlink_wallet_fundings_on_starlink_user_id"
    t.index ["starlink_user_wallet_id"], name: "index_starlink_wallet_fundings_on_starlink_user_wallet_id"
    t.index ["transaction_id"], name: "index_starlink_wallet_fundings_on_transaction_id", unique: true
  end

  add_foreign_key "starlink_kit_renewals", "starlink_kits"
  add_foreign_key "starlink_kit_renewals", "starlink_user_wallets"
  add_foreign_key "starlink_kit_renewals", "starlink_users"
  add_foreign_key "starlink_kits", "starlink_plans"
  add_foreign_key "starlink_kits", "starlink_users"
  add_foreign_key "starlink_user_wallets", "starlink_users"
  add_foreign_key "starlink_wallet_fundings", "starlink_user_wallets"
  add_foreign_key "starlink_wallet_fundings", "starlink_users"
end
