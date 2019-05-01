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

ActiveRecord::Schema.define(version: 2019_04_29_234540) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
    t.string "team"
    t.string "start_time"
    t.string "end_time"
    t.string "work_days"
    t.boolean "admin"
  end

  create_table "calendar_l2s", force: :cascade do |t|
    t.date "date"
    t.float "base_value"
    t.integer "signed_up_total"
    t.text "signed_up_agents", default: [], array: true
    t.float "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendar_l3s", force: :cascade do |t|
    t.date "date"
    t.float "base_value"
    t.integer "signed_up_total"
    t.text "signed_up_agents", default: [], array: true
    t.float "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendar_sups", force: :cascade do |t|
    t.date "date"
    t.float "base_value"
    t.integer "signed_up_total"
    t.text "signed_up_agents", default: [], array: true
    t.float "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendars", force: :cascade do |t|
    t.date "date"
    t.float "base_value"
    t.integer "signed_up_total"
    t.text "signed_up_agents", default: [], array: true
    t.float "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "date_values", force: :cascade do |t|
    t.date "date"
    t.float "base_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pto_requests", force: :cascade do |t|
    t.string "reason"
    t.date "request_date"
    t.integer "cost"
    t.integer "signed_up_total"
    t.integer "user_id"
    t.integer "humanity_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "admin_note"
    t.boolean "excused"
    t.string "position"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.integer "bank_value", default: 0, null: false
    t.integer "humanity_user_id"
    t.boolean "ten_hour_shift", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
    t.string "team"
    t.string "start_time"
    t.string "end_time"
    t.integer "work_days", default: [], array: true
    t.boolean "admin"
    t.boolean "on_pip"
    t.integer "no_call_show"
    t.integer "make_up_days"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
