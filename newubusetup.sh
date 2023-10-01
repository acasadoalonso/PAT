#!/bin/bash
#
# this script is used to setup a new fresh UBUNTU server
#
if [ $# -eq 0  ]
then 
   echo "You need to provide server name"
   exit 
fi
echo "Update UBUNTU server: "$1
echo "======================================= "
ping -c 5 $1
ssh-keygen -f "/home/angel/.ssh/known_hosts" -R "$1"
sshpass -p"correo" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa angel@$1
echo "==============================================================="
ssh angel@$1 "sudo apt update "
ssh angel@$1 "sudo sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen"
ssh angel@$1 "sudo sed -i 's/^# *\(es_ES.UTF-8\)/\1/' /etc/locale.gen"
ssh angel@$1 "sudo locale-gen "
ssh angel@$1 "sudo apt install -y locales"
ssh angel@$1 "sudo update-locale "			
ssh angel@$1 "sudo apt install -y nfs-common nfs-kernel-server cifs-utils     "		
ssh angel@$1 "sudo apt-get install -y software-properties-common              "
ssh angel@$1 "sudo apt-get install -y python3-software-properties             "
ssh angel@$1 "sudo apt-get install -y build-essential                         "
ssh angel@$1 "sudo apt-get install -y python-is-python3                       "
ssh angel@$1 "sudo apt-get install -y qemu-guest-agent                        "
ssh angel@$1 "echo 'export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LANGUAGE=en_US.UTF-8 ' >>~/.profile "
ssh angel@$1 "echo 'export LD_LIBRARY_PATH=/usr/local/lib' >>~/.profile "
ssh angel@$1 "echo 'neofetch'                 >>~/.profile "
echo "==============================================================="
ssh angel@$1 "sudo mkdir -p /nfs "
ssh angel@$1 "sudo mkdir -p /newnfs "
ssh angel@$1 "sudo mkdir -p /wrk"
ssh angel@$1 "sudo mkdir -p /nas1"
ssh angel@$1 "sudo mkdir -p /nas2"
ssh angel@$1 "mkdir      -p src/sh"
scp ~/src/sh/commoninstall.sh    angel@$1:~/src/sh 
scp ~/src/sh/nfs.sh              angel@$1:~/src/sh 
scp /nfs/hosts                   angel@$1:~/src/sh 
scp ~/.smbcredentials3           angel@$1:~
scp ~/Documents/meshi.sh         angel@$1:~/src/sh 
ssh angel@$1 '[ ! -d /usr/local/mesh_services ] && cd ~/src/sh/ && bash ~/src/sh/meshi.sh'
echo "==============================================================="
ssh angel@$1 "cd ;ls -la ;rm -f Vid* Mus* Book* Temp* Pub*  "
ssh angel@$1 "sudo mount 192.168.1.10:/nfs/NFS/Documents /nfs"
ssh angel@$1 "sudo mount 192.168.1.9:/nfs/NFS/           /newnfs"
ssh angel@$1 "sudo mount -t cifs --rw -o credentials=~/.smbcredentials3,uid=1000 //192.168.1.4/CASADOTNAS /nas1"
ssh angel@$1 "sudo mount -t cifs --rw -o credentials=~/.smbcredentials3,uid=1000 //192.168.1.4/CASADOlocal/LocalFiles /nas2"
ssh angel@$1 "sudo sed -i 's/^#alias/alias/' .bashrc"
ssh angel@$1 "sudo cat /etc/hosts /nfs/hosts >temp.hosts"
ssh angel@$1 "sudo cp temp.hosts /etc/hosts "
ssh angel@$1 "sudo rm temp.hosts  "
echo "==============================================================="
ssh angel@$1 "sudo apt upgrade -y"
ssh angel@$1 "sudo apt install -y fail2ban monit neofetch ntpdate git mariadb-client"
ssh angel@$1 "neofetch "
ssh angel@$1 "sudo timedatectl set-timezone Europe/Madrid "
ssh angel@$1 "sudo apt autoremove -y"
echo "==============================================================="
ping -c 5 $1

#update /etc/dhpcd.conf
