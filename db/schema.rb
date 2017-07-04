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

ActiveRecord::Schema.define(version: 20170704132941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.json     "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
    t.index ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name", using: :btree
    t.index ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name", using: :btree
  end

  create_table "books", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.integer  "book_id"
    t.string   "name"
    t.string   "url"
    t.string   "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_chapters_on_book_id", using: :btree
  end

  create_table "mappings", force: :cascade do |t|
    t.string   "index_term"
    t.integer  "page_id"
    t.string   "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "chapter_id"
    t.index ["page_id"], name: "index_mappings_on_page_id", using: :btree
  end

  create_table "page_changes", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "namespace"
    t.text     "raw_content"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["namespace"], name: "index_page_changes_on_namespace", using: :btree
    t.index ["page_id"], name: "index_page_changes_on_page_id", using: :btree
    t.index ["title"], name: "index_page_changes_on_title", using: :btree
    t.index ["user_id"], name: "index_page_changes_on_user_id", using: :btree
  end

  create_table "page_verifications", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "from_state", default: false
    t.boolean  "to_state",   default: false
    t.index ["page_id"], name: "index_page_verifications_on_page_id", using: :btree
    t.index ["user_id"], name: "index_page_verifications_on_user_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title"
    t.string   "namespace"
    t.text     "raw_content",  default: ""
    t.text     "html_content", default: ""
    t.string   "used_links",                             array: true
    t.string   "subresources",                           array: true
    t.string   "headline"
    t.boolean  "verified"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.jsonb    "db_sections"
    t.index ["namespace"], name: "index_pages_on_namespace", using: :btree
    t.index ["title", "namespace"], name: "index_pages_on_title_and_namespace", unique: true, using: :btree
    t.index ["title"], name: "index_pages_on_title", using: :btree
    t.index ["verified"], name: "index_pages_on_verified", using: :btree
  end

  create_table "pages_users", id: false, force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "user_id", null: false
  end

  create_table "repo_links", force: :cascade do |t|
    t.string   "repo"
    t.string   "folder"
    t.string   "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "page_id"
    t.index ["page_id"], name: "index_repo_links_on_page_id", using: :btree
  end

  create_table "triples", force: :cascade do |t|
    t.integer "page_id"
    t.string  "predicate", null: false
    t.string  "object"
    t.index ["object"], name: "index_triples_on_object", using: :btree
    t.index ["page_id"], name: "index_triples_on_page_id", using: :btree
    t.index ["predicate", "object"], name: "index_triples_on_predicate_and_object", using: :btree
    t.index ["predicate"], name: "index_triples_on_predicate", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "role",            default: "guest"
    t.string   "name"
    t.string   "github_name"
    t.string   "github_avatar",   default: "http://www.gravatar.com/avatar"
    t.string   "github_token"
    t.string   "github_uid"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.boolean  "developer",       default: false
    t.string   "last_message_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["github_uid"], name: "index_users_on_github_uid", unique: true, using: :btree
    t.index ["name"], name: "index_users_on_name", using: :btree
  end

  create_table "visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_visits_on_user_id", using: :btree
    t.index ["visit_token"], name: "index_visits_on_visit_token", unique: true, using: :btree
  end

  add_foreign_key "chapters", "books"
  add_foreign_key "page_changes", "pages"
  add_foreign_key "page_changes", "users"
  add_foreign_key "repo_links", "pages"
end
