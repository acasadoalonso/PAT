#!/bin/bash
#
# This scrept take the json files exported from on keycloak system and import it on the current kc --- it is used to sync both systems
#

shopt -s expand_aliases
alias  kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
export kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
$kcadm config credentials --server $KEYCLOAK_URL  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"
cd jsonfiles
for f in $(sudo ls  cpas*.json); do
        rm -f tmpuser.json
        echo "Processing file:" $f
	echo '{' >cbo && tail -n +4 $f | head -n-2  > tmp.json && echo '}' >cbc && cat cbo tmp.json cbc >tmpuser.json
	docker cp ./tmpuser.json keycloak:/root
	rm tmpuser.json cbo tmp.json cbc
	$kcadm create users    -r cpas -f /root/tmpuser.json
	echo "User: "$(jq -r '.users[0].username' $f) --rolename user               -r cpas
	$kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename user               -r cpas
	$kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename default-roles-cpas -r cpas
        role1=$(jq -r '.users[0].realmRoles[0]' $f) 
	role2=$(jq -r '.users[0].realmRoles[1]' $f)  
	role3=$(jq -r '.users[0].realmRoles[2]' $f)  
        if [[ $(jq -r '.users[0].realmRoles[0]' $f) == 'user' ]]
        then
          if [[ $role1 == 'default-roles-cpas' ||  $role2  == 'default-roles-cpas' ]]
          then
            echo "Added role3 "$role3
	    $kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename "$role3" -r cpas
          else
            echo "Added role2 "$role2
	    $kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename "$role2" -r cpas
          fi
        else
          echo "Added role1 "$role1
	  $kcadm add-roles --uusername $(jq -r '.users[0].username' $f)   --rolename "$role1" -r cpas
        fi
done
cd -
