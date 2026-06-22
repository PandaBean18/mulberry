class IdeasController < AuthenticatedController
    before_action :set_idea, only: [:show, :update, :destroy]

    def index
        ideas = @current_user.ideas.includes(inspos: :thumbnail_item).order(updated_at: :desc)
    
        render json: ideas.map { |idea| serialize_idea(idea) }, status: :ok
    end

    def show
        render json: serialize_idea(@idea), status: :ok
    end

    def create
        ActiveRecord::Base.transaction do
            @idea = @current_user.ideas.build(
                title: params[:title],
                description: params[:description] || {}
            )

            @idea.save!

            if params[:inspos].present?
                params[:inspos].each do |inspo_params|
                    source_type = inspo_params[:source_type] || "direct_upload"
                    initial_status = (source_type == "instagram") ? :processing : :active

                    inspo = @idea.inspos.build(
                        source_type: source_type,
                        status: initial_status,
                        
                        thumbnail_item_id: inspo_params[:thumbnail_item_id],
                        
                        external_url: inspo_params[:external_url],
                        external_thumbnail_url: inspo_params[:external_thumbnail_url],
                        
                        temporary_assets: source_type == "instagram" ? {
                            thumbnail_url: inspo_params[:temporary_thumbnail_url],
                            media_url: inspo_params[:temporary_media_url] 
                        } : {}
                    )
                    
                    inspo.save!

                    if inspo.processing?
                        ProcessInspoMediaJob.perform_later(inspo.id)
                    end
                end
            end
        end

        render json: serialize_idea(@idea.reload), status: :created
    rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    def update
        if @idea.update(title: params[:title], description: params[:description])
            render json: serialize_idea(@idea), status: :ok
        else
            render json: { errors: @idea.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @idea.destroy
        head :no_content
    end

    private

    def set_idea
        @idea = @current_user.ideas.includes(inspos: :thumbnail_item).find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Idea not found" }, status: :not_found
    end

    def serialize_idea(idea)
        {
            id: idea.id,
            title: idea.title,
            description: idea.description,
            created_at: idea.created_at,
            updated_at: idea.updated_at,
            inspos: idea.inspos.map do |inspo|
                {
                    id: inspo.id,
                    source_type: inspo.source_type,
                    status: inspo.status,
                    external_url: inspo.external_url,
                    thumbnail_url: inspo.resolved_thumbnail_url,
                    created_at: inspo.created_at
                }
            end
        }
    end
end