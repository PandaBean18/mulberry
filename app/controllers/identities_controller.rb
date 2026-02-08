class IdentitiesController < ApplicationController
  before_action :set_identity, only: %i[ show update destroy ]

  # GET /identities
  def index
    @identities = Identity.all

    render json: @identities
  end

  # GET /identities/1
  def show
    render json: @identity
  end

  # POST /identities
  def create
    @identity = Identity.new(identity_params)

    if @identity.save
      render json: @identity, status: :created, location: @identity
    else
      render json: @identity.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /identities/1
  def update
    if @identity.update(identity_params)
      render json: @identity
    else
      render json: @identity.errors, status: :unprocessable_content
    end
  end

  # DELETE /identities/1
  def destroy
    @identity.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_identity
      @identity = Identity.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def identity_params
      params.expect(identity: [ :user_id, :provider, :uid, :password_digest ])
    end
end
