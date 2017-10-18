class AddIndexToUsedLinks < ActiveRecord::Migration[5.0]
  def change
    add_index :pages, :used_links, using: 'gin'
    add_index :pages, :subresources, using: 'gin'
  end
end
