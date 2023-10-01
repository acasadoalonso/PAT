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
	mkdir -p  ./proxdata
	chmod 775 ./proxdata
	- docker ps -a
	- docker stop patc
	- docker rm patc
	docker  run -ti --net mynetpat --ip 172.19.0.2 -p 3003:3000 --restart unless-stopped --name patc --hostname PATdock -v ./proxdata:/home/pat/src/pat pat 
	- docker ps -a
ssh:
	docker exec -it patc /bin/bash service ssh start
	sshpass -p docker  ssh pat@172.19.0.2 
attach:
	docker attach patc
net:
	docker network create --subnet=172.19.0.0/16 mynetpat

