#
# Start with a fresh UBUNTU 22.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
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
node --version
npm  --version
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
cd /home/pat/src/keycloak-24.0.2
./bin/kc.sh --verbose build
./bin/kc.sh --verbose start-dev --http-port 8081 &
sleep 30
./bin/kcadm.sh config credentials --server http://172.19.0.2:8081 --realm master --user admin
./bin/kcadm.sh create realms -f conf/realm-import.json --server http://172.19.0.2:8081
cd ..
# change the IP addr from John's IP to the docker container IP
sed -i 's/192.168.1.106/172.19.0.2/' ./pat/patServer/Server/package.json
sed -i 's/192.168.1.106/172.19.0.2/' ./pat/patServer/Server/keycloak.json
sed -i 's/192.168.1.106/172.19.0.2/' ./pat/patClient/package.json
sed -i 's/192.168.1.106/172.19.0.2/' ./pat/patClient/public/keycloak.json
sed -i 's/192.168.1.106/172.19.0.2/' ./pat/patClient/.env
sed -i 's/dev.soaring/www.soaring/'  ./pat/patServer/Server/server/params.js
sudo chown pat:pat /home/pat/. -R
sudo chmod 775 -R  /home/pat/.

