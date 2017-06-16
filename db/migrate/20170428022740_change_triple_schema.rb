class ChangeTripleSchema < ActiveRecord::Migration[5.0]
  def up
    create_table :triples do |t|
      t.references :page
      t.string :predicate, null: false
      t.string :object
    end

    execute('insert into triples(page_id, predicate, object)
      select id, split_part(link, \'::\', 1), split_part(link, \'::\', 2)
      from pages, unnest(used_links) as link where strpos(link, \'::\') > 0'
    )
  end

  def down
    drop_table :triples
  end
end
