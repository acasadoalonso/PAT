#
# Start with a fresh UBUNTU 22.04
#
# Requirements a  docker container with Ubuntu 22.04 as the base
#
# The Dockerfile execution installs the operating system, suporting software, java, keycloak, node and npm
# and copy all the supporting scritps on ~/src/sh
# However it can not install the software from git for the authentification issus, so this script is needed.
# This script is executed just after the docker run command and after attaching the container.
#
###################################################################################################
date
echo
echo "User: "$USER
echo
echo
echo "Installation on DOCKER "
echo "======================="
echo
export KCversion='25.0.2'
export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
echo "Container IP:  "$CONTAINERIP
echo "============================"
echo
git config --global --add safe.directory /home/pat/src/pat/patServer
git config --global --add safe.directory /home/pat/src/pat/patClient
# check for curl and install it if needed
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
echo
echo "Install the PAT software from GitHub"
echo
sudo usermod pat -s /bin/bash
cd /home/pat/src/pat
sudo chmod 775 .
sudo chown pat:pat .
rm -rf patServer
rm -rf patClient
gh auth login --with-token < ../mytoken.txt
#gh auth refresh -h github.com
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
cd patServer
#
# check the NODE and & NPM versions 
#
echo
echo "NODE & NPM versions ..."
echo "======================="
node --version
npm  --version
echo
echo "Compile the JS modules"
echo
cd       /home/pat/src/pat
(cd patClient;  npm install)
(cd patServer/Server; npm install)
#
cd       /home/pat/src/pat
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env.development.local
echo
echo "PAT installation done ..."
echo
cd       /home/pat/
chown pat:pat -R .			# change the ownership and modes f the modules
chmod 775     -R .
###################################################################################################
echo 
echo "Setup the aliases ..."
echo 
alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'
alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'
echo
###########################################################################################################
echo
echo "Start the keycloak system"
echo
cd /home/pat/src/keycloak-$KCversion
./bin/kc.sh --verbose build
sleep 10
./bin/kc.sh --verbose start-dev --http-port 8081 --https-client-auth none &
echo "Wait 120 seconds ....."
sleep 120
./bin/kc.sh show-config
echo " -----------------------------"
if [[ $CONTAINERIP == '' ]] ; then
        export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
	echo "Container IP:  "$CONTAINERIP
	echo "============================"
fi
echo 
echo "Container IP: "$CONTAINERIP
echo
echo
echo "Create the CPAS realm"
echo
echo
pwd
echo
echo "The password for admin is admin ... "
echo
./bin/kcadm.sh config credentials --server http://$CONTAINERIP:8081 --realm master --user admin
sleep 10
./bin/kcadm.sh update realms/master -s sslRequired=NONE
./bin/kcadm.sh create realms -f conf/realm-cpas.json --server http://$CONTAINERIP:8081
./bin/kcadm.sh get realms   --fields id,realm,enabled,displayName,displayNameHtml
./bin/kcadm.sh get users    -r cpas
./bin/kcadm.sh get clients  -r cpas
./bin/kcadm.sh get roles    -r cpas
./bin/kcadm.sh get groups   -r cpas
bash ./conf/addusers.sh
echo
###########################################################################################################
echo
cd ..
pwd
if [[ $CONTAINERIP == '' ]] ; then
        export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
	echo "Container IP:  "$CONTAINERIP
	echo "============================"
fi
echo "============================"
echo "Container IP:  "$CONTAINERIP
echo "Hostname:      "$(hostname)
echo "============================"
# change the IP addr from John's IP to the docker container IP
bash ~/src/pat/sh/changeip.sh

sudo chown pat:pat /home/pat/. -R
sudo chmod 775 -R  /home/pat/.
sudo atd
bash ~/src/sh/patcheck.sh
echo
echo "Installation on DOCKER done"
echo "==========================="
echo
date
###########################################################################################################
