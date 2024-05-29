#
# Start with a fresh UBUNTU 22.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
# <<<<<<<<<<<<<<<<<  update those values >>>>>>>>>>
export PATHOST='192.168.1.6'
export KCHOST='192.168.1.6'
echo "Host IP addr:  "$PATHOST
echo
sudo apt update
sudo apt upgrade -y
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
sudo apt-get install -y wget systemd git libarchive-dev  vim inetutils-ping figlet ntpdate ssh sudo openssh-server 				
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
echo "Get the software from John's repo ..."
gh auth login --with-token < mytoken.txt
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
cd patServer
#
echo "Node and NPM versions:"
echo "======================"
node --version
npm  --version
echo "Install the NODE modules needed ...."
cd   ~/src/pat
(cd patClient;  npm install)
(cd patServer/Server; npm install)
#
echo "Setup the aliases ..."
alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'
alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'
echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'"                                                                       >>~/.bash_aliases
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'"                                                 >>~/.bash_aliases
echo "alias startkc='(sudo ~/src/*2/bin/kc.sh --verbose start-dev --http-host $KCHOST --http-port 8081  --http-enabled true  &)'"    >>~/.bash_aliases
cd   ~/src/pat
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env.development.local
echo "Install JAVA now ..."
sudo apt-get install -y openjdk-17-jre-headless openjdk-17-jdk-headless
cd   ~/src/
sudo echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
echo "Get the KeyCloak source ..."
wget https://github.com/keycloak/keycloak/releases/download/24.0.2/keycloak-24.0.2.tar.gz
tar zxvf keycloak-24.0.2.tar.gz
rm       keycloak-24.0.2.tar.gz
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
cd ~/src/keycloak-24.0.2/
# COPY the very basic REALM
cp ../keycloak/realm-import.json ~/src/keycloak-24.0.2/conf
./bin/kc.sh --verbose build
./bin/kc.sh --verbose start-dev --http-port 8081 &
echo "Wait 90 seconds ....."
sleep 90
echo "Create the CPAS realm"
echo
echo
./bin/kcadm.sh config credentials --server http://$KCHOST:8081 --realm master --user admin
./bin/kcadm.sh create realms -f conf/realm-import.json --server http://$KCHOST:8081
cd ..
# change the IP addr from John's IP to the docker container IP
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patServer/Server/package.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patServer/Server/keycloak.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/package.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/public/keycloak.json
sed -i "s/192.168.1.106/$PATHOST/" ./pat/patClient/.env
sed -i "s/dev.soaring/www.soaring/"  ./pat/patServer/Server/server/params.js
sudo chown pat:pat /home/pat/. -R
sudo chmod 775 -R  /home/pat/.
echo
echo "Installation on DOCKER done"
echo "==========================="
echo
date

sudo apt autoremove -y
echo "PAT installation done ..."
echo "========================="
echo
echo
