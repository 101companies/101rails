class AddIndexesToTriples < ActiveRecord::Migration[5.0]
  def change
    add_index :triples, :predicate
    add_index :triples, :object
    add_index :triples, %i[predicate object]
  end
end
