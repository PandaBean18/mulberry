class CreatePortfolioItems < ActiveRecord::Migration[8.1]
    def change
        create_table :portfolio_items, id: :uuid do |t|
            t.references :user, type: :uuid, null: false, foreign_key: true
            t.references :media_item, type: :uuid, null: true, foreign_key: true, index: { unique: true }

            t.string :title, null: false
            t.text :description
            t.boolean :is_collaborative, default: false, null: false
            t.string :external_url
            t.jsonb :metrics, default: {}, null: false

            t.integer :status, default: 0, null: false
            t.jsonb :temporary_assets, default: {}, null: false

            t.timestamps
        end
        add_index :portfolio_items, :metrics, using: :gin
        add_index :portfolio_items, :status
    end
end
