#!/bin/bash 
#
# Start with a fresh UBUNTU 22.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
KCversion='25.0.2'
date
echo "Runninng "$(basename "$0")
echo "Intalling PAT and KeyCloack version: "$KCversion
# <<<<<<<<<<<<<<<<<  CHECK those values first >>>>>>>>>>
export PATHOST=$(getent hosts "$(hostname)" | awk '{ print $1 }' | tail -n1)
export KCHOST=$(getent hosts "$(hostname)"  | awk '{ print $1 }' | tail -n1)
echo "Host IP addr:      "$PATHOST
echo "Keycloak IP addr:  "$KCHOST
echo "========================================"
echo
##################################################
echo "Setup the aliases ..."
if [[ $KCversion == '25.0.2' ]]
then
    echo "alias kcstart='(sudo ~/src/*$KCversion/bin/kc.sh --verbose start-dev --hostname $KCHOST  --http-port=8081 --http-enabled true --https-client-auth none --features=organization &)'"    >>~/.bash_aliases
else

    echo "alias kcstart='(export KEYCLOAK_ADMIN='admin' && export KEYCLOAK_ADMIN_PASSWORD='benalla' && sudo ~/src/*$KCversion/bin/kc.sh --verbose start-dev  --http-port 8081  --http-enabled true --https-client-auth none --features=organization &)'"    >>~/.bash_aliases
fi
echo 
cd   ~/src/
echo 
echo "Get the KeyCloak source ..."
echo
echo
wget https://github.com/keycloak/keycloak/releases/download/$KCversion/keycloak-$KCversion.tar.gz
tar zxvf keycloak-$KCversion.tar.gz
rm       keycloak-$KCversion.tar.gz
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
cd ~/src/keycloak-$KCversion/
echo 
echo "Copy REALM"
echo
# COPY the very basic REALM
sed -i "s/192.168.1.5/$PATHOST/" ../keycloak/realm-cpas.json
cp                               ../keycloak/realm-cpas.json ~/src/keycloak-$KCversion/conf
echo 
echo "Build Keycloak"
echo
./bin/kc.sh --verbose build --https-client-auth none
echo 
echo "Start Keycloak"
echo
./bin/kc.sh --verbose start-dev --http-port 8081 --https-client-auth none &
echo
echo
echo "Wait 90 seconds ..... untill KC has started ..."
sleep 90
echo
echo "Create the CPAS realm"
echo
echo
./bin/kcadm.sh config credentials --server http://$KCHOST:8081 --realm master --user admin
echo
echo
./bin/kcadm.sh update realms/master -s sslRequired=NONE
./bin/kcadm.sh create realms -f conf/realm-cpas.json --server http://$KCHOST:8081
./bin/kcadm.sh get realms --fields id,realm,enabled,displayName,displayNameHtml
./bin/kcadm.sh get clients -r cpas --fields 'id,clientId,protocolMappers(id,name,protocol,protocolMapper)'
./bin/kcadm.sh get groups  -r cpas --offset 0 --limit 100
./bin/kcadm.sh get users   -r cpas --offset 0 --limit 100
./bin/kcadm.sh get roles   -r cpas --offset 0 --limit 100
echo
echo
cd ..
# change the IP addr from John's IP to the docker container IP
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patServer/Server/package.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patServer/Server/keycloak.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/package.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/public/keycloak.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/.env
sed -i "s/dev.soaring/www.soaring/"  ./pat/patServer/Server/server/params.js
cd
echo "Updating mode and owner ..."
echo "==========================="
sudo chown $USER:$USER . -R
sudo chmod 775 -R  .
echo
echo
date
