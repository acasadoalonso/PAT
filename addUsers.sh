#!/bin/bash
#
# This scrept take the json files exported from on keycloak system and import it on the current kc --- it is used to sync both systems
#
echo
echo "Current setup environment"
echo
echo "Ckeycloak URL: "$KEYCLOAK_URL
echo "Ckeycloak ADMIN: "$KEYCLOAK_ADMIN
echo "Ckeycloak ADMIN_PASSWORD: "$KEYCLOAK_ADMIN_PASSWORD
shopt -s expand_aliases
alias  kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
export kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
$kcadm config credentials --server $KEYCLOAK_URL  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"
cd jsonfiles
for f in $(sudo ls  cpas*.json); do
        rm -f tmpuser.json
        echo "Processing file:" $f
	echo '{' >cbo && tail -n +4 $f | head -n-2  > tmp.json && echo '}' >cbc && cat cbo tmp.json cbc >tmpuser.json
        #cat tmpuser.json
	docker cp ./tmpuser.json keycloak:/var/tmpuser.json
	$kcadm create users    -r cpas -f /var/tmpuser.json
	rm tmpuser.json cbo tmp.json cbc
	echo "User: "$(jq -r '.users[0].username' $f) --rolename user               -r cpas
	$kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename user               -r cpas
	$kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename default-roles-cpas -r cpas
        role1=$(jq -r '.users[0].realmRoles[0]' $f) 
	role2=$(jq -r '.users[0].realmRoles[1]' $f)  
	role3=$(jq -r '.users[0].realmRoles[2]' $f)  
        role=$(jq -r '.users[0].realmRoles[0]' $f)
        x=1 
        while [[ $role != 'null' ]] ; 
        do
          if [[ $role == 'default-roles-cpas' ||  $role  == 'user' ]]
          then
            echo 'std roles ...: '$role
          else
            echo "Added role "$role
	    $kcadm add-roles --uusername $(jq -r '.users[0].username' $f) --rolename "$role" -r cpas
          fi
          role=$(jq -r '.users[0].realmRoles['$x']' $f)
          #echo "Role: "$role
          x=$(( $x + 1 ))
        done
done

