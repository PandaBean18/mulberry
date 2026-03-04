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
			metadata: params[:metadata], # dimensions, format, etc.
			label: params[:label]
		)

		render json: {
			message: "Media saved to profile",
			item: media_item.as_json(methods: [:thumbnail_url, :url])
		}, status: :created
	end
end