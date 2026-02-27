module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

		def connect
			self.current_user = find_verified_user
		end

		private 

		def find_verified_user
			token = request.params[:token]
			current_user = nil

			if (token == nil)
				return render json: {error: 'Missing Token'}, status: :unauthorized
			end

			begin
				decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, {algorithm: "HS256"})
				payload = decoded_token.first 

				current_user = User.find_by(id: payload['sub'])

				if (current_user == nil)
					puts 1
					reject_unauthorized_connection
				end
			rescue JWT::ExpiredSignature 
				puts 2
				reject_unauthorized_connection
			rescue JWT::DecodeError
				puts 3
				reject_unauthorized_connection
			end 

			return current_user
		end
  end
end
