class CreateDeliverables < ActiveRecord::Migration[8.1]
	def change
		create_table :deliverables, id: :uuid do |t|
			t.references :campaign_participant, null: false, type: :uuid, foreign_key: true 
			t.string :deliverable_type, null: false 
			t.string :status, null: false, default: "pending"
			t.string :submission_proof_url, null: true
			t.string :feedback
			t.timestamps
		end
	end
end
