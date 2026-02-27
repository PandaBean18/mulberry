# Set your variables
SPONSOR_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMGY4YWIzYi02ZDkyLTQ1NjgtYTc5MC00MjdmZGQxNzEyMzUiLCJqdGkiOiIyOWQzZDRhNy0zMzE3LTQxMGItYTA1OC0wZTczMDY1YjZlMzUiLCJleHAiOjE3NzIxMjg4NjEsImlhdCI6MTc3MjEyNzA2MX0.OAW1RJJ9xaUwLWOLk7ByNegG74VP-LGLbydFpre2Zrc
CREATOR_UUID=ef8c6a16-7373-4cab-84ce-c04b63d7a6ab

curl -X POST http://127.0.0.1:3000/conversations \
     -H "Authorization: Bearer $SPONSOR_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{
           \"other_user_id\": \"$CREATOR_UUID\"
         }"