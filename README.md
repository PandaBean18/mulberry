# Database Structure

Users table:<br>
id -> uuid<br>
email -> string<br>
role -> string -> must be one of {"sponsor", "creator"}<br>
username -> string<br>
timezone -> string<br>
created_at -> datetime<br>
updated_at -> datetime<br>
<hr>

Identities table:<br>
id -> uuid<br>
user_id -> user.id -> uuid<br>
provider -> string -> must be one of {"password", "google"}<br>
uid -> string -> uid provided by google, must be non null if provider is google<br>
password_digest -> string -> must be not null if provider is password<br>
created_at && updated_at -> datetime<br>
<hr>

Sessions table:<br>
id -> uuid<br>
identity_id -> identity.id -> uuid<br>
access_token_identifier -> the id of JWT corressponding to this session (JTI)<br>
refresh_token_digest -> hash of refresh token<br>
expires_at -> datetime<br>


A user has one to many relation with the identities table, the identities table has one to many relation with sessions table
