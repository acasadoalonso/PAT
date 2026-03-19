#!/bin/bash
#
# This script setup the Keyclok realm for the CPAS
#
KCversion='25.0.2'

shopt -s expand_aliases
if [[ $1 != 'bash' ]] 
then						# docker version
   alias  kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
   export kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
   alias
else						# bash version
   cd ~/src/keycloak-$KCversion/
   pwd
   export PATH=$PATH:$(pwd)/bin
   alias  kcadm='kcadm.sh '
   export kcadm='kcadm.sh '
   cd -
fi
echo "KCADM: "$kcadm
#exit
export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KEYCLOAK_URL=http://$CONTAINERIP:8081    # URL to call Keycloak
export KEYCLOAK_ADMIN=admin			# default admin user
export KEYCLOAK_ADMIN_PASSWORD=Madrid		# default password
echo "Container IP:  "$CONTAINERIP

echo "=============="
echo "Login into keycloak using the CLI interface ..."
$kcadm config credentials --server $KEYCLOAK_URL  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"
$kcadm update realms/master -s sslRequired=NONE
docker cp ./jsonfiles/realm-cpas.json keycloak:/root	# copy the realm file into the docker container
if [[ $1 != 'bash' ]] 
then						# docker version
   $kcadm create realms -f /root/realm-cpas.json # create the basis realm cpas
else
   $kcadm create realms -f ./jsonfiles/realm-cpas.json 	# create the basis realm cpas
fi
echo
echo Realms
echo "=============="
$kcadm get realms   -F id,realm,enabled,displayName,displayNameHtmla --format CSV --noquotes
echo
echo Users
echo "=============="
$kcadm get users    -r cpas -F username,firstName,lastName           --format CSV --noquotes
echo
echo Clients
echo "=============="
$kcadm get clients  -r cpas -F clientId,name                         --format CSV --noquotes
echo
echo Roles
echo "=============="
$kcadm get roles    -r cpas -F name,description                      --format CSV --noquotes
echo
echo Groups
echo "=============="
$kcadm get groups   -r cpas -F name,path                             --format CSV --noquotes
echo
PATgroupid=$($kcadm get groups -r cpas -F id --noquotes --format CSV)
echo
echo "GroupID /PAT users:   "$PATgroupid
echo "=============="
echo
echo "Create now the continent subgroups"
echo "=============="
$kcadm create groups/$PATgroupid/children   -r cpas -s name=Europe
$kcadm create groups/$PATgroupid/children   -r cpas -s name=Australia
$kcadm create groups/$PATgroupid/children   -r cpas -s name=USA
$kcadm create groups/$PATgroupid/children   -r cpas -s name=SouthAmerica
$kcadm create groups/$PATgroupid/children   -r cpas -s name=Africa
$kcadm get    groups/$PATgroupid/children   -r cpas -F name,path      --format CSV --noquotes
echo
echo "Create now the country subgroups"
echo "=============="
EuropeID=$($kcadm get groups -r cpas   -q search=Europe -F 'subGroups(id)' --noquotes --format CSV)
echo
echo "GroupID Europe:   "$EuropeID
echo "=============="
$kcadm create groups/$EuropeID/children  -r cpas -s name=Spain
$kcadm create groups/$EuropeID/children  -r cpas -s name=France
$kcadm create groups/$EuropeID/children  -r cpas -s name=Germany
$kcadm create groups/$EuropeID/children  -r cpas -s name=Italy
$kcadm create groups/$EuropeID/children  -r cpas -s name=UK
$kcadm create groups/$EuropeID/children  -r cpas -s name=Poland
$kcadm create groups/$EuropeID/children  -r cpas -s name=Sweeden
$kcadm create groups/$EuropeID/children  -r cpas -s name=Belgium
$kcadm create groups/$EuropeID/children  -r cpas -s name=Hungary
$kcadm create groups/$EuropeID/children  -r cpas -s name=Slovenia
$kcadm create groups/$EuropeID/children  -r cpas -s name=Slovakia
$kcadm get    groups/$EuropeID/children  -r cpas -F name,path           --format CSV --noquotes
echo
echo "Create roles ..."
echo "=============="
$kcadm create roles    -r cpas -s name=user_Spain     -s 'description=The Spaniars'
$kcadm create roles    -r cpas -s name=user_France    -s 'description=The Frenchies'
$kcadm create roles    -r cpas -s name=user_USA       -s 'description=The Americans'
$kcadm create roles    -r cpas -s name=user_Australia -s 'description=The down under folks'
$kcadm create roles    -r cpas -s name=user_UK        -s 'description=The Brits'
$kcadm create roles    -r cpas -s name=user_Germany   -s 'description=The Germans'
$kcadm create roles    -r cpas -s name=user_Italy     -s 'description=The Italians'
$kcadm create roles    -r cpas -s name=user_Slovenia  -s 'description=The Slovenians'
$kcadm get-roles       -r cpas -F name,description			--format CSV --noquotes

echo
echo "Create now the users"
echo "=============="
docker cp ./jsonfiles/user1.json keycloak:/root
docker cp ./jsonfiles/user2.json keycloak:/root
docker cp ./jsonfiles/user3.json keycloak:/root
if [[ $1 != 'bash' ]] 
then						# docker version
   $kcadm create users    -r cpas -f /root/user1.json
   $kcadm create users    -r cpas -f /root/user2.json
   $kcadm create users    -r cpas -f /root/user3.json
else
   $kcadm create users    -r cpas -f ./jsonfiles/user1.json
   $kcadm create users    -r cpas -f ./jsonfiles/user2.json
   $kcadm create users    -r cpas -f ./jsonfiles/user3.json
fi
echo
echo Users
echo "=============="
$kcadm get    users    -r cpas -F username,firstName,lastName           --format CSV --noquotes
echo "=============="
echo
echo "Update roles of users."
echo "=============="
$kcadm get-roles -r cpas --uusername admin -F name,description		--format CSV --noquotes
$kcadm get-roles -r cpas --uusername angel -F name,description		--format CSV --noquotes
$kcadm get-roles -r cpas --uusername john  -F name,description		--format CSV --noquotes
echo
echo "Update new roles of users."
echo "=============="
$kcadm add-roles --uusername angel --rolename user           -r cpas
$kcadm add-roles --uusername angel --rolename user_Spain     -r cpas
$kcadm add-roles --uusername angel --rolename user_France    -r cpas
$kcadm add-roles --uusername john  --rolename user           -r cpas
$kcadm add-roles --uusername john  --rolename user_Australia -r cpas
$kcadm get-roles -r cpas -F name,description				--format CSV --noquotes
echo "=============="
echo
echo "Users roles ..."
echo "=============="
echo
echo Angel
$kcadm get-roles -r cpas --uusername angel -F name,description		--format CSV --noquotes
echo
echo JohnW
$kcadm get-roles -r cpas --uusername john  -F name,description		--format CSV --noquotes
echo "=============="

echo
###########################################################################################################
echo

