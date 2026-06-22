class Idea < ApplicationRecord
    belongs_to :user
    has_many :inspos, dependent: :destroy

    validates :title, presence: true
    validate :user_must_be_creator

    private 

    def user_must_be_creator
        if user && user.role != "creator"
            errors.add(:user, "must have the creator role to maintain an idea workspace")
        end
    end
end