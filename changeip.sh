#!/bin/bash 
date
# <<<<<<<<<<<<<<<<<  CHECK those values first >>>>>>>>>>
export PATHOST=$(getent hosts "$(hostname)" | awk '{ print $1 }' | tail -n1)
export KCHOST=$(getent hosts "$(hostname)"  | awk '{ print $1 }' | tail -n1)
echo "Host IP addr:      "$PATHOST
echo "Keycloak IP addr:  "$KCHOST
echo "========================================"
echo
##################################################
sudo apt update
cd ~/src/
# change the IP addr from John's IP to the docker container IP
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patServer/Server/package.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patServer/Server/keycloak.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/package.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/public/keycloak.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/.env
sed -i "s/dev.soaring/www.soaring/"  ./pat/patServer/Server/server/params.js
cd
sudo chown $USER:$USER . -R
sudo chmod 775 -R  .
echo
echo
date
