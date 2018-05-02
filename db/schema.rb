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

ActiveRecord::Schema.define(version: 20180428142709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "user_id", null: false
    t.string "code", null: false
    t.text "detail"
    t.json "data", default: {}, null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "feed_items", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.string "guid", null: false
    t.string "title"
    t.string "link"
    t.string "author"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.index ["feed_id", "guid"], name: "index_feed_items_on_feed_id_and_guid", unique: true
    t.index ["feed_id"], name: "index_feed_items_on_feed_id"
    t.index ["guid"], name: "index_feed_items_on_guid"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind"
    t.bigint "created_by_id"
    t.index ["created_by_id"], name: "index_feeds_on_created_by_id"
    t.index ["url"], name: "index_feeds_on_url", unique: true
  end

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], force: :cascade, comment: "3" do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.bigserial "job_id", null: false
    t.text "job_class", null: false
    t.json "args", default: [], null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error"
    t.text "queue", default: "", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "feed_id"
    t.boolean "include_title", default: true, null: false
    t.boolean "shorten_common_terms", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_sent_item_id"
    t.boolean "include_feed_name", default: false, null: false
    t.boolean "include_link", default: true, null: false
    t.integer "character_limit", default: 1600, null: false
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "sms_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
  end

  create_table "verification_codes", force: :cascade do |t|
    t.string "destination", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "events", "users"
  add_foreign_key "feed_items", "feeds"
  add_foreign_key "feeds", "users", column: "created_by_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "users"
end
