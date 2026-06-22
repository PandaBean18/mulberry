class ProcessInspoMediaJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :polynomially_longer, attempts: 3

    def perform(inspo_id)
        inspo = Inspo.find_by(id: inspo_id)
        return if inspo.nil? || !inspo.processing?

        target_url = inspo.temporary_assets&.[]('thumbnail_url')
        if target_url.blank?
            inspo.failed!
            return
        end

        user = inspo.idea.user

        upload_result = Cloudinary::Uploader.upload(
            target_url,
            folder: "twynn/users/user_#{user.id}/ideas/inspos",
            tags: ["user_#{user.id}", "idea_inspo"],
            resource_type: "image"
        )

        ActiveRecord::Base.transaction do
        media_item = user.media_items.create!(
            cloudinary_public_id: upload_result['public_id'],
            media_type: "image",
            label: "portfolio",
            metadata: {
                width: upload_result['width'],
                height: upload_result['height'],
                format: upload_result['format'],
                bytes: upload_result['bytes']
            }
        )

        inspo.update!(
            thumbnail_item: media_item,
            temporary_assets: {},
            status: :active
        )
        end

    rescue => e
        Rails.logger.error "[ProcessInspoMediaJob] Failed processing for Inspo ID #{inspo_id}: #{e.message}"
        
        if executions >= 3
            inspo_fallback = Inspo.find_by(id: inspo_id)
            inspo_fallback&.failed!
        end

        raise e
    end
end