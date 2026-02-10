class Embedding < ApplicationRecord
    belongs_to :user 
    has_neighbors :description_embedding
end