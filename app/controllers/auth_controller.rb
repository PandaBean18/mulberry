class AuthController < ApplicationController
    before_action :authenticate_user!, only:  [:logout]

    def signup
        @user = User.create!(user_params)

        hashed_password = BCrypt::Password.create(params[:password])

        @identity = @user.identities.create!(
            provider: 'password',
            uid: user_params[:email],
            password_digest: hashed_password
        )

        render_session_tokens(@identity, status: :created)
    rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    def login
        identity = Identity.find_by(provider: 'password', uid: user_params[:email])

        if BCrypt::Password.new(identity&.password_digest) == params[:password]
            render_session_tokens(identity)
        else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
    end

    def logout
        jti = @auth_payload[:jti]
        session = @current_user.sessions.find_by(access_token_identifier: jti)

        if session&.update(revoked_at: Time.current)
            render json: { message: 'Logged out' }
        else
            render json: { error: 'Session not found' }, status: :not_found
        end
    end

    private

    def user_params
        params.require(:user).permit(:username, :email, :role, :timezone, :description)
    end

    def render_session_tokens(identity, status: :ok)
        raw_refresh = SecureRandom.hex(32)
        jti = SecureRandom.uuid 

        identity.sessions.create!(
            access_token_identifier: jti, 
            refresh_token_digest: BCrypt::Password.create(raw_refresh),
            expires_at: 2.weeks.from_now
        )

        payload = {
            sub: @user.id,
            jti: jti,
            exp: 30.minutes.from_now.to_i,
            iat: Time.current.to_i
        }

        access_token = JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')

        render json: {
            access_token: access_token,
            refresh_token: raw_refresh,
            user: identity.user.as_json(only: [:id, :username, :role])
        }, status: status
    end

    def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last

        if (token == nil)
            return render json: {error: 'Missing Token'}, status: :unauthorized
        end

        begin 
            decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, {algorithm: "HS256"})
            @auth_payload = decoded_token.first 

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