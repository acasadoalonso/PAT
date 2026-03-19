#!/bin/bash
KCversion='25.0.2'

shopt -s expand_aliases
if [[ $1 == 'Docker' ]] 
then
   alias  kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"a
else
   cd ~/src/keycloak-$KCversion/
   pwd
   export PATH=$PATH:$(pwd)/bin
   alias  kcadm = 'kcadm.sh 'a
   cd -
fi
kcadm --help
alias
exit
export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KEYCLOAK_URL=http://$CONTAINERIP:8081    # URL to call Keycloak
export KEYCLOAK_ADMIN=admin			# default admin user
export KEYCLOAK_ADMIN_PASSWORD=Madrid		# default password
echo "Container IP:  "$CONTAINERIP

echo "=============="
echo "Login into keycloak using the CLI interface ..."
kcadm config credentials --server $KEYCLOAK_URL  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"
kcadm update realms/master -s sslRequired=NONE
docker cp realm-cpas.json keycloak:/root	# copy the realm file into the docker container
kcadm create realms -f /root/realm-cpas.json 	# create the basis realm cpas
echo Realms
echo "=============="
kcadm get realms   -F id,realm,enabled,displayName,displayNameHtmla --format CSV --noquotes
echo Users
echo "=============="
kcadm get users    -r cpas -F username,firstName,lastName           --format CSV --noquotes
echo Clients
echo "=============="
kcadm get clients  -r cpas -F clientId,name                         --format CSV --noquotes
echo Roles
echo "=============="
kcadm get roles    -r cpas -F name,description                      --format CSV --noquotes
echo Groups
echo "=============="
kcadm get groups   -r cpas -F name,path                             --format CSV --noquotes
echo
PATgroupid=$(kcadm get groups -r cpas -F id --noquotes --format CSV)
echo "GroupID /PAT users:   "$PATgroupid
echo "=============="
echo
echo "Create now the continent subgroups"
echo "=============="
kcadm create groups/$PATgroupid/children   -r cpas -s name=Europe
kcadm create groups/$PATgroupid/children   -r cpas -s name=Australia
kcadm create groups/$PATgroupid/children   -r cpas -s name=USA
kcadm create groups/$PATgroupid/children   -r cpas -s name=SouthAmerica
kcadm create groups/$PATgroupid/children   -r cpas -s name=Africa
kcadm get    groups/$PATgroupid/children   -r cpas -F name,path      --format CSV --noquotes
echo "Create now the country subgroups"
echo "=============="
EuropeID=$(kcadm get groups -r cpas   -q search=Europe -F 'subGroups(id)' --noquotes --format CSV)
echo "GroupID Europe:   "$EuropeID
echo "=============="
kcadm create groups/$EuropeID/children  -r cpas -s name=Spain
kcadm create groups/$EuropeID/children  -r cpas -s name=France
kcadm create groups/$EuropeID/children  -r cpas -s name=Germany
kcadm create groups/$EuropeID/children  -r cpas -s name=Italy
kcadm get    groups/$EuropeID/children  -r cpas -F name,path           --format CSV --noquotes
echo "Create now the users"
echo "=============="
docker cp user1.json keycloak:/root
docker cp user2.json keycloak:/root
docker cp user3.json keycloak:/root
kcadm create users    -r cpas -f /root/user1.json
kcadm create users    -r cpas -f /root/user2.json
kcadm create users    -r cpas -f /root/user3.json
echo
echo Users
echo "=============="
kcadm get    users    -r cpas -F username,firstName,lastName           --format CSV --noquotes
echo "=============="

echo
###########################################################################################################
echo

