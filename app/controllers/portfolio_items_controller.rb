class PortfolioItemsController < AuthenticatedController
    def create
        source_type = params[:source_type] || "direct_upload"
        initial_status = (source_type == "instagram") ? :processing : :active

        portfolio_item = @current_user.portfolio_items.build(
            title: params[:title],
            description: params[:description],
            external_url: params[:external_url],
            metrics: params[:metrics] || {},
            status: initial_status,
            source_type: source_type,
            
            external_thumbnail_url: params[:thumbnail_url], # yt
            external_embed_url: params[:media_url], # yt

            media_item_id: params[:media_item_id], # direct media upload
            thumbnail_item_id: params[:thumbnail_item_id], # direct media upload
            
            temporary_assets: source_type == "instagram" ? {
                thumbnail_url: params[:temporary_thumbnail_url],
                media_url: params[:temporary_media_url]
            } : {},
            is_collaborative: params[:is_collaborative]
        )

        if portfolio_item.save
            if portfolio_item.processing?
                ProcessPortfolioMediaJob.perform_later(portfolio_item.id)
            end
            
            render json: portfolio_item, status: :created
        else
            render json: { errors: portfolio_item.errors.full_messages }, status: :unprocessable_entity
        end
    end
end