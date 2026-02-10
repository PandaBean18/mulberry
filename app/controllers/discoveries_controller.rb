class DiscoveriesController < ApplicationController
    def search_creators
        query_text = params[:description]

        if query_text.blank?
            return render json: { error: "Description is required" }, status: :bad_request
        end

        query_vector = EmbeddingService.generate(query_text)
        nearest_embeddings = Embedding.nearest_neighbors(:description_embedding, query_vector, distance: "cosine").limit(10)
        creators = User.where(id: nearest_embeddings.map(&:user_id)).select(:id, :username, :email, :description)
        render json: {
            query: query_text,
            matches: creators
        }
    rescue StandardError => e
        render json: { error: "Search failed: #{e.message}" }, status: :internal_server_error
    end
end