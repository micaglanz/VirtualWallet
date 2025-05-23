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

ActiveRecord::Schema[8.0].define(version: 2025_05_16_232850) do
  create_table "accounts", id: false, force: :cascade do |t|
    t.string "cvu", null: false
    t.string "dni_owner", null: false
    t.string "password", null: false
    t.integer "balance", default: 0, null: false
    t.boolean "status_active", default: true
    t.string "alias", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alias"], name: "index_accounts_on_alias", unique: true
    t.index ["cvu"], name: "index_accounts_on_cvu", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "source_cvu", null: false
    t.string "destination_cvu", null: false
    t.string "details"
    t.integer "amount", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["destination_cvu"], name: "index_trans_destination_cvu"
    t.index ["source_cvu"], name: "index_trans_source_cvu"
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "dni", null: false
    t.string "name", null: false
    t.string "surname", null: false
    t.string "address", null: false
    t.string "email", null: false
    t.date "date_of_birth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dni"], name: "index_users_on_dni", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "users", column: "dni_owner", primary_key: "dni"
  add_foreign_key "transactions", "accounts", column: "destination_cvu", primary_key: "cvu"
  add_foreign_key "transactions", "accounts", column: "source_cvu", primary_key: "cvu"
end
