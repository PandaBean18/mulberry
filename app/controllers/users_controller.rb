class UsersController < AuthenticatedController
    skip_before_action :authenticate_user!, only: [:show]
    def me 
        user_data = @current_user.as_json(except: [:password_digest])
        avatar_item = @current_user.media_items.find_by(label: 'avatar')
        portfolio_items = @current_user.portfolio_items.includes(:media_item, :thumbnail_item)

        render json: {
            user: user_data, 
            avatar: avatar_item&.as_json(methods: :url),
            portfolio: portfolio_items.map { |item|
                {
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    status: item.status,
                    source_type: item.source_type,
                    is_collaborative: item.is_collaborative,
                    external_url: item.external_url,
                    metrics: item.metrics,
                    
                    thumbnail_url: item.resolved_thumbnail_url,
                    media_url: item.resolved_media_url,
                    
                    created_at: item.created_at
                }
            }
        }
    end

def show
    user = User.find(params[:id])

    if user.role != "creator"
        return render json: { error: "Portfolio not found" }, status: :not_found
    end

    user_data = user.as_json(except: [:password_digest])
    avatar_item = user.media_items.find_by(label: 'avatar')
    
    portfolio_items = user.portfolio_items
                            .includes(:media_item, :thumbnail_item)
                            .active
                            .order(created_at: :desc)

    render json: {
        user: user_data,
        avatar: avatar_item&.as_json(methods: :url),
        portfolio: portfolio_items.map { |item|
            {
                id: item.id,
                title: item.title,
                description: item.description,
                status: item.status,
                source_type: item.source_type,
                is_collaborative: item.is_collaborative,
                external_url: item.external_url,
                metrics: item.metrics,
                
                thumbnail_url: item.resolved_thumbnail_url,
                media_url: item.resolved_media_url,
                
                created_at: item.created_at
            }
            }
    }
    rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
    end

    def deliverables
        d = @current_user.deliverables.includes(:submission_proof, campaign_participant: :campaign)
        
        render json: d.as_json(
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
    end
end
