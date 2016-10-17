class CreateRepoLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :repo_links do |t|
      t.string :repo
      t.string :folder
      t.string :user
      t.timestamps

      t.references :page, foreign_key: true, index: true
    end
  end
end
