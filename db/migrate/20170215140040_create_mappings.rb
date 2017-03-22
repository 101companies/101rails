class CreateMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :mappings do |t|
      t.string :index_term
      t.references :page
      t.string :comment

      t.timestamps
    end
  end
end
