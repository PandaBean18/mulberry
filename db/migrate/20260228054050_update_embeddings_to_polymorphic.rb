class UpdateEmbeddingsToPolymorphic < ActiveRecord::Migration[8.1]
  	def change
		remove_foreign_key :embeddings, :users
		rename_column :embeddings, :user_id, :owner_id
		add_column :embeddings, :owner_type, :string, null: false, default: 'User'
		remove_index :embeddings, :owner_id if index_exists?(:embeddings, :owner_id)
    	add_index :embeddings, [:owner_type, :owner_id], unique: true
  	end
end
