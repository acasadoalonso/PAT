#!make
#
# This is the Makefile to build the PAT docker container
#
IMAGE_NAME := pat
FULL_VERSION := 0.1.0
MINOR_VERSION := 0.1
MAJOR_VERSION := 0
SUBNET := 172.19.0.0			# subnet used
CONTAINERIP := 172.19.0.2		# IP assigned to the PAT container
PATPORT := 3003:3000				# port used by the PAT client
KCPORT := 8082:8081				# port used by the Keycloak console

dev:
	docker build --no-cache=false -t ${IMAGE_NAME} .

build :
	docker build --no-cache=false -t ${IMAGE_NAME}:$(FULL_VERSION)  .
	docker tag ${IMAGE_NAME}:$(FULL_VERSION) ${IMAGE_NAME}:$(MINOR_VERSION)
	docker tag ${IMAGE_NAME}:$(FULL_VERSION) ${IMAGE_NAME}:$(MAJOR_VERSION)
	docker tag ${IMAGE_NAME}:$(FULL_VERSION) ${IMAGE_NAME}
clean:
	docker rmi ${IMAGE_NAME} 
	docker system prune 
	docker images
cleanpat:
	docker rmi ${IMAGE_NAME}:$(FULL_VERSION)  
	docker rmi ${IMAGE_NAME}:$(MINOR_VERSION)
	docker rmi ${IMAGE_NAME}:$(MAJOR_VERSION)
	docker rmi ${IMAGE_NAME} 
	docker images
run:
	mkdir -p  ./dockerdata
	chmod 775 ./dockerdata
	- docker ps -a
	- docker stop patc
	- docker rm patc
	#- docker network create --subnet=${SUBNET}/16 mynetpat
	docker  run -ti --net mynetpat --ip ${CONTAINERIP} -p ${PATPORT} -p ${KCPORT} --restart unless-stopped --name patc --hostname PATdock -v ./dockerdata:/home/pat/src/pat pat 
	- docker ps -a
attach:
	docker attach patc
	# after attach
	# su pat
	# bash sh/instondocker.sh
	# pat
	# on browser localhost:${KCPORT}       		# for the keycload console
	# on browser localhost:${PATPORT}		# for the PAT 
start:
	docker start  patc &
exec:
	docker exec   patc bash /home/pat/src/pat/patServer/runme.sh &
meshinst:
	docker exec   patc bash /home/pat/src/sh/meshi.sh &
mesh:
	docker exec   patc bash /home/pat/src/sh/meshstart.sh &
net:
	docker network create --subnet=${SUBNET}/16 mynetpat
ssh:
	docker exec -it patc /bin/bash service ssh start
	sshpass -p docker  ssh pat@${CONTAINERIP} 
