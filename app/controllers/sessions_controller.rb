class SessionsController < ApplicationController
  before_action :set_session, only: %i[ show update destroy ]
  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  # GET /sessions
  def index
    @sessions = Session.all

    render json: @sessions
  end

  # GET /sessions/1
  def show
    render json: @session
  end

  # POST /sessions
	def create
		@session = Session.new(session_params)

		if @session.save
			render json: @session, status: :created, location: @session
		else
			render json: @session.errors, status: :unprocessable_content
		end
	end

	def refresh
		refresh_token = params[:refresh_token]
		session = Session.active.find_by(access_token_identifier: params[:access_token_identifier])

		if session && BCrypt::Password.new(session.refresh_token_digest) == refresh_token
			user = session.identity.user 
			jti = SecureRandom.uuid
			payload = {
				sub: user.id,
				jti: jti,
				exp: 30.minutes.from_now.to_i 
				iat: Time.current.to_i
			}

			new_access_token = JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
			new_refresh_token = SecureRandom.hex(32)

			session.update!(refresh_token_digest: BCrypt::Password.create(new_refresh_token), access_token_identifier: jti)

			render json: {access_token: new_access_token, refresh_token: new_refresh_token}
		else 
			render json: {error: "Invalid refresh token"}, status: :unauthorized
		end
	end

  # PATCH/PUT /sessions/1
	def update
		if @session.update(session_params)
			render json: @session
		else
			render json: @session.errors, status: :unprocessable_content
		end
	end

  # DELETE /sessions/1
  	def destroy
    	@session.destroy!
  	end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def session_params
      	params.expect(session: [ :identity_id, :refresh_token_digest, :access_token_identifier, :revoked_at, :expires_at ])
    end
end
