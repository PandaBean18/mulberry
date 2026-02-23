class CreateMediaItems < ActiveRecord::Migration[8.1]
  def change
    create_table :media_items, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :cloudinary_public_id, null: false
      t.integer :media_type, default: 0
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :media_items, :cloudinary_public_id, unique: true
  end
end
