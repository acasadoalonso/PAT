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
# check for curl and install it if needed
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
echo
echo "Install the PAT software from GitHub"
echo
echo "Current dir: "$(pwd)
rm -rf patServer
rm -rf patClient
gh auth login --with-token < ../../mytoken.txt
#gh auth refresh -h github.com
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
echo "Directory content:"
ls -la
#
# TEMP hack
#
cp docker-compose.yaml  patServer
cp Dockerfile.patServer patServer
cp Dockerfile.patClient patClient
cp Dockerfile.keycloak  patServer
cp .env.patServer       patServer/.env
cp .env.patClient       patClient/.env
cd patServer
mv compose.yml  compose.orig
mv Dockerfile   Dockerfile.orig
docker compose stop
docker compose rm
docker compose build --no-cache
docker compose up -d
docker ps -a
echo
echo "PAT installation done ..."
echo
###################################################################################################
echo 
echo "Setup the aliases ..."
echo 
alias pat='docker compose up -d'
alias patrestart='(docker compose restart) '
echo
###########################################################################################################
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
cd ~/src/keycloak-$KCversion/
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
