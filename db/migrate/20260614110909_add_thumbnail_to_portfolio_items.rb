class AddThumbnailToPortfolioItems < ActiveRecord::Migration[8.1]
    def change
        add_reference :portfolio_items, :thumbnail_item, type: :uuid, null: true, foreign_key: { to_table: :media_items }
    end
end
