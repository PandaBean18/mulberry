class Session < ApplicationRecord
  belongs_to :identity
  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

end
