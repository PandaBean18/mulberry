require "test_helper"

class IdentitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:one)
  end

  test "should get index" do
    get identities_url, as: :json
    assert_response :success
  end

  test "should create identity" do
    assert_difference("Identity.count") do
      post identities_url, params: { identity: { password_digest: @identity.password_digest, provider: @identity.provider, uid: @identity.uid, user_id: @identity.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show identity" do
    get identity_url(@identity), as: :json
    assert_response :success
  end

  test "should update identity" do
    patch identity_url(@identity), params: { identity: { password_digest: @identity.password_digest, provider: @identity.provider, uid: @identity.uid, user_id: @identity.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy identity" do
    assert_difference("Identity.count", -1) do
      delete identity_url(@identity), as: :json
    end

    assert_response :no_content
  end
end
