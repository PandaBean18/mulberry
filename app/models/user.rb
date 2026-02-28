class User < ApplicationRecord
    enum :role, {creator: "creator", sponsor: "sponsor"}
    has_many :identities, dependent: :destroy
    has_many :sessions, through: :identities
    has_one :embedding, as: :owner, dependent: :destroy
    has_many :media_items, dependent: :destroy
    has_many :campaigns, foreign_key: :sponsor_id, dependent: :destroy
    has_many :campaign_participants, foreign_key: :creator_id, dependent: :destroy # this returns all the entries
                                                                                   # in campaign_participants table 
                                                                                   # where the creator id is user id
                                                                                   
    has_many :participating_campaigns, through: :campaign_participants, source: :campaign
    after_commit :generate_description_embedding, on: :create, if: :creator?

    validates :username, :email, presence: true, uniqueness: true
    validates :description, presence: true, if: :creator?
    validates :role, inclusion: {in: roles.keys}

    private 

    def generate_description_embedding
        GenerateEmbeddingJob.perform_later(self.id, 'User')
    end
end
