class Identity < ApplicationRecord
  belongs_to :user
  has_many :sessions, dependent: :destroy
  enum :provider, {google: "google", password: "password"}

  validates :provider, inclusion: {in: providers.keys}
  validates :uid, presence: true, if -> {google?}
  validates :password_digest, presence: true, if -> {password?}
end
