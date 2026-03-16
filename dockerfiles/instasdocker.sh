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
alias pat='(cd ~/src/PAT/dockerfiles/patServer && docker compose up -d)'
alias patrestart='(cd ~/src/PAT/dockerfiles/patServer && docker compose restart) '
alias kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"

echo
echo "alias pat='(cd ~/src/PAT/dockerfiles/patServer && docker compose up)'"                         >>~/.bash_aliases
echo "alias patrestart='(cd ~/src/PAT/dockerfiles/patServer && docker compose restart)'"             >>~/.bash_aliases
echo "alias status='(pgrep -a node;echo;pgrep -a java;echo;sudo netstat -ano -p tcp|grep 8080;echo)'" >>~/.bash_aliases
echo "alias kcadm='docker exec keycloak bash /opt/keycloak/bin/kcadm.sh'"                            >>~/.bash_aliases

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
shopt -s expand_aliases
alias  kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"
export KEYCLOAK_URL=http://192.168.1.5:8081     #/auth
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=Madrid


echo Login
kcadm config credentials --server $KEYCLOAK_URL  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"
kcadm update realms/master -s sslRequired=NONE
kcadm create realms -f conf/realm-cpas.json --server http://$CONTAINERIP:8081
kcadm get realms   --fields id,realm,enabled,displayName,displayNameHtml
kcadm get users    -r cpas
kcadm get clients  -r cpas
kcadm get roles    -r cpas
kcadm get groups   -r cpas
echo "=============="
groupid=$(kcadm get groups -r cpas -F id --noquotes --format CSV)
echo "GroupID:   "$groupid
kcadm get groups -r cpas
kcadm create groups/$groupid/children   -r cpas -s name=Europe
kcadm create groups/$groupid/children   -r cpas -s name=Australia
kcadm create groups/$groupid/children   -r cpas -s name=USA
kcadm create groups/$groupid/children   -r cpas -s name=SouthAmerica
kcadm create groups/$groupid/children   -r cpas -s name=Africa
kcadm get    groups/$groupid/children   -r cpas
kcadm get    groups/$groupid/children   -r cpas -F id,name --noquotes --format CSV

kcadm create users    -r cpas -f user1.json
kcadm create users    -r cpas -f user2.json
kcadm create users    -r cpas -f user3.json
echo "=============="
kcadm get    users    -r cpas
echo "=============="

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
echo
echo "Installation on DOCKER done"
echo "==========================="
echo
date
###########################################################################################################
