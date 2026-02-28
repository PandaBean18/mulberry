class InviteCreatorJob < ApplicationJob
    queue_as :default

    def perform(creator_id, campaign_id, sponsor_id)
        participant = CampaignParticipant.find_by(campaign_id: campaign_id, creator_id: creator_id)
        return if participant&.status == 'invited'

        conversation = Conversation.find_or_create_by!(creator_id: creator_id , sponsor_id: sponsor_id, campaign_id: campaign_id)

        if !conversation.save
            return 
        end 
        
        CampaignParticipant.upsert({
            campaign_id: campaign_id, 
            creator_id: creator_id, 
            conversation_id: conversation.id
        }, unique_by: [:campaign_id, :creator_id]) 
    end
end