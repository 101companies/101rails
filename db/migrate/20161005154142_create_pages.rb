class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.string :title
      t.string :namespace
      t.text :raw_content, default: ''
      t.text :html_content, default: ''
      t.string :used_links,   array: true
      t.string :subresources,  array: true
      t.string :headline
      t.boolean :verified

      t.timestamps

      t.index [:title, :namespace], unique: true
      t.index :title
      t.index :namespace
      t.index :verified
    end

    create_join_table :pages, :users
  end
end
