# Source - https://stackoverflow.com/a/74116758

# Posted by hc_dev, modified by community. See post 'Timeline' for change history

# Retrieved 2026-03-20, License - CC BY-SA 4.0



# define the variables: url, credentials to access REST API, and the realm to export
KEYCLOAK_URL="https://localhost:8081"
KEYCLOAK_REALM="master"
KEYCLOAK_USER="admin"
KEYCLOAK_SECRET="Madrid"
REALM_NAME="myRealm"

# obtain the access token
ACCESS_TOKEN=$(curl -X POST "${KEYCLOAK_URL}/auth/realms/${KEYCLOAK_REALM}/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${KEYCLOAK_USER}" \
  -d "password=${KEYCLOAK_SECRET}" \
  -d "grant_type=password" \
  -d 'client_id=admin-cli' \
  | jq -r '.access_token')
echo $ACCESS_TOKEN
# export the realm as JSON
curl -X GET "${KEYCLOAK_URL}/auth/admin/realms/${REALM_NAME}"
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  > keycloak_${REALM_NAME}_realm.json

# export the users
curl -X GET "${KEYCLOAK_URL}/auth/admin/realms/${REALM_NAME}/users" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  > keycloak_${REALM_NAME}_users.json

# export the roles
curl -X GET "${KEYCLOAK_URL}/auth/admin/realms/${REALM_NAME}/roles" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  > keycloak_${REALM_NAME}_roles.json

# integrate all 3 using jq's slurp
jq -s '.[0] + {users:.[1], roles:.[2]}' \
  keycloak_${REALM_NAME}_realm.json \ 
  keycloak_${REALM_NAME}_users.json \
  keycloak_${REALM_NAME}_roles.json \
  > keycloak_${REALM_NAME}_realm-incl-users-roles.json

