class CreateChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters do |t|
      t.string :url
      t.string :title
      t.string :content
      t.string :check_sum
      t.references :book

      t.timestamps
    end
  end
end
