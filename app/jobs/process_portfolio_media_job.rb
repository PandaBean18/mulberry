class ProcessPortfolioMediaJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :polynomially_longer, attempts: 3
    def perform(portfolio_item_id)
        item = PortfolioItem.find_by(id: portfolio_item_id)
        return unless item && item.processing?

        if item.source_type == "youtube"
            item.update!(status: :active)
            return
        end

        temporary_assets = item.temporary_assets
        return if temporary_assets.blank?

        begin
            uploaded_data = upload_to_cloudinary(temporary_assets)
                            primary_media = nil
            if uploaded_data[:media_id]
                primary_media = MediaItem.create!(
                        cloudinary_public_id: uploaded_data[:media_id],
                        media_type: uploaded_data['resource_type'] == "video" ? :video : :image,
                        label: 'portfolio',
                        user_id: item.user_id
                    )
            end

            thumbnail_media = nil
            if uploaded_data[:thumbnail_id]
                thumbnail_media = MediaItem.create!(
                        cloudinary_public_id: uploaded_data[:thumbnail_id],
                        media_type: uploaded_data['resource_type'] == "video" ? :video : :image,
                        label: 'portfolio',
                        user_id: item.user_id
                    )
            end
            

            item.update!(
                media_item: primary_media,
                thumbnail_item: thumbnail_media,
                status: :active,
                temporary_assets: {}
            )

        rescue StandardError => e
            Rails.logger.error("[ProcessPortfolioMediaJob] Failed for Item #{item.id}: #{e.message}")
            item.update!(status: :failed)
            raise e
        end
    end

    private 

    def upload_to_cloudinary(assets)
        results = {}
        
        if assets['media_url'].present?
            video_response = Cloudinary::Uploader.upload(
                assets['media_url'],
                resource_type: "video",
                end_offset: "10.0",
                transformation: [{ height: 720, crop: "limit" }]
            )
            results[:media_id] = video_response['public_id']
        end

        if assets['thumbnail_url'].present?
            image_response = Cloudinary::Uploader.upload(
                assets['thumbnail_url'],
                resource_type: "image",
                transformation: [{ height: 720, crop: "limit" }]
            )
            results[:thumbnail_id] = image_response['public_id']
        end

        results
    end
end