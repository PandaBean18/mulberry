class Deliverable < ApplicationRecord
    belongs_to :campaign_participant
    
    TYPES = %w[story post reel video].freeze
    STATUSES = %w[pending submitted rejected approved].freeze 

    validates :deliverable_type, inclusion: { in: TYPES }
    validates :status, inclusion: { in: STATUSES }

    validates :submission_proof_url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }, allow_blank: true
    validates :due_date, presence: true
    scope :needs_review, -> { where(status: 'submitted') }
    scope :approved, -> { where(status: 'approved') }

    def submit!(url)
        update!(submission_proof_url: url, status: 'submitted', updated_at: Time.current)
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