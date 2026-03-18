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
cp Dockerfile.keycloak  patServer
cp .env.patServer       patServer/.env
cp Makefile             patServer
cp *.json               patServer
cp SetupKeycloak.sh     patServer
cp .env.patClient       patClient/.env
cp Dockerfile.patClient patClient
#
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
###########################################################################################################
echo
cd ..
pwd
if [[ $CONTAINERIP == '' ]] ; then
        export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
	echo "Container IP:  "$CONTAINERIP
	echo "============================"
fi
#
# setup the Keycloak realm
#
bash SetupKeycloak.sh

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
