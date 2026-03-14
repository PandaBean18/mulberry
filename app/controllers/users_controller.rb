class UsersController < AuthenticatedController
    def me 
        user_data = @current_user.as_json(except: [:password_digest])

        profile_media = @current_user.media_items.where(label: ['avatar', 'portfolio']).select(:id, :cloudinary_public_id, :media_type, :label)

        render json: {
            user: user_data, 
            avatar: profile_media.find { |m| m.label == 'avatar' }&.as_json(methods: :url),
            portfolio: profile_media.select { |m| m.label == 'portfolio' }.as_json(methods: [:url, :thumbnail_url])
        }
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
