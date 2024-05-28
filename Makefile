#!make

IMAGE_NAME := pat
FULL_VERSION := 0.1.0
MINOR_VERSION := 0.1
MAJOR_VERSION := 0

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
cleanbu:
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
	- docker network create --subnet=172.19.0.0/16 mynetpat
	docker  run -ti --net mynetpat --ip 172.19.0.2 -p 3003:3000 -p 8082:8081 --restart unless-stopped --name patc --hostname PATdock -v ./dockerdata:/home/pat/src/pat pat 
	- docker ps -a
attach:
	docker attach patc
	# after attach
	# su pat
	# bash sh/instondocker.sh
	# pat
	# on browser localhost:8082       	# for the keycload console
	# on browser localhost:3003		# for the PAT 
start:
	docker start  patc &
exec:
	docker exec   patc bash /home/pat/src/pat/patServer/runme.sh &
mesh:
	docker exec   patc bash /home/pat/src/sh/meshstart.sh &
net:
	docker network create --subnet=172.19.0.0/16 mynetpat
ssh:
	docker exec -it patc /bin/bash service ssh start
	sshpass -p docker  ssh pat@172.19.0.2 
