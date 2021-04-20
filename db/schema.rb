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

ActiveRecord::Schema.define(version: 2021_04_19_111747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", id: :serial, force: :cascade do |t|
    t.integer "visit_id"
    t.integer "user_id"
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name"
    t.index ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name"
  end

  create_table "books", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chapters", id: :serial, force: :cascade do |t|
    t.integer "book_id"
    t.string "name"
    t.string "url"
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  create_table "mappings", id: :serial, force: :cascade do |t|
    t.string "index_term"
    t.integer "page_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chapter_id"
    t.index ["page_id"], name: "index_mappings_on_page_id"
  end

  create_table "page_changes", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.integer "user_id"
    t.string "title"
    t.string "namespace"
    t.text "raw_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace"], name: "index_page_changes_on_namespace"
    t.index ["page_id"], name: "index_page_changes_on_page_id"
    t.index ["title"], name: "index_page_changes_on_title"
    t.index ["user_id"], name: "index_page_changes_on_user_id"
  end

  create_table "page_verifications", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "from_state", default: false
    t.boolean "to_state", default: false
    t.index ["page_id"], name: "index_page_verifications_on_page_id"
    t.index ["user_id"], name: "index_page_verifications_on_user_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "namespace"
    t.text "raw_content", default: ""
    t.text "html_content", default: ""
    t.string "used_links", array: true
    t.string "subresources", array: true
    t.string "headline"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "db_sections"
    t.index ["namespace"], name: "index_pages_on_namespace"
    t.index ["subresources"], name: "index_pages_on_subresources", using: :gin
    t.index ["title", "namespace"], name: "index_pages_on_title_and_namespace", unique: true
    t.index ["title"], name: "index_pages_on_title"
    t.index ["used_links"], name: "index_pages_on_used_links", using: :gin
    t.index ["verified"], name: "index_pages_on_verified"
  end

  create_table "pages_users", id: false, force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "user_id", null: false
  end

  create_table "repo_links", id: :serial, force: :cascade do |t|
    t.string "repo"
    t.string "folder"
    t.string "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "page_id"
    t.index ["page_id"], name: "index_repo_links_on_page_id"
  end

  create_table "triples", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.string "predicate", null: false
    t.string "object"
    t.index ["object"], name: "index_triples_on_object"
    t.index ["page_id"], name: "index_triples_on_page_id"
    t.index ["predicate", "object"], name: "index_triples_on_predicate_and_object"
    t.index ["predicate"], name: "index_triples_on_predicate"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "role", default: "guest"
    t.string "name"
    t.string "github_name"
    t.string "github_avatar", default: "http://www.gravatar.com/avatar"
    t.string "github_token"
    t.string "github_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "developer", default: false
    t.string "last_message_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_uid"], name: "index_users_on_github_uid", unique: true
    t.index ["name"], name: "index_users_on_name"
  end

  create_table "visits", id: :serial, force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.integer "user_id"
    t.string "referring_domain"
    t.string "search_keyword"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
    t.index ["visit_token"], name: "index_visits_on_visit_token", unique: true
  end

  add_foreign_key "chapters", "books"
  add_foreign_key "page_changes", "pages"
  add_foreign_key "page_changes", "users"
  add_foreign_key "repo_links", "pages"

  create_view "wiki_at_times", sql_definition: <<-SQL
      SELECT pages.id,
      COALESCE(page_changes.title, pages.title) AS title,
      pages.namespace,
      COALESCE(page_changes.raw_content, pages.raw_content) AS raw_content,
      COALESCE(page_changes.created_at, pages.created_at) AS valid_from
     FROM (pages
       LEFT JOIN page_changes ON ((page_changes.page_id = pages.id)));
  SQL
end
