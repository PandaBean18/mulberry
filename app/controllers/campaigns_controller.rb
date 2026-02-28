class CampaignController < AuthenticatedController
    before_action :set_campaign, only: [:show, :update, :matches, :invite, :onboard]

    def index
        @campaigns = @current_user.campaigns
        render json: @campaigns
    end

    def create 
        @campaign = @current_user.campaigns.new(campaign_params)
        
        if @campaign.save
            render json: @campaign, status: :created
        else 
            render json: @campaign.errors, status: :unprocessable_entity
        end
    end

    def show 
        render json: @campaign.as_json(include: {
            campaign_participants: { include: :creator }
        })
    end

    def update 
        if @campaign.update(campaign_params)
            render json: @campaign, status: :ok
        else 
            render json: @campaign.errors, status: :unprocessable_entity
        end
    end

    def matches 
        vector = @campaign.embedding.description_embedding

        @top_creators = User.creators
                        .joins(:embedding)
                        .order(Arel.sql("embeddings.description_embedding <=> '#{vector}'"))
                        .limit(10)

        render json: @top_creators
    end

    def invite 
        creator_ids = params[:creator_ids]

        participants = creator_ids.map do |c_id|
            {campaign_id: @campaign.id, creator_id: c_id, status: 'invited'}
        end

        CampaignParticipant.upsert_all(participants, unique_by: [:campaign_id, :creator_id])

        render json: {message: "Invites sent successfully"}, status: :ok
    end

    def onboard
        if @campaign.update(status: 'active')
            render json: { message: "Campaign is now active" }
        else
            render json: @campaign.errors, status: :unprocessable_entity
        end
    end

    private

    def set_campaign
        @campaign = current_user.campaigns.find(params[:id])
    end

    def campaign_params
        params.require(:campaign).permit(:title, :brief, :budget_total, :status)
    end
end