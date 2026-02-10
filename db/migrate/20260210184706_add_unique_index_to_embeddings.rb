class AddUniqueIndexToEmbeddings < ActiveRecord::Migration[8.1]
  def change
    remove_index :embeddings, :user_id if index_exists?(:embeddings, :user_id)
    add_index :embeddings, :user_id, unique: true
  end
end
