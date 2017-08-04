class CreateRawRepos < ActiveRecord::Migration[5.0]
  def change
    create_table :raw_repos do |t|
      t.string :name
      t.integer :state
      t.integer :repo_id
      t.integer :size
    end
  end
end
