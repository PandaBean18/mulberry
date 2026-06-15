require "timeout"
class MediaController < AuthenticatedController 
	def signature
		timestamp = Time.now.to_i
		folder = "portfolio/#{@current_user.id}"
		
		params_to_sign = { 
			folder: folder,
			source: "uw",
			tags: "user_id_#{@current_user.id},portfolio",
			timestamp: timestamp, 
		}
		
		signature = Cloudinary::Utils.api_sign_request(
			params_to_sign, 
			Rails.application.credentials.dig(:cloudinary, :api_secret)
		)

		render json: {
			signature: signature,
			timestamp: timestamp,
			api_key: Rails.application.credentials.dig(:cloudinary, :api_key),
			cloud_name: Rails.application.credentials.dig(:cloudinary, :cloud_name),
			folder: folder,
			tags: params_to_sign[:tags]
		}
	end

	def confirm_upload
		media_item = @current_user.media_items.create!(
			cloudinary_public_id: params[:public_id],
			media_type: params[:resource_type] == "video" ? :video : :image,
			metadata: params[:metadata],
			label: params[:label]
		)

		render json: {
			message: "Media saved to profile",
			item: media_item.as_json(methods: [:thumbnail_url, :url])
		}, status: :created
	end

	def parse_link
		url = params[:url]
		return render json: { error: "URL is required" }, status: :bad_request if url.blank?

		begin
			parsed_link = Timeout.timeout(15.0) do
        		MediaParserService.call(url)
      		end

			if parsed_link
				render json: parsed_link, status: :ok	
			else
				render json: { error: "Could not extract metadata from this link." }, status: :unprocessable_entity
			end
			
		rescue Timeout::Error 
			render json: { 
				error: "The link took too long to process. You can still add it manually." 
			}, status: :gateway_timeout
		rescue StandardError => e
			Rails.logger.error("[MediaController#parse_link] Error: #{e.message}")
      		render json: { error: "Failed to parse link." }, status: :internal_server_error
		end
	end
end