class AddExternalUrlFieldsToPortfolioItems < ActiveRecord::Migration[8.1]
    def change
        add_column :portfolio_items, :external_thumbnail_url, :string
        add_column :portfolio_items, :external_embed_url, :string
        add_column :portfolio_items, :source_type, :string, default: "direct_upload" # also instagram and youtube
    end
end
