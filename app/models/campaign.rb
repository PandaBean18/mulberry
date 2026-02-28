class Campaign < ApplicationRecord
    belongs_to :sponsor, class_name: 'User'
    has_one :embedding, as: :owner, dependent: :destroy

    validates :title, :brief, presence: true
    validates :budget_total, numericality: { greater_than_or_equal_to: 0 }
    validates :status, inclusion: { in: %w[draft active completed cancelled] } 

    after_save :generate_vector_embedding, if: :save_change_to_brief?

    private 

    def generate_vector_embedding
        GenerateEmbeddingJob.perform_later(self.id, "Campaign")
    end
end