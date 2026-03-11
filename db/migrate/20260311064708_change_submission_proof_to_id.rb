class ChangeSubmissionProofToId < ActiveRecord::Migration[8.1]
	def change
		remove_column :deliverables, :submission_proof_url, :string 

		add_column :deliverables, :submission_proof_id, :uuid

		add_index :deliverables, :submission_proof_id

		add_foreign_key :deliverables, :media_items, column: :submission_proof_id
	end
end
