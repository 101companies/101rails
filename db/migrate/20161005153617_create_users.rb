class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :role, default: 'guest'
      t.string :name
      t.string :github_name
      t.string :github_avatar, default: 'http://www.gravatar.com/avatar'
      t.string :github_token
      t.string :github_uid

      t.timestamps

      t.index :name
      t.index :github_uid,  unique: true
      t.index :email,       unique: true
    end
  end
end
