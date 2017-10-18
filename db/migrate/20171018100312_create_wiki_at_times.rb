class CreateWikiAtTimes < ActiveRecord::Migration[5.0]
  def change
    create_view :wiki_at_times
  end
end
