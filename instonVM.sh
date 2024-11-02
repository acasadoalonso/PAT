#!/bin/bash 
#
# Start with a fresh UBUNTU 22.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
echo 
export KCversion='25.0.2'
date
echo "Runninng "$(basename "$0")
echo "Intalling PAT and KeyCloack version: "$KCversion
# <<<<<<<<<<<<<<<<<  CHECK those values first >>>>>>>>>>
export KCversion='25.0.2'
export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
export KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)

echo "Host IP addr:      "$PATHOST
echo "Keycloak IP addr:  "$KCHOST
echo "User:              "$USER
echo "KCversion:         "$KCversion
echo "========================================"
echo
##################################################
sudo apt update
sudo apt upgrade -y
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
sudo apt-get install -y wget systemd git libarchive-dev  vim inetutils-ping figlet ntpdate ssh sudo openssh-server
echo 
echo "Install service programs"
echo "========================"
echo 
sudo apt-get install -y gh gcc g++ make curl neofetch iproute2 ca-certificates gnupg libfmt-dev
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=18
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install -y nodejs libfmt-dev
npm install -g npm@10.1.0
sudo apt autoremove -y
mkdir -p ~/src
mkdir -p ~/src/pat
cd       ~/src/pat
echo 
echo "Get the software from John's repo ..."
echo "====================================="
echo 
gh auth login --with-token <../mytoken.txt
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
cd patServer
#
echo 
echo "Node and NPM versions:"
echo "======================"
node --version
npm  --version
echo 
echo "Install the NODE modules needed ...."
echo "===================================="
echo 
cd   ~/src/pat
(cd patClient;  npm install)
echo 
(cd patServer/Server; npm install)
#
echo 
echo "Setup the aliases ..."
echo 
alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'
alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'
echo 
echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'"                                         >>~/.bash_aliases
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'"                   >>~/.bash_aliases
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'"                   >>~/.bash_aliases
echo "alias status='(pgrep -a node;echo ;pgrep -a java;echo )'"                                        >>~/.bash_aliases
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

if [[ $KCversion == '25.0.2' ]]
then
    echo "alias kcstart='(sudo ~/src/*$KCversion/bin/kc.sh --verbose start-dev --hostname $KCHOST  --http-port=8081 --http-enabled true --https-client-auth none --features=organization &)'"    >>~/.bash_aliases
else

    echo "alias kcstart='(export KEYCLOAK_ADMIN='admin' && export KEYCLOAK_ADMIN_PASSWORD='benalla' && sudo ~/src/*$KCversion/bin/kc.sh --verbose start-dev  --http-port 8081  --http-enabled true --https-client-auth none --features=organization &)'"    >>~/.bash_aliases
fi
echo 
cd   ~/src/pat
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env.development.local
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env
echo 
echo "Install JAVA now ..."
echo 
sudo apt-get install -y openjdk-17-jre-headless openjdk-17-jdk-headless
cd   ~/src/
sudo echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
echo 
echo "Get the KeyCloak source ..."
echo
echo
wget http://github.com/keycloak/keycloak/releases/download/$KCversion/keycloak-$KCversion.tar.gz
tar zxvf keycloak-$KCversion.tar.gz
rm       keycloak-$KCversion.tar.gz
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
cd ~/src/keycloak-$KCversion/
pwd
mkdir -p conf
# copy the configuration files 
cp -r ../PAT/keycloak/*  ~/src/keycloak-$KCversion/conf/
# COPY the very basic REALM
sed -i "s/192.168.1.5/$PATHOST/" ../PAT/keycloak/realm-cpas.json
cp                               ../PAT/keycloak/realm-cpas.json ~/src/keycloak-$KCversion/conf
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
echo "====================="
echo
echo
./bin/kcadm.sh config credentials --server http://$KCHOST:8081 --realm master --user admin
echo
echo
pwd
./bin/kcadm.sh update realms/master -s sslRequired=NONE
# create the ream CPAS 
./bin/kcadm.sh create realms -f conf/realm-cpas.json --server http://$KCHOST:8081
# check the users
./bin/kcadm.sh get realms   --fields id,realm,enabled,displayName,displayNameHtml
./bin/kcadm.sh get users    -r cpas
./bin/kcadm.sh get clients  -r cpas
./bin/kcadm.sh get roles    -r cpas
./bin/kcadm.sh get groups   -r cpas
bash ../keycloak/addusers.sh
pwd

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
sudo apt autoremove -y
echo
echo "PAT installation done ..."
echo "========================="
echo
echo
date
