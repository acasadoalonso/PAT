#!make
#
# This is the Makefile to build the PAT docker container
#
SUBNET := 172.19.0.0			# subnet used
CONTAINERIP := 172.19.0.2		# IP assigned to the PAT container

build :
	docker compose build --no-cache=false 
clean:
	docker compose rm 
	docker system prune 
	docker images
cleanpat:
	docker compose rmi 
	docker images
run:
	. ./env
	echo $USER
	SCRIPT=$(readlink -f $0)
	SCRIPTPATH=`dirname $SCRIPT`
	cd $SCRIPTPATH
	mkdir -p  ./proxdata		# dockerdata within this directory contains the PAT data
	sudo chmod 775 ./proxdata	# be sure that is accesable 
	clear
	export ROOT=`pwd`/proxdata


	docker compose up -d
setup:
	bash SetupKeycloak.sh
attach:
	docker attach pat_server
start:
	docker compose start  -d
meshinst:
	docker exec   pat_server bash /home/pat/src/sh/meshi.sh &
mesh:
	docker exec   pat_server bash /home/pat/src/sh/meshstart.sh &
net:
	docker network create --subnet=${SUBNET}/16 cpas
ssh:
	docker exec -it pat_server /bin/bash service ssh start
	sshpass -p docker  ssh pat@${CONTAINERIP} 
