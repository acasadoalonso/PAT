#
# Start with a fresh UBUNTU 22.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
export KCversion='25.0.2'
echo
echo "Installation on DOCKER "
echo "======================="
echo
export CONTAINERIP=$(getent hosts "$(hostname)" | awk '{ print $1 }' | head -n1)
echo "Container IP:  "$CONTAINERIP
echo "============================"
git config --global --add safe.directory /home/pat/src/pat/patServer
git config --global --add safe.directory /home/pat/src/pat/patClient
date
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
cd /home/pat/src/pat
rm -rf patServer
rm -rf patClient
gh auth login --with-token < ../mytoken.txt
gh auth refresh -h github.com
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
cd patServer
#
echo "NODE & NPM versions ..."
echo "======================="
node --version
npm  --version
echo
cd       /home/pat/src/pat
(cd patClient;  npm install)
(cd patServer/Server; npm install)
#
cd       /home/pat/src/pat
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env.development.local
echo "PAT installation done ..."
cd       /home/pat/
chown pat:pat -R .
chmod 775 -R .
###################################################################################################
echo 
echo "Setup the aliases ..."
alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'
alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'
echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'"                                                                       >>~/.bash_alias
es
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'"                                                 >>~/.bash_alias
es
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'"                                                 >>~/.bash_alias
es
echo "alias status='(echo ">>>>>";pgrep -a node;echo "====";pgrep -a java;echo "__________________")'"                               >>~/.bash_alias
es
echo "export KEYCLOAK_ADMIN='admin'"                                                                  >>~/.profile
echo "export KEYCLOAK_ADMIN_PASSWORD='admin'"                                                         >>~/.profile
echo "neofetch      "                                                                                 >>~/.profile
echo '(echo ">>>>>";pgrep -a node;echo "====";pgrep -a java;echo "__________________")'               >>~/.profile
echo "echo '__________________________________________________________________________________'     " >>~/.profile
echo "date      "                                                                                     >>~/.profile
echo "export KCversion="$KCversion                                                                    >>~/.profile
echo "export PATHOST=$(getent hosts "$(hostname)" | awk '{ print $1 }' | tail -n1)      "             >>~/.profile
echo "export KCHOST=$(getent hosts "$(hostname)"  | awk '{ print $1 }' | tail -n1)      "             >>~/.profile
echo 'echo "Host IP addr:      "$PATHOST      '                                                       >>~/.profile
echo 'echo "Keycloak IP addr:  "$KCHOST      '                                                        >>~/.profile
echo 'echo "Keycloak Version:  "$KCversion      '                                                     >>~/.profile
echo 'echo "========================================"      '                                          >>~/.profile
echo 'echo      '                                                                                     >>~/.profile
###########################################################################################################
cd /home/pat/src/keycloak-$KCversion
./bin/kc.sh --verbose build
./bin/kc.sh --verbose start-dev --http-port 8081 --https-client-auth none &
echo "Wait 90 seconds ....."
sleep 90
if [[ $CONTAINERIP == '' ]] ; then
	export CONTAINERIP=$(getent hosts "$(hostname)" | awk '{ print $1 }' | head -n1)
	echo "Container IP:  "$CONTAINERIP
	echo "============================"
fi
echo "Create the CPAS realm"
echo
echo
./bin/kcadm.sh config credentials --server http://$CONTAINERIP:8081 --realm master --user admin
./bin/kcadm.sh update realms/master -s sslRequired=NONE
./bin/kcadm.sh create realms -f conf/realm-cpas.json --server http://$CONTAINERIP:8081
./bin/kcadm.sh get realms   --fields id,realm,enabled,displayName,displayNameHtml
./bin/kcadm.sh get users    -r cpas
./bin/kcadm.sh get clients  -r cpas
./bin/kcadm.sh get roles    -r cpas
./bin/kcadm.sh get groups   -r cpas

echo
echo

cd ..
# change the IP addr from John's IP to the docker container IP
sed -i 's/192.168.1.106/$CONTAINERIP/' ./pat/patServer/Server/package.json
sed -i 's/192.168.1.106/$CONTAINERIP/' ./pat/patServer/Server/keycloak.json
sed -i 's/192.168.1.106/$CONTAINERIP/' ./pat/patClient/package.json
sed -i 's/192.168.1.106/$CONTAINERIP/' ./pat/patClient/public/keycloak.json
sed -i 's/192.168.1.106/$CONTAINERIP/' ./pat/patClient/.env
sed -i 's/dev.soaring/www.soaring/'    ./pat/patServer/Server/server/params.js
sudo chown pat:pat /home/pat/. -R
sudo chmod 775 -R  /home/pat/.
echo
echo "Installation on DOCKER done"
echo "==========================="
echo
date
