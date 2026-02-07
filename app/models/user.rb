class User < ApplicationRecord
    enum :role, {creator: "creator", sponsor: "sponsor"}

    validates :username, :email, presence: true, uniqueness: true
    validates :role, inclusion: {in: roles.keys}
end
