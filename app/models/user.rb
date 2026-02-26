class User < ApplicationRecord
    enum :role, {creator: "creator", sponsor: "sponsor"}
    has_many :identities, dependent: :destroy
    has_many :sessions, through: :identities
    has_one :embedding, dependent: :destroy 
    has_many :media_items, dependent: :destroy
    after_commit :generate_description_embedding, on: :create, if: :creator?

    validates :username, :email, presence: true, uniqueness: true
    validates :description, presence: true, if: :creator?
    validates :role, inclusion: {in: roles.keys}

    private 

    def generate_description_embedding
        GenerateEmbeddingJob.perform_later(self.id)
    end
end
