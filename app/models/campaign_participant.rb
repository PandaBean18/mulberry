class CampaignParticipant < ApplicationRecord
    belongs_to :campaign
    belongs_to :creator, class_name: "User"
    belongs_to :conversation
    
    STATUSES = %w[invited accepted rejected completed].freeze

    validates :status, inclusion: { in: STATUSES }
    validates :campaign_id, uniqueness: { scope: :creator_id, message: "is already participating in this campaign"}
    validates :offered_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    scope :invited, -> { where(status: 'invited') }
    scope :active,  -> { where(status: 'accepted') }
end