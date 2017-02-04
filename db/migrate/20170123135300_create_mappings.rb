class CreateMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :mappings do |t|
      t.integer :kind
      t.string :index_term
      t.string :wiki_term
      t.string :comment
      t.references :book

      t.timestamps
    end
  end
end
