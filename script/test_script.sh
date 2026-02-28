# curl -X POST http://127.0.0.1:3000/auth/signup \
#      -H "Content-Type: application/json" \
#      -d '{
#            "user": {
#              "username": "rndBean",
#              "email": "rndbean@example.com",
#              "role": "creator",
#              "description": "I build custom ESP32 music players and focus on low-level Ruby systems. lmao",
#              "timezone": "Asia/Kolkata"
#            },
#            "password": "securepassword123"
#          }'


# Values for test user acc
# ACCESS_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZjhjNmExNi03MzczLTRjYWItODRjZS1jMDRiNjNkN2E2YWIiLCJqdGkiOiI2NTgwZWI1OC1lMDFkLTQzMDAtYWQxYS03MGJiNTY1ZWU1MDUiLCJleHAiOjE3NzIxNzQxMTYsImlhdCI6MTc3MjE3MjMxNn0.wFEreYy2gvmwd-XZvQQbigDdKC5vqH7z8VXItnt5CjU
# REFRESH_TOKEN=b61386a4ebd50f960488fa4ee377d3d744bcc0a98cc4ad34aadc5ab2134f4f76
# JTI=6580eb58-e01d-4300-ad1a-70bb565ee505


#test sponsor acc
ACCESS_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMGY4YWIzYi02ZDkyLTQ1NjgtYTc5MC00MjdmZGQxNzEyMzUiLCJqdGkiOiJmZmQzM2RlMS1iYmYwLTQyMTAtYTcyMy05ZDMxZDZhMDliM2YiLCJleHAiOjE3NzIyODU4MzMsImlhdCI6MTc3MjI4NDAzM30.viToyqIDfzXiwqYlsPQ8arjU0IZjNG4z5Gw_xSBqrqQ
REFRESH_TOKEN=d38b426122f2bf2459f2384a0ec99b929493c01eda39b428576e0842ce2f4872
JTI=ffd33de1-bbf0-4210-a723-9d31d6a09b3f

# test campaign 
CAMPAIGN_ID=ad863bb9-790b-49ca-964d-7b50ca75dd16

function logout() {
    curl -X DELETE http://127.0.0.1:3000/auth/logout \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json"
}

function refresh() {
    curl -X POST http://127.0.0.1:3000/auth/refresh \
     -H "Content-Type: application/json" \
     -d "{
           \"refresh_token\": \"$REFRESH_TOKEN\",
           \"access_token_identifier\": \"$JTI\"
         }"
}

function getSignature() {
  curl -X GET http://127.0.0.1:3000/media/signature \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json"
}

function upload() {
  local SIGNATURE=$1
  local TIMESTAMP=$2
  local API_KEY=$3
  local CLOUDINARY_NAME=$4
  local FOLDER=$5
  local TAGS=$6
  local MEDIA_PATH=$7
  echo $TAGS
  curl -X POST "https://api.cloudinary.com/v1_1/$CLOUDINARY_NAME/image/upload" \
     -F "file=@$MEDIA_PATH" \
     -F "api_key=$API_KEY" \
     -F "timestamp=$TIMESTAMP" \
     -F "signature=$SIGNATURE" \
     -F "folder=$FOLDER" \
     -F "tags=$TAGS" \
     -F "source=uw"
}

function confirm() {
  curl -X POST http://127.0.0.1:3000/media/confirm_upload \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{
           \"public_id\": \"$1\",
           \"resource_type\": \"image\",
           \"metadata\": { 
             \"width\": $2, 
             \"height\": $3, 
             \"format\": \"$4\" 
           }
         }"
}

function createCampaign() {
  curl -X POST http://localhost:3000/campaigns \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -d '{
       "campaign": {
         "title": "Gaming Headphone review",
         "brief": "Looking for high energy creators to review our new gaming headphones with amazing sound quality",
         "budget_total": 25000.00,
         "status": "draft"
       }
     }'
}

function showCampaign() {
  curl -X GET http://localhost:3000/campaigns/$1 \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json"
}

function campaignMatches() {
  curl -X GET http://localhost:3000/campaigns/$1/matches \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json"
}

function inviteCreators() {
  curl -X POST http://localhost:3000/campaigns/$1/invite \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "creator_ids": [
         "2d611ed4-a0b2-4417-890e-2f9ea2c9b1b3",
         "e8552373-34a2-40b1-950a-dcfbae8f7a0c",
         "ce593558-b390-48ab-96b3-87f83e865194",
         "a523a48d-203b-40d2-9e12-0c15e88073a0"
       ]
     }'
}

if [ $1 = "refresh" ]; then
  refresh
elif [ $1 = "sign" ]; then 
  getSignature
elif [ $1 = "upload" ]; then
  upload $2 $3 $4 $5 $6 $7 $8
elif [ $1 = "confirm" ]; then 
  confirm $2 $3 $4 $5
elif [ $1 = "createCampaign" ]; then
  createCampaign
elif [ $1 = "showCampaign" ]; then 
  showCampaign $2
elif [ $1 = "campaignMatches" ]; then 
  campaignMatches $2
elif [ $1 = "inviteCreators" ]; then 
  inviteCreators $2
fi