
export access_token=$(\
curl -X POST http://127.0.0.1:8081/realms/cpas/protocol/openid-connect/token \
-H 'content-type: application/x-www-form-urlencoded' \
-d 'client_id=patClient' \
-d 'username=admin&password=admin&grant_type=password' | jq --raw-output '.access_token')

curl http://127.0.0.1:8081/api/getComp/043c8329-42ea-42c8-b1a8-df5dcff12acc -H "Authorization: Bearer "$access_token

