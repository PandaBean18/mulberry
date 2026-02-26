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


# Values for test acc
ACCESS_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZjhjNmExNi03MzczLTRjYWItODRjZS1jMDRiNjNkN2E2YWIiLCJqdGkiOiJkODczMzhhZC0wM2NlLTQ3ZTctYWU4OS00MzFjYjcwNDA1MWIiLCJleHAiOjE3NzIxMDUxODgsImlhdCI6MTc3MjEwMzM4OH0.NVVwsLJIJUHZR96-QoMIAKTIWnj2tAzqXYDilhBZe0w
REFRESH_TOKEN=8c0aaf7d7359f59bd28042897b401ed62f6cdcb78ae4c9da108ba2ec7a9131c3
JTI=d87338ad-03ce-47e7-ae89-431cb704051b

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

if [ $1 = "refresh" ]; then
  refresh
elif [ $1 = "sign" ]; then 
  getSignature

elif [ $1 = "upload" ]; then
  upload $2 $3 $4 $5 $6 $7 $8
elif [ $1 = "confirm" ]; then 
  confirm $2 $3 $4 $5
fi