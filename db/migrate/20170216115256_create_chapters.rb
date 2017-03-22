class CreateChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :name
      t.string :url

      t.timestamps
    end

    create_table :chapters do |t|
      t.references :book, foreign_key: true
      t.string :name
      t.string :url
      t.string :checksum

      t.timestamps
    end
  end
end
