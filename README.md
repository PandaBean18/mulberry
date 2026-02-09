# Database Structure

Users table:
id -> uuid
email -> string 
role -> string -> must be one of {"sponsor", "creator"}
username -> string
timezone -> string 
created_at -> datetime
updated_at -> datetime 

Identities table:
id -> uuid
user_id -> user.id -> uuid 
provider -> string -> must be one of {"password", "google"}
uid -> string -> uid provided by google, must be non null if provider is google
password_digest -> string -> must be not null if provider is password
created_at && updated_at -> datetime 

Sessions table:
id -> uuid
identity_id -> identity.id -> uuid
access_token_identifier -> the id of JWT corressponding to this session (JTI)
refresh_token_digest -> hash of refresh token
expires_at -> datetime 


A user has one to many relation with the identities table, the identities table has one to many relation with sessions table
