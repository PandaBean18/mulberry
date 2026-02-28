class Campaign < ApplicationRecord
    belongs_to :sponsor, class_name: 'User'
    has_one :embedding, as: :owner, dependent: :destroy
    has_many :campaign_participants, dependent: :destroy
    has_many :creators, through: :campaign_participants
    has_many :conversations, dependent: :nullify
    has_many :deliverables, through: :campaign_participants

    validates :title, :brief, presence: true
    validates :budget_total, numericality: { greater_than_or_equal_to: 0 }
    validates :status, inclusion: { in: %w[draft active completed cancelled] } 

    after_save :generate_vector_embedding, if: :saved_change_to_brief?

    private 

    def generate_vector_embedding
        GenerateEmbeddingJob.perform_later(self.id, "Campaign")
    end
end