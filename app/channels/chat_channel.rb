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
end
