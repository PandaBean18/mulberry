class MessagesController < AuthenticatedController
    def create
        @conversation = Conversation.find(params[:conversation_id])
        @message = @conversation.messages.new(message_params)
        @message.sender = @current_user

        if @message.save
            render json: @message, status: :created
        else
            render json: @message.errors, status: :unprocessable_entity
        end
    end

    private

    def message_params
        params.require(:message).permit(:body)
    end
end