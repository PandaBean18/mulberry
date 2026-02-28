class CreateCampaignParticipants < ActiveRecord::Migration[8.1]
    def change
        create_table :campaign_participants, id: :uuid do |t|
			t.references :campaign, null: false, type: :uuid, foreign_key: true 
			t.references :creator, null: false, type: :uuid, foreign_key: { to_table: :users }
			t.references :conversation, null: false, type: :uuid, foreign_key: true 
			t.string :status, null: false, default: 'invited'
			t.decimal :offered_rate, precision: 10, scale: 2
            t.timestamps
        end
		add_index :campaign_participants, [:campaign_id, :creator_id], unique: true
		add_index :campaign_participants, :status
    end
end
