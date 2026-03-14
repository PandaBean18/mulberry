class DeliverablesController < AuthenticatedController
    before_action :set_deliverable, only: [:submit, :approve, :reject]

    def create 
        if @current_user.role != 'sponsor'
            return render json: { error: "Not authorized" }, status: :unauthorized
        end

        @deliverable = Deliverable.new(deliverable_params)

        if @deliverable.save 
            return render json: @deliverable, status: :created
        else 
            return render json: @deliverable.errors, status: :unprocessable_entity
        end
    end

    def show
        @deliverable = Deliverable.find(params[:id]) 

        if (@current_user.id == @deliverable.campaign_participant.creator_id || @current_user.id == @deliverable.campaign_participant.campaign.sponsor_id) 
            return render json: @deliverable.as_json(
                include: {
                    campaign_participant: {
                        only: [:id],
                        include: {
                            campaign: { only: [:id, :title, :brief] }
                        }
                    },
                    submission_proof: {
                        only: [:id, :cloudinary_public_id, :media_type],
                        methods: [:url, :thumbnail_url]
                    },
                    calendar_entry: {
                        only: [:id, :date]
                    }
                }
            )
        else 
            return render json: { error: "Not authorized" }, status: :unauthorized
        end
        
    end

    def submit
        if @current_user.id != @deliverable.campaign_participant.creator_id 
            return render json: { error: "Not authorized" }, status: :unauthorized
        end

        if @deliverable.submit!(params[:submission_proof_id])
            render json: @deliverable
        else 
            render json: @deliverable.errors, status: :unprocessable_entity
        end
    end

    def approve
        if authorize_sponsor!
            @deliverable.approve 
            rener json: @deliverable
        end
    end

    def reject 
        if authorize_sponsor!
            if params[:feedback].blank?
                return render json: { error: "Feedback is required for rejection" }, status: :bad_request
            end

            @deliverable.reject!(params[:feedback])
            render json: @deliverable
        end
    end

    private 

    def deliverable_params
        params.require(:deliverable).permit(:campaign_participant_id, :deliverable_type, :status)
    end

    def set_deliverable
        @deliverable = Deliverable.find(params[:id])
    end

    def authorize_sponsor!
        campaign = @deliverable.campaign_participant.campaign

        if campaign.sponsor_id == @current_user.id 
            true 
        else 
            render json: { error: "Only the campaign sponsor can perform this action" }, status: :unauthorized
            false
        end
    end

end