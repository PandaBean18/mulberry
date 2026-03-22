class Message < ApplicationRecord
    belongs_to :conversation
    belongs_to :sender, class_name: "User"
    validates :body, presence: true
    
    after_create_commit { broadcast_message }

    def sender_label(current_user_id)
        sender_id == current_user_id ? "creator" : "sponsor"
    end

    private

    def broadcast_message
        ActionCable.server.broadcast(
            "conversation_#{conversation.id}",
            {
                id: id,
                body: body,
                sender_id: sender_id,
                created_at: created_at,
                username: sender.email
            }
        )    
    end
end