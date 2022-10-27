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

ActiveRecord::Schema[7.0].define(version: 2022_10_27_180302) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "account_type", null: false
    t.string "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "account_credited_id", null: false
    t.bigint "account_debited_id", null: false
    t.string "memo"
    t.string "note"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.integer "percent_shared"
    t.string "imported_transaction_id"
    t.index ["account_credited_id"], name: "index_transactions_on_account_credited_id"
    t.index ["account_debited_id"], name: "index_transactions_on_account_debited_id"
  end

  add_foreign_key "transactions", "accounts", column: "account_credited_id"
  add_foreign_key "transactions", "accounts", column: "account_debited_id"
end
