#!make
#
# This is the Makefile to build the PAT docker container
#
SUBNET := 172.19.0.0			# subnet used
CONTAINERIP := 172.19.0.2		# IP assigned to the PAT container
PATPORT := 3003:3000			# port used by the PAT client
APIPORT := 8080:8080			# port used by the server listening
KCPORT  := 8081:8081			# port used by the Keycloak console


build :
	docker compose build --no-cache=false 
clean:
	docker compose rmi 
	docker system prune 
	docker images
cleanpat:
	docker compose rmi 
	docker images
	rm -r dockerdata
run:
	export API_PORT=8080
	export AUTH_PORT=8081
	export FRONTEND_PORT=300
	echo $USER
	SCRIPT=$(readlink -f $0)
	SCRIPTPATH=`dirname $SCRIPT`
	cd $SCRIPTPATH
	mkdir -p  ./proxdata		# dockerdata within this directory contains the PAT data
	sudo chmod 775 ./proxdata	# be sure that is accesable 
	clear
	export ROOT=`pwd`/proxdata
	if [ -f ./igc_fr_geoid.txt ]
	then
  		cp --update=none ./igc_fr_geoid.txt $ROOT
	fi

	export FRONTEND_URL=http://$(hostname -I | awk '{ print $1 }' | tail -n1):$FRONTEND_PORT
	export AUTH_SERVER_URL=http://$(hostname -I | awk '{ print $1 }' | tail -n1):$AUTH_PORT
	export REACT_APP_AUTH_SERVER_URL=$AUTH_SERVER_URL
	export REACT_APP_API_URL=http://$(hostname -I | awk '{ print $1 }' | tail -n1):$API_PORT

	docker compose up -d
setup:
	bash SetupKeycloak.sh
attach:
	docker attach pat_server
start:
	docker compose start  &
meshinst:
	docker exec   pat_server bash /home/pat/src/sh/meshi.sh &
mesh:
	docker exec   pat_server bash /home/pat/src/sh/meshstart.sh &
net:
	docker network create --subnet=${SUBNET}/16 cpas
ssh:
	docker exec -it pat_server /bin/bash service ssh start
	sshpass -p docker  ssh pat@${CONTAINERIP} 
