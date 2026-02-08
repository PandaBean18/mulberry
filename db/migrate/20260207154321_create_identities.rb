class CreateIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false
      t.string :uid
      t.string :password_digest

      t.timestamps
    end

    add_index :identities, [:provider, :uid], unique: true
  end
end
