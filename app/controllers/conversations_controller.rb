class ConversationsController < AuthenticatedController
    def create 
        creator_id = @current_user.role == "creator" ? @current_user.id : params[:other_user_id]
        sponsor_id = creator_id == @current_user.id ? params[:other_user_id] : @current_user.id 

        if (creator_id == nil || creator_id == '' || sponsor_id == nil || sponsor_id == '')
            return render json: { error: "other_user_id is required to start a conversation" }, status: :bad_request
        elsif (creator_id == sponsor_id)
            return render json: { error: "You cannot start a conversation with yourself" }, status: :unprocessable_entity
        end

        @conversation = Conversation.find_or_create_by!(
            creator_id: creator_id,
            sponsor_id: sponsor_id
        )

        return render json: @conversation, status: :ok
    end

    def index 
        @conversations = Conversation.where(creator_id: @current_user.id).includes(:campaign).order(updated_at: :desc)

        render json: @conversations.as_json(
            include: {
                campaign: { only: [:id, :title] }
            }, 
            latest_message: { only: [:body, :created_at, :sender_id] }
        )

    end
end