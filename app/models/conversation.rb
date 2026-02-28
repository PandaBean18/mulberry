class Conversation < ApplicationRecord
	belongs_to :creator, class_name: "User"
	belongs_to :sponsor, class_name: "User"
	has_many :messages, dependent: :destroy
	belongs_to :campaign, optional: true

	def recipient(current_user)
		current_user == creator ? sponsor : creator
	end
end