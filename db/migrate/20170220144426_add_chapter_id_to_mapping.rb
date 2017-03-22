class AddChapterIdToMapping < ActiveRecord::Migration[5.0]
  def change
    add_column :mappings, :chapter_id, :integer
  end
end
