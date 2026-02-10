class CreateEmbeddings < ActiveRecord::Migration[8.1]
  def change
    enable_extension "vector"
    create_table :embeddings, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.column :description_embedding, :vector, limit: 384
      t.timestamps
    end
  end
end
