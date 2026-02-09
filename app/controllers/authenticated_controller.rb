class AuthenticatedController < ApplicationController
    before_action :authenticate_user!

    private 

    def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last

        if (token == nil)
            return render json: {error: 'Missing Token'}, status: :unauthorized
        end

        begin 
            decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, {algorithm: "HS256"})
            payload = decoded_token.first 

            @current_user = User.find_by(id: payload['sub'])

            if (@current_user == nil)
                return render json: {error: "User not found"}, status: :unauthorized
            end
        rescue JWT::ExpiredSignature 
            render json: {error: "Token expired", code: "TOKEN_EXPIRED"}, status: :unauthorized
        rescue JWT::DecodeError
            render json: {error: "Invalid Token"}, status: :unauthorized
        end 
    end
end