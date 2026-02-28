class CreateCampaigns < ActiveRecord::Migration[8.1]
  	def change
		create_table :campaigns, id: :uuid do |t|
			t.references :sponsor, null: false, type: :uuid, foreign_key: { to_table: :users }
			t.string :title, null: false
			t.text :brief, null: false
			t.decimal :budget_total, precision: 10, scale: 2, default: 0.0
			t.string :status, default: 'draft', null: false
			t.timestamps
		end
		add_index :campaigns, :status
  	end
end
