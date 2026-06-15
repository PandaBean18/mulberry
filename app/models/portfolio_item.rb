class PortfolioItem < ApplicationRecord
    belongs_to :user
    belongs_to :media_item, optional: true, dependent: :destroy
    belongs_to :thumbnail_item, class_name: "MediaItem", optional: true, dependent: :destroy

    validates :title, presence: true
    validate :user_must_be_creator

    enum :status, { 
        processing: 0, 
        active: 1, 
        failed: 2 
    }

    validates :title, presence: true
    validate :user_must_be_creator

    def resolved_thumbnail_url
        if processing?
            temporary_assets&.[]('thumbnail_url')
        elsif source_type == 'youtube'
            external_thumbnail_url
        elsif thumbnail_item.present?
            cloudinary_image_url(thumbnail_item.cloudinary_public_id)
        elsif media_item.present? && media_item.video?
            Cloudinary::Utils.cloudinary_url(
                media_item.cloudinary_public_id,
                resource_type: :video,
                format: :jpg,
                transformation: [{ start_offset: "0.0", height: 720, crop: "limit" }]
            )
        else
            nil
        end
    end

    def resolved_media_url
        if processing?
            temporary_assets&.[]('media_url')
        elsif source_type == 'youtube'
            external_embed_url
        elsif media_item.present?
            cloudinary_video_url(media_item.cloudinary_public_id)
        else
            nil
        end
    end

    private

    def user_must_be_creator
        if user && user.role != "creator"
            errors.add(:user, "must have the creator role to maintain a portfolio")
        end
    end

    def cloudinary_image_url(public_id)
        return nil if public_id.blank?
        
        Cloudinary::Utils.cloudinary_url(
            public_id, 
            resource_type: :image
        )
    end

    def cloudinary_video_url(public_id)
        return nil if public_id.blank?
        
        Cloudinary::Utils.cloudinary_url(
            public_id, 
            resource_type: :video
        )
    end
end