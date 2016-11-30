class AddLastMessageIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_message_id, :string
  end
end
