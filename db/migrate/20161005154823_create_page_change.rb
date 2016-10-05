class CreatePageChange < ActiveRecord::Migration[5.0]
  def change
    create_table :page_changes do |t|
      t.references :page, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true

      t.string :title
      t.string :namespace
      t.text :raw_content
      t.timestamps

      t.index :title
      t.index :namespace
    end
  end
end
