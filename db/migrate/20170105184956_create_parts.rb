class CreateParts < ActiveRecord::Migration[5.0]
  def change
    create_table :parts do |t|
      t.string :name
      t.integer :state
      t.integer :repo_id

      t.timestamps
    end
  end
end
