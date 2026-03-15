class CalendarEntry < ApplicationRecord
    belongs_to :user
    belongs_to :deliverable, optional: true

    TYPES = %w[reel post video story other].freeze

    validates :title, :date, :entry_type, presence: true
    validates :entry_type, inclusion: { in: TYPES }

    def complete
        update!(is_completed: true)
    end

    def undo_complete
        update!(is_completed: false)
    end

end