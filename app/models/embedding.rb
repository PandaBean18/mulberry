class Embedding < ApplicationRecord
    belongs_to :owner, polymorphic: true 
    has_neighbors :description_embedding
    validates :embedding, presence: true
    validates :owner_id, uniqueness: { scope: :owner_type }
end