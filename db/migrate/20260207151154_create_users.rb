class CreateUsers < ActiveRecord::Migration[8.1]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  def change
    create_table :users, id: :uuid do |t|
      t.string :username
      t.string :email
      t.string :role
      t.string :timezone

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
