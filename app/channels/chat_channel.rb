class ChatChannel < ApplicationCable::Channel
    def subscribed
      	@conversation = Conversation.find(params[:id])

		if @conversation.creator_id == current_user.id || @conversation.sponsor_id == current_user.id
			stream_from "conversation_#{@conversation.id}"
		else
			reject
		end
    end

    def unsubscribed
    end

	def read_message(data)
        message = @conversation.messages.find_by(id: data["message_id"])
        
        if message && message.sender_id != current_user.id && message.read_at.nil?
            message.update!(read_at: Time.current)
			ActionCable.server.broadcast(
                "conversation_#{@conversation.id}", 
                {
                    type: "message_read",
                    message_id: message.id,
                    message: message.body,
                    read_at: message.read_at
                }
            )
        end
    end

    def send_message(data)
        return unless @conversation.creator_id == current_user.id || @conversation.sponsor_id == current_user.id

        message = @conversation.messages.new(
            body: data['body'],
            sender_id: current_user.id
        )

        if message.save
            # do nothing
        else
            transmit({
                type: "error",
                error: "Message body can't be blank",
                code: "VALIDATION_FAILED"
            })
        end
    end
end
