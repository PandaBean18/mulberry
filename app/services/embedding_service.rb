class EmbeddingService
    MODEL_NAME = "Xenova/all-MiniLM-L6-v2"

    def self.generate(text)
        @model ||= Informers.pipeline("feature-extraction", MODEL_NAME)

        result = @model.call(text)
        result[0]
    end
end