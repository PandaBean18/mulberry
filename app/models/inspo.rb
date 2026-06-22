class Inspo < ApplicationRecord
    belongs_to :idea
    belongs_to :thumbnail_item, class_name: "MediaItem", optional: true, dependent: :destroy

    enum :status, { 
        processing: 0, 
        active: 1, 
        failed: 2 
    }

    validates :source_type, inclusion: { 
        in: %w[direct_upload instagram youtube generic_web],
        message: "%{value} is not a valid source engine" 
    }

    def resolved_thumbnail_url
        if processing?
            temporary_assets&.[]('thumbnail_url')
        elsif %w[youtube generic_web].include?(source_type)
            external_thumbnail_url
        elsif thumbnail_item.present?
            cloudinary_image_url(thumbnail_item.cloudinary_public_id)
        else
            nil
        end
    end

    private

    def cloudinary_image_url(public_id)
        return nil if public_id.blank?
    
        Cloudinary::Utils.cloudinary_url(
            public_id, 
            resource_type: :image
        )
    end
end