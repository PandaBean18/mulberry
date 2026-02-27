class CreateConversations < ActiveRecord::Migration[8.1]
	def change
		create_table :conversations, id: :uuid do |t|
			t.references :creator, null: false, type: :uuid ,foreign_key: { to_table: :users }
			t.references :sponsor, null: false, type: :uuid, foreign_key: { to_table: :users }

			t.timestamps
		end

		add_index :conversations, [:creator_id, :sponsor_id], unique: true
	end
end
