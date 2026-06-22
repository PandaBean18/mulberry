# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_15_115143) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "vector"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "calendar_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "brief"
    t.datetime "created_at", null: false
    t.datetime "date", null: false
    t.uuid "deliverable_id"
    t.string "entry_type", null: false
    t.boolean "is_completed", default: false, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["date"], name: "index_calendar_entries_on_date"
    t.index ["deliverable_id"], name: "index_calendar_entries_on_deliverable_id"
    t.index ["is_completed"], name: "index_calendar_entries_on_is_completed"
    t.index ["user_id"], name: "index_calendar_entries_on_user_id"
  end

  create_table "campaign_participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.uuid "conversation_id", null: false
    t.datetime "created_at", null: false
    t.uuid "creator_id", null: false
    t.decimal "offered_rate", precision: 10, scale: 2
    t.string "status", default: "invited", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "creator_id"], name: "index_campaign_participants_on_campaign_id_and_creator_id", unique: true
    t.index ["campaign_id"], name: "index_campaign_participants_on_campaign_id"
    t.index ["conversation_id"], name: "index_campaign_participants_on_conversation_id"
    t.index ["creator_id"], name: "index_campaign_participants_on_creator_id"
    t.index ["status"], name: "index_campaign_participants_on_status"
  end

  create_table "campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "brief", null: false
    t.decimal "budget_total", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.uuid "sponsor_id", null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["sponsor_id"], name: "index_campaigns_on_sponsor_id"
    t.index ["status"], name: "index_campaigns_on_status"
  end

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id"
    t.datetime "created_at", null: false
    t.uuid "creator_id", null: false
    t.uuid "sponsor_id", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_conversations_on_campaign_id"
    t.index ["creator_id", "sponsor_id"], name: "index_conversations_on_creator_id_and_sponsor_id", unique: true
    t.index ["creator_id"], name: "index_conversations_on_creator_id"
    t.index ["sponsor_id"], name: "index_conversations_on_sponsor_id"
  end

  create_table "deliverables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "brief"
    t.uuid "campaign_participant_id", null: false
    t.datetime "created_at", null: false
    t.string "deliverable_type", null: false
    t.datetime "due_date", null: false
    t.string "feedback"
    t.string "status", default: "pending", null: false
    t.uuid "submission_proof_id"
    t.datetime "updated_at", null: false
    t.index ["campaign_participant_id"], name: "index_deliverables_on_campaign_participant_id"
    t.index ["due_date"], name: "index_deliverables_on_due_date"
    t.index ["submission_proof_id"], name: "index_deliverables_on_submission_proof_id"
  end

  create_table "embeddings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.vector "description_embedding", limit: 384
    t.uuid "owner_id", null: false
    t.string "owner_type", default: "User", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_embeddings_on_owner_type_and_owner_id", unique: true
  end

  create_table "ideas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "description", default: {}, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_ideas_on_user_id"
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest"
    t.string "provider", null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "inspos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_thumbnail_url"
    t.string "external_url"
    t.uuid "idea_id", null: false
    t.string "source_type", default: "direct_upload", null: false
    t.integer "status", default: 0, null: false
    t.jsonb "temporary_assets", default: {}, null: false
    t.uuid "thumbnail_item_id"
    t.datetime "updated_at", null: false
    t.index ["idea_id"], name: "index_inspos_on_idea_id"
    t.index ["thumbnail_item_id"], name: "index_inspos_on_thumbnail_item_id"
  end

  create_table "media_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cloudinary_public_id", null: false
    t.datetime "created_at", null: false
    t.string "label", default: "portfolio", null: false
    t.integer "media_type", default: 0
    t.jsonb "metadata", default: {}
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["cloudinary_public_id"], name: "index_media_items_on_cloudinary_public_id", unique: true
    t.index ["label"], name: "index_media_items_on_label"
    t.index ["user_id"], name: "index_media_items_on_user_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body", null: false
    t.uuid "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.uuid "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "portfolio_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "external_embed_url"
    t.string "external_thumbnail_url"
    t.string "external_url"
    t.boolean "is_collaborative", default: false, null: false
    t.uuid "media_item_id"
    t.jsonb "metrics", default: {}, null: false
    t.string "source_type", default: "direct_upload"
    t.integer "status", default: 0, null: false
    t.jsonb "temporary_assets", default: {}, null: false
    t.uuid "thumbnail_item_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["media_item_id"], name: "index_portfolio_items_on_media_item_id", unique: true
    t.index ["metrics"], name: "index_portfolio_items_on_metrics", using: :gin
    t.index ["status"], name: "index_portfolio_items_on_status"
    t.index ["thumbnail_item_id"], name: "index_portfolio_items_on_thumbnail_item_id"
    t.index ["user_id"], name: "index_portfolio_items_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_token_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.uuid "identity_id", null: false
    t.string "refresh_token_digest", null: false
    t.datetime "revoked_at"
    t.datetime "updated_at", null: false
    t.index ["access_token_identifier"], name: "index_sessions_on_access_token_identifier", unique: true
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
    t.index ["refresh_token_digest"], name: "index_sessions_on_refresh_token_digest", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "role"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "calendar_entries", "deliverables"
  add_foreign_key "calendar_entries", "users"
  add_foreign_key "campaign_participants", "campaigns"
  add_foreign_key "campaign_participants", "conversations"
  add_foreign_key "campaign_participants", "users", column: "creator_id"
  add_foreign_key "campaigns", "users", column: "sponsor_id"
  add_foreign_key "conversations", "campaigns"
  add_foreign_key "conversations", "users", column: "creator_id"
  add_foreign_key "conversations", "users", column: "sponsor_id"
  add_foreign_key "deliverables", "campaign_participants"
  add_foreign_key "deliverables", "media_items", column: "submission_proof_id"
  add_foreign_key "ideas", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "inspos", "ideas"
  add_foreign_key "inspos", "media_items", column: "thumbnail_item_id"
  add_foreign_key "media_items", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "portfolio_items", "media_items"
  add_foreign_key "portfolio_items", "media_items", column: "thumbnail_item_id"
  add_foreign_key "portfolio_items", "users"
  add_foreign_key "sessions", "identities"
end
