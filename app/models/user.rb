class User < ApplicationRecord
    enum :role, {creator: "creator", sponsor: "sponsor"}
    has_many :identities, dependent: :destroy

    validates :username, :email, presence: true, uniqueness: true
    validates :role, inclusion: {in: roles.keys}
end
