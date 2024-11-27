#!/bin/bash 
######################################################
#
# Start with a fresh UBUNTU 24.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
######################################################
echo "Runninng "$(basename "$0")
echo "Intalling PAT and KeyCloack version: "
date
######################################################
# <<<<<<<<<<<<<<<<<  CHECK those values first >>>>>>>>>>
echo 
export KCversion='25.0.2'			# Keycloak version
export KCfqn=''					# export KCfqn='icgpat.fai.org:10051'      KC API
export NODE='20'				# Node Version
export NPM='npm@10.1.0'				# NPM version
export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KCHOST=$(hostname -I  | awk '{ print $1 }' | tail -n1)
echo
echo "Host IP addr:      "$PATHOST
echo "Keycloak IP addr:  "$KCHOST
echo "User:              "$USER
echo "KCversion:         "$KCversion
echo "NODEversion:       "$NODE
echo "NPMversion:        "$NPM
echo "========================================"
echo
#
######################################################
sudo apt update
sudo apt upgrade -y
mkdir -p ~/src
mkdir -p ~/src/pat
mkdir -p ~/src/sh
if [[ -d ~/src/PAT ]]			# if we have the github directory
then					# copy the aux scripts	
   cp -r ~/src/PAT/sh/*.sh 		~/src/sh/
   cp -r ~/src/PAT/keycloak 		~/src/
   cp    ~/src/PAT/crontab.data 	~/src/
   cp    ~/src/PAT/logrotate.conf 	~/src/
fi
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
sudo apt-get install -y gh gcc g++ make curl neofetch iproute2 ca-certificates gnupg libfmt-devi logrotate net-tools
#
######################################################
echo 
echo "Install JAVA now ..."
echo "===================="
echo 
sudo apt-get install -y openjdk-17-jre-headless openjdk-17-jdk-headless
sudo echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
#
######################################################
echo 
echo "Install NODE and NPM now ..."
echo "============================"
echo 
sudo curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=$NODE
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install -y nodejs libfmt-dev
sudo npm install -g $NPM
echo 
echo "Node and NPM versions:"
echo "======================"
node --version
npm  --version
sudo apt autoremove -y
#
######################################################
cd   ~/src/
echo 
echo "Get the KeyCloak source ..."
echo "==========================="
echo
echo
wget http://github.com/keycloak/keycloak/releases/download/$KCversion/keycloak-$KCversion.tar.gz
tar zxvf keycloak-$KCversion.tar.gz
rm       keycloak-$KCversion.tar.gz
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
cd ~/src/keycloak-$KCversion/
pwd
export PATH=$PATH:$(pwd)/bin
mkdir -p conf
# copy the configuration files 
if [[ -d ~/src/PAT ]]				# if we have the github directory
then
	cp -r ../PAT/keycloak/*  ~/src/keycloak-$KCversion/conf/
	# COPY the very basic REALM
	sed -i "s/192.168.1.5/$PATHOST/" ../PAT/keycloak/realm-cpas.json
	cp                               ../PAT/keycloak/realm-cpas.json ~/src/keycloak-$KCversion/conf
fi
#
######################################################
cd       ~/src/pat
echo 
echo "Get the software from John's repo ..."
echo "====================================="
echo 
rm -rf patClient
rm -rf patServer
if [ -f ../mytoken.txt ] ; then
	echo 
	echo "Login and Clone the github repo ...."
	echo "===================================="
	echo 
	gh auth login --with-token <../mytoken.txt
	gh repo clone jwharington/patClient
	gh repo clone jwharington/patServer
	cd patServer
#
######################################################
	echo 
	echo "Install the NODE modules needed ...."
	echo "===================================="
	echo 
	cd   ~/src/pat
	(cd patClient;  npm install)
	echo 
	(cd patServer/Server; npm install)
	cd       ~/src/pat
#
######################################################
else
	echo 
	echo "Get the GITHUB token prior to the installation ...."
	echo "==================================================="
	echo 
	echo 
	echo 
	echo 
	exit
fi
#
######################################################
echo 
echo "Setup the aliases ..."
echo "====================="
echo 
alias pat='(cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'
alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'
if [[ $KCversion == '25.0.2' ]]
then
    echo "alias kcstart='(~/src/*$KCversion/bin/kc.sh --verbose start-dev --hostname $KCHOST  --http-port=8081 --http-enabled true --https-client-auth none --features=organization >>/tmp/kc.log &)'"    							       >>~/.bash_aliases
else
    echo "alias kcstart='(~/src/*$KCversion/bin/kc.sh --verbose start-dev  --http-port 8081  --http-enabled true --https-client-auth none --features=organization >>/tmp/kc.log &)'"                                                                                   >>~/.bash_aliases
fi
echo 
echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'"                         >>~/.bash_aliases
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'"   >>~/.bash_aliases
echo "alias status='(pgrep -a node;echo;pgrep -a java;echo;sudo netstat -ano -p tcp|grep 8080;echo)'" >>~/.bash_aliases
#
echo "export KEYCLOAK_ADMIN='admin'"                                                                  >>~/.profile
echo "export KEYCLOAK_ADMIN_PASSWORD='admin'"                                                         >>~/.profile
echo "neofetch      "                                                                                 >>~/.profile
echo '(echo ;pgrep -a node;echo ;pgrep -a java;echo )'                                                >>~/.profile
echo "echo '__________________________________________________________________________________'     " >>~/.profile
echo "date      "                                                                                     >>~/.profile
echo "export KCversion="$KCversion                                                                    >>~/.profile
echo "export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)"				      >>~/.profile
echo "export KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)"				      >>~/.profile
echo 'echo "Host IP addr:      "$PATHOST      '                                                       >>~/.profile
echo 'echo "Keycloak IP addr:  "$KCHOST      '                                                        >>~/.profile
echo 'echo "Keycloak Version:  "$KCversion      '                                                     >>~/.profile
echo 'echo "User:              "$USER           '                                                     >>~/.profile
echo 'echo "========================================"      '                                          >>~/.profile
echo 'echo      '                                                                                     >>~/.profile
echo 
alias
echo 
cd   ~/src/pat
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env.development.local
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env
#
######################################################
cd ~/src/keycloak-$KCversion/
pwd
echo 
echo "Build Keycloak"
echo "=============="
echo
./bin/kc.sh --verbose build --https-client-auth none
echo 
echo "Start Keycloak"
echo "=============="
echo
./bin/kc.sh --verbose start-dev --http-port 8081 --https-client-auth none &
echo
echo
echo "Wait 90 seconds ..... untill KC has started ..."
echo "==============================================="
sleep 90
echo "Back from sleep ..."
echo "==================="
echo
echo
echo "Create the CPAS realm"
echo "====================="
echo
echo
./bin/kcadm.sh config credentials --server http://localhost:8081 --realm master --user admin
echo
echo
pwd
./bin/kcadm.sh update realms/master -s sslRequired=NONE
# create the realm CPAS 
./bin/kcadm.sh delete realms/cpas                  	# delete the realm just in case
./bin/kcadm.sh create realms -f conf/realm-cpas.json --server http://localhost:8081
# check the users
./bin/kcadm.sh get realms   --fields id,realm,enabled,displayName,displayNameHtml
./bin/kcadm.sh get users    -r cpas
./bin/kcadm.sh get clients  -r cpas
./bin/kcadm.sh get roles    -r cpas
./bin/kcadm.sh get groups   -r cpas
bash ../keycloak/addusers.sh
pwd

######################################################
echo
echo
cd ..
# change the IP addr from John's IP to the docker container IP
bash ~/src/sh/changeip.sh
if [ -f crontab.data ]		
then 			
     	echo				
        echo "==================="
     	echo "Set the crontab ..."
        echo "==================="
     	echo			
     	crontab <crontab.data
     	crontab -l 	
fi	
cd
echo "Updating mode and owner ..."
echo "==========================="
sudo chown $USER:$USER . -R
sudo chmod 775 -R  .
echo
sudo apt autoremove -y
echo
echo "PAT installation done ..."
echo "========================="
echo
echo
date
