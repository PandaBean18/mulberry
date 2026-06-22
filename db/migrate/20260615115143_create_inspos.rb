class CreateInspos < ActiveRecord::Migration[8.1]
    def change
        create_table :inspos, id: :uuid do |t|
            t.references :idea, null: false, foreign_key: true, type: :uuid
            t.string :source_type, null: false, default: "direct_upload"
            t.integer :status, null: false, default: 0
            t.references :thumbnail_item, null: true, foreign_key: { to_table: :media_items }, type: :uuid
            t.string :external_url
            t.string :external_thumbnail_url
            t.jsonb :temporary_assets, null: false, default: {}
            t.timestamps
        end
    end
end
