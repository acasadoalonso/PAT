#!make
#
# This is the Makefile to build the PAT docker container
#
SUBNET := 172.19.0.0			# subnet used
CONTAINERIP := 172.19.0.2		# IP assigned to the PAT container
PATPORT := 3003:3000			# port used by the PAT client
KCPORT := 8081:8081			# port used by the Keycloak console


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
	mkdir -p  ./dockerdata		# dockerdata within this directory contains the PAT data
	sudo chmod 775 ./dockerdata	# be sure that is accesable 
	clear
	docker compose up -d
setup:
	bash SetupKeycloak.sh
attach:
	docker attach patc
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
