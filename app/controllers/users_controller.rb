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
end
