#!/usr/bin/env bash

shopt -s expand_aliases

alias  kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
export KEYCLOAK_URL=http://192.168.1.5:8081     #/auth
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=Madrid


echo Login
kcadm config credentials --server $KEYCLOAK_URL  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"
kcadm get users    -r cpas
kcadm get clients  -r cpas
kcadm get roles    -r cpas
kcadm get groups   -r cpas

