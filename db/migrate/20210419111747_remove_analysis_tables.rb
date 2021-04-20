class RemoveAnalysisTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :parts
    drop_table :raw_repos
    drop_table :repos
    drop_table :system_settings
  end
end
