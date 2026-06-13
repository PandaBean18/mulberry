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

			if token.blank?
				reject_unauthorized_connection
			end

			begin
				decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, {algorithm: "HS256"})
				payload = decoded_token.first 

				current_user = User.find_by(id: payload['sub'])

				if (current_user == nil)
					reject_unauthorized_connection
				end
			rescue JWT::ExpiredSignature 
				reject_unauthorized_connection
			rescue JWT::DecodeError
				reject_unauthorized_connection
			end 

			return current_user
		end
  end
end
