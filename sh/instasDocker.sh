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
export KC_VERSION='25.0.2'
export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export CONTAINERIP=$(hostname -I | awk '{ print $1 }' | tail -n1)
echo "Container IP:  "$CONTAINERIP
echo "============================"
echo
# check for curl and install it if needed
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
#
######################################################
sudo apt update
sudo apt upgrade -y
mkdir -p ~/src
mkdir -p ~/src/pat
mkdir -p ~/src/sh
echo
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
sudo mkdir -p /etc/apt/keyrings
# install gh
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
# install the service programs
echo 
echo "Install service programs"
echo "========================"
echo 
sudo apt-get install -y wget systemd git libarchive-dev  vim inetutils-ping figlet ntpdate ssh sudo openssh-server
sudo apt-get install -y gh jq gcc g++ make curl neofetch iproute2 ca-certificates gnupg libfmt-dev logrotate net-tools
#
######################################################

echo
echo "Install the PAT software from GitHub"
echo
echo "Current dir: "$(pwd)
echo "=================================="
echo
cd ~/src/pat
sudo rm -rf patServer
sudo rm -rf patClient
echo "Login into github ..."
echo "====================="
gh auth login --with-token < ../../mytoken.txt
#gh auth refresh -h github.com
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
echo "Directory content:"
echo "=================:"
ls -la pat*
#
# TEMP hack
#
cp ../dockerfiles/Makefile             ~/src/pat/patServer
#
export HOSTNAME=$PATHOST
cd ~/src/pat/patServer
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
alias kcadm="docker exec keycloak bash /opt/keycloak/bin/kcadm.sh"

echo
echo "alias status='(pgrep -a node;echo;pgrep -a java;echo;sudo netstat -ano -p tcp|grep 8000;echo)'" >>~/.bash_aliases
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
echo "============================"
echo "Container IP:  "$CONTAINERIP
echo "Hostname:      "$(hostname)
echo "============================"
echo
cd -
bash SetupKeycloak.sh

echo "Installation on DOCKER done"
echo "==========================="
echo
date
###########################################################################################################
