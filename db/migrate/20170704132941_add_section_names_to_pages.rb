class AddSectionNamesToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :db_sections, :jsonb

    Page.find_each(&:save!)
  end
end
