class AddCampaignToConversations < ActiveRecord::Migration[8.1]
    def change
		add_reference :conversations, :campaign, type: :uuid, foreign_key: true, null: true 
		add_index :conversations, :campaign_id unless index_exists?(:conversations, :campaign_id)
    end 
end
