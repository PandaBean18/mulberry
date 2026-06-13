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
        @conversations = Conversation.where(creator_id: @current_user.id).includes(:campaign, :latest_message).order(updated_at: :desc)

        render json: @conversations.map {|conv| 
            msg = conv.latest_message

            {
                id: conv.id,
                updated_at: conv.updated_at,
                campaign: conv.campaign.as_json(only: [:id, :title]),
                creator_id: conv.creator_id,
                sponsor_id: conv.sponsor_id,
                latest_message: msg ? {
                    body: msg.body,
                    created_at: msg.created_at,
                    read_at: msg.read_at,
                    sender_id: msg.sender_id,
                    sender_label: msg.sender_id == @current_user.id ? "creator" : "sponsor"
                } : nil
            }
        }
    end

    def show
        @conversation = Conversation.find_by(id: params[:id])

        if @conversation.nil? || (@conversation.creator_id != @current_user.id && @conversation.sponsor_id)
            return render json: { error: "Conversation not found or access denied" }, status: :not_found
        end

        @conversation.messages.where.not(sender_id: @current_user.id).where(read_at: nil).update_all(read_at: Time.current)
        @messages = @conversation.messages.order(created_at: :asc)
        render json: {
            id: @conversation.id,
            campaign: @conversation.campaign&.as_json(only: [:id, :title]),
            creator_id: @conversation.creator_id,
            sponsor_id: @conversation.sponsor_id,
            messages: @messages.map { |msg|
                {
                    id: msg.id,
                    body: msg.body,
                    sender_id: msg.sender_id,
                    sender_label: msg.sender_label(@current_user.id),
                    created_at: msg.created_at,
                    read_at: msg.read_at
                }
            }
        }, status: :ok
    end
end