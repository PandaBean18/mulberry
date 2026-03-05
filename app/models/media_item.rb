class MediaItem < ActiveRecord::Base
    belongs_to :user
    enum :media_type, { image: 0, video: 1 }

    LABELS = %w[avatar portfolio chat deliverable_proof].freeze

    validates :cloudinary_public_id, presence: true, uniqueness: true
    validates :label, inclusion: { in: LABELS }

    scope :avatars, -> { where(label: 'avatar') }
    scope :portfolios, -> { where(label: 'portfolio') }
    scope :proofs, -> { where(label: 'deliverable_proof') }

    before_create :cleanup_old_avatar, if: :is_avatar?

    def thumbnail_url
        res_type = (media_type == 1 || media_type == "video") ? "video" : "image"
        Cloudinary::Utils.cloudinary_url(
          cloudinary_public_id,
          resource_type: res_type,
          transformation: [
              { width: 300, height: 300, crop: "fill", quality: "auto", fetch_format: "jpg" }
          ]
        )
    end

    def url 
        res_type = (media_type == 1 || media_type == "video") ? "video" : "image"

        Cloudinary::Utils.cloudinary_url(cloudinary_public_id, resource_type: res_type);
    end

    private 

    def is_avatar?
        label == 'avatar'
    end

    def cleanup_old_avatar
        old_avatar = user.media_items.find_by(label: 'avatar')

        old_avatar&.destroy
    end
end