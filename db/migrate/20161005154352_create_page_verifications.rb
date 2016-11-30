class CreatePageVerifications < ActiveRecord::Migration[5.0]
  def change
    create_table :page_verifications do |t|
      t.belongs_to(:page, index: true)
      t.belongs_to(:user, index: true)

      t.timestamps

      t.boolean :from_state, default: false
      t.boolean :to_state, default: false
    end
  end
end
