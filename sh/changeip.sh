#!/bin/bash 
#
# this script is used to change the IP addr of the server running pat from the original running on John's laptop
#
date
export KCversion='25.0.2'
export KCfqn=''					# export KCfqn='icgpat.fai.org:10051'      KC API
export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KCHOST=$(hostname -I  | awk '{ print $1 }' | tail -n1)
# <<<<<<<<<<<<<<<<<  CHECK those values first >>>>>>>>>>
echo "Host IP addr:      "$PATHOST
echo "Keycloak IP addr:  "$KCHOST
echo "KC version:        "$KCversion
echo "Keycloak Fqn:      "$KCfqn
echo "========================================"
echo
##################################################
cd ~/src/
export oldIP=$(cat ./pat/patServer/Server/keycloak.json | awk '/http/{print $(NF)}'| awk ' {print substr($0, 9)}' | sed 's/:.*//')
echo "Current IP addr on the package:    "$oldIP
echo "Current IP addr of the server:     "$PATHOST
echo "========================================"
echo
##################################################
# change the IP addr from John's IP to the docker container IP
if [[ $PATHOST != $oldIP ]]
then
	sed -i "s/$oldIP/$PATHOST/" ./pat/patServer/Server/package.json
	sed -i "s/$oldIP/$PATHOST/" ./pat/patClient/package.json
	sed -i "s/$oldIP/$PATHOST/" ./pat/patClient/.env
	sed -i "s/dev.soaring/www.soaring/"  ./pat/patServer/Server/server/params.js
	if [[ $KCfqn == '' ]]
	then
    		sed -i "s/$oldIP/$PATHOST/" ./pat/patServer/Server/keycloak.json
    		sed -i "s/$oldIP/$PATHOST/" ./pat/patClient/public/keycloak.json
	else
    		sed -i "s/$oldIP:8081/$KCfqn/" ./pat/patServer/Server/keycloak.json
    		sed -i "s/$oldIP:8081/$KCfqn/" ./pat/patClient/public/keycloak.json
	fi
fi
##################################################
cd
sudo chown $USER:$USER . -R
sudo chmod 775 -R  .
echo
echo
date
