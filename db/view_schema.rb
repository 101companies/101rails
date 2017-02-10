require 'sequent/support'

Sequent::Support::ViewSchema.define(view_projection: Sequent::Support::ViewProjection.new(name: 'view_schema', version: 1, event_handlers: [PageProjector.new], definition: 'db/view_schema.rb')) do

  enable_extension 'plpgsql'

  create_table 'books', force: :cascade do |t|
    t.string   'name'
    t.string   'url'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'chapters', force: :cascade do |t|
    t.string   'url',         null: false
    t.string   'title',       null: false
    t.string   'content'
    t.string   'check_sum'
    t.string   'book_id',     null: false
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
    t.index ['book_id'], name: 'index_chapters_on_book_id', using: :btree
  end

  create_table 'mappings', force: :cascade do |t|
    t.integer  'kind'
    t.string   'index_term'
    t.string   'wiki_term'
    t.string   'comment'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'page_changes', force: :cascade do |t|
    t.string  'page_id',      null: false
    t.string  'user_id',      null: false
    t.string   'title',       null: false
    t.string   'namespace',   null: false
    t.text     'raw_content', null: false
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
    t.index ['namespace'], name: 'index_page_changes_on_namespace', using: :btree
    t.index ['page_id'], name: 'index_page_changes_on_page_id', using: :btree
    t.index ['title'], name: 'index_page_changes_on_title', using: :btree
    t.index ['user_id'], name: 'index_page_changes_on_user_id', using: :btree
  end

  create_table 'page_verifications', force: :cascade do |t|
    t.string  'page_id',     null: false
    t.string  'user_id',     null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean  'from_state', default: false
    t.boolean  'to_state',   default: false
    t.index ['page_id'], name: 'index_page_verifications_on_page_id', using: :btree
    t.index ['user_id'], name: 'index_page_verifications_on_user_id', using: :btree
  end

  create_table 'pages', force: :cascade do |t|
    t.string   'aggregate_id',  null: false
    t.string   'title',        null: false
    t.string   'namespace',    null: false
    t.text     'raw_content',  default: '', null: false
    t.text     'html_content', default: '', null: false
    t.string   'used_links',   default: [], array: true
    t.string   'subresources', default: [], array: true
    t.string   'headline'
    t.boolean  'verified',    default: false, null: false
    t.datetime 'created_at',                null: false
    t.datetime 'updated_at',                null: false
    t.index ['namespace'], name: 'index_pages_on_namespace', using: :btree
    t.index ['title', 'namespace'], name: 'index_pages_on_title_and_namespace', unique: true, using: :btree
    t.index ['title'], name: 'index_pages_on_title', using: :btree
    t.index ['verified'], name: 'index_pages_on_verified', using: :btree
  end
  add_index :pages, ["aggregate_id"], unique: true

  create_table 'pages_users', id: false, force: :cascade do |t|
    t.string 'page_id', null: false
    t.string 'user_id', null: false
  end

  create_table 'repo_links', force: :cascade do |t|
    t.string   'repo'
    t.string   'folder'
    t.string   'user'
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
    t.integer  'page_record_id',      null: false
    t.index ['page_record_id'], name: 'index_repo_links_on_page_id', using: :btree
  end

  create_table 'users', force: :cascade do |t|
    t.string 'aggregate_id', null: false
    t.string   'email'
    t.string   'role',            default: 'guest', null: false
    t.string   'name'
    t.string   'github_name'
    t.string   'github_avatar',   default: 'http://www.gravatar.com/avatar'
    t.string   'github_token'
    t.string   'github_uid'
    t.datetime 'created_at',                                                 null: false
    t.datetime 'updated_at',                                                 null: false
    t.boolean  'developer',       default: false, null: false
    t.string   'last_message_id'
    t.index ['email'], name: 'index_users_on_email', unique: true, using: :btree
    t.index ['github_uid'], name: 'index_users_on_github_uid', unique: true, using: :btree
    t.index ['name'], name: 'index_users_on_name', using: :btree
  end

  add_index :users, ["aggregate_id"], unique: true

  # add_foreign_key 'page_changes', 'pages'
  # add_foreign_key 'page_changes', 'users'

end
