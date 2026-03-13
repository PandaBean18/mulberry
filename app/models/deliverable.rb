class Deliverable < ApplicationRecord
    belongs_to :campaign_participant
    belongs_to :submission_proof, class_name: 'MediaItem', optional: true
    has_one :calendar_entry, dependent: :nullify
    
    TYPES = %w[story post reel video].freeze
    STATUSES = %w[pending submitted rejected approved].freeze

    validates :deliverable_type, inclusion: { in: TYPES }
    validates :status, inclusion: { in: STATUSES }
    validates :due_date, presence: true
    scope :needs_review, -> { where(status: 'submitted') }
    scope :approved, -> { where(status: 'approved') }

    def submit!(id)
        update!(submission_proof_id: id, status: 'submitted', updated_at: Time.current)
    end

    def approve!
        update!(status: 'approved', feedback: nil)
    end

    def reject!(reason)
        update!(status: 'rejected', feedback: reason)
    end

    def editable?
        %w[pending rejected].include?(status)
    end

end