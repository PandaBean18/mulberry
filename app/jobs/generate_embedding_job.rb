class GenerateEmbeddingJob < ApplicationJob
    queue_as :default

    def perform(user_id)
        user = User.find_by(id: user_id)

        if (!user.description.present?) 
            return 
        end

        vector = EmbeddingService.generate(user.description)

        Embedding.upsert({
            user_id: user_id,
            description_embedding: vector, 
            updated_at: Time.current
        }, unique_by: :user_id)
    end
end