class GenerateEmbeddingJob < ApplicationJob
    queue_as :default

    def perform(owner_id, owner_type)
        if (owner_type != 'User' && owner_type != 'Campaign')
            return 
        end

        owner = (owner_type == 'User' ? User.find_by(id: owner_id) : Campaign.find_by(id: owner_id))
        
        if ((owner_type == 'User' && !owner.description.present?) || (owner_type == 'Campaign' && !owner.brief.present?)) 
            return 
        end

        text = (owner_type == 'User' ? owner.description : owner.brief)

        vector = EmbeddingService.generate(text)

        Embedding.upsert({
            owner_id: owner_id,
            owner_type: owner_type
            description_embedding: vector, 
            updated_at: Time.current
        }, unique_by: [:owner_type, :owner_id])
        
    end
end