class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :identity, null: false, foreign_key: true, type: :uuid
      t.string :refresh_token_digest, null: false 
      t.string :access_token_identifier, null: false
      t.datetime :revoked_at
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :sessions, :access_token_identifier, unique: true
    add_index :sessions, :refresh_token_digest, unique: true
  end
end
