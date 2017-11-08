class CreateRepos < ActiveRecord::Migration[5.0]
  def change
    create_table :repos do |t|
      t.string :name
      t.string :link
      t.integer :size
      t.string :rev
      t.integer :state
      t.integer :raw_repo_id

      t.timestamps
    end
  end
end
