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

ActiveRecord::Schema[7.0].define(version: 2023_11_01_174931) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "account_type", null: false
    t.string "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ignore_in_charts", default: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "budgeted_amounts", force: :cascade do |t|
    t.integer "year", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "frequency", default: "monthly"
    t.integer "month", default: 1
    t.index ["account_id"], name: "index_budgeted_amounts_on_account_id"
  end

  create_table "other_party_accounts", force: :cascade do |t|
    t.bigint "other_party_id", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_other_party_accounts_on_account_id"
    t.index ["other_party_id"], name: "index_other_party_accounts_on_other_party_id"
  end

  create_table "owner_accounts", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.bigint "account_id", null: false
    t.decimal "ownership_percent", precision: 4, scale: 2, null: false
    t.index ["account_id"], name: "index_owner_accounts_on_account_id"
    t.index ["owner_id"], name: "index_owner_accounts_on_owner_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.decimal "default_ownership_percent", precision: 4, scale: 2, null: false
  end

  create_table "transaction_imports", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "account_credited_id"
    t.bigint "account_debited_id"
    t.string "memo"
    t.string "note"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.integer "percent_shared"
    t.string "imported_transaction_id"
    t.string "type"
    t.string "status", default: "active"
    t.bigint "parent_id"
    t.index ["account_credited_id"], name: "index_transactions_on_account_credited_id"
    t.index ["account_debited_id"], name: "index_transactions_on_account_debited_id"
    t.index ["parent_id"], name: "index_transactions_on_parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "other_party_accounts", "accounts"
  add_foreign_key "other_party_accounts", "owners", column: "other_party_id"
  add_foreign_key "owner_accounts", "accounts"
  add_foreign_key "owner_accounts", "owners"
  add_foreign_key "transactions", "accounts", column: "account_credited_id"
  add_foreign_key "transactions", "accounts", column: "account_debited_id"
  add_foreign_key "transactions", "transactions", column: "parent_id"
end
