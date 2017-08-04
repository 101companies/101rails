class ExtendParts < ActiveRecord::Migration[5.0]
  def change
    add_column :parts, :result, :string
    add_column :parts, :dependsOn, :string
  end
end
