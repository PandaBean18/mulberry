curl -X POST http://127.0.0.1:3000/auth/signup \
     -H "Content-Type: application/json" \
     -d '{
           "user": {
             "username": "sponsor_bean",
             "email": "sponsor@business.com",
             "role": "sponsor",
             "timezone": "Asia/Kolkata"
           },
           "password": "business_password_123"
         }'