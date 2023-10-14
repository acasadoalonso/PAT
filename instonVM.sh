#
# Start with a fresh UBUNTU 22.04
#
# Requirements a VM or LXC with 16Gb storage and 2048 Mb memory
#
sudo apt update
sudo apt upgrade -y
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
sudo apt install -y gh gcc g++ make curl iproute2 
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
echo "Get the software from John repo ..."
gh auth login --with-token < mytoken.txt
gh repo clone jwharington/patClient
gh repo clone jwharington/patServer
cd patServer
#
echo "Node and NPM versions:"
node --version
npm  --version
echo "Install the modules needed ...."
cd       ~/src/pat
(cd patClient;  npm install)
(cd patServer/Server; npm install)
#
alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'
alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'
echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh &)'" >>~/.bash_aliases
echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh &)'" >>~/.bash_aliases
cd       ~/src/pat
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true">>patClient/.env.development.local
sudo apt autoremove -y
echo "PAT installation done ..."
