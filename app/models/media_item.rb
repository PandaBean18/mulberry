class MediaItem < ActiveRecord::Base
  belongs_to :user
  enum :media_type, { image: 0, video: 1 }

  validates :cloudinary_public_id, presence: true, uniqueness: true

  def thumbnail_url
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      transformation: [
        { width: 300, height: 300, crop: "fill", quality: "auto", fetch_format: "auto" }
      ]
    )
  end
end