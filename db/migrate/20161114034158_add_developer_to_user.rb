class AddDeveloperToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :developer, :boolean, default: false
  end
end
