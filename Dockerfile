FROM ubuntu:jammy
USER root
VOLUME /home/pat/src/pat
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update 
RUN apt-get -y upgrade 
# Set the locale
#RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 
RUN apt-get -y install locales
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8
RUN export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8	
RUN apt-get install -y wget systemd git libarchive-dev  vim inetutils-ping figlet ntpdate ssh sudo openssh-server 				
RUN apt-get install -y gh gcc g++ make curl neofetch iproute2 ca-certificates gnupg libfmt-dev
RUN apt-get install -y openjdk-17-jre-headless openjdk-17-jdk-headless
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ARG NODE_MAJOR=18
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN apt update && sudo apt install -y nodejs 
RUN npm install -g npm@10.1.0 
# change password root
RUN echo "root:docker"|chpasswd
ARG USER=pat
ARG UID=1000
ARG GID=1000
# default password for user
ARG PW=docker
# Option1: Using unencrypted password/ specifying password
RUN useradd -m ${USER} --uid=${UID} --shell=/bin/bash && echo "${USER}:${PW}" |  chpasswd
RUN adduser pat sudo 
RUN adduser pat adm 
RUN echo 'alias ll="ls -la"' >> ~/.bashrc
RUN echo "*** Welcome to the PAT application container ***" > /etc/motd  && cp -a /root /root.orig
# Clean up APT when done.
RUN apt-get autoremove -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/* 
#USER pat
RUN git config --global user.email "acasadoalonso@gmail.com" 
RUN git config --global user.name  "Angel Casado"     
RUN mkdir -p         		/home/pat/src

# install keycloak and deps for authentication
RUN mkdir -p         		/home/pat/keycloak
RUN echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> /etc/environment
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
RUN wget https://github.com/keycloak/keycloak/releases/download/24.0.1/keycloak-24.0.1.tar.gz
RUN tar zxvf keycloak-24.0.1.tar.gz
RUN rm keycloak-24.0.1.tar.gz
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=KYC_PASS
WORKDIR /home/pat/src/keycloak-24.0.1/
# COPY keycloak/keycloak.conf /home/pat/src/keycloak-24.0.1/conf
RUN ./bin/kc.sh --verbose build
# COPY keycloak/keycloak.service /etc/systemd/system/
# need to run it with ./binkc.sh --verbose start or start-dev

RUN mkdir -p         		/home/pat/src/sh
RUN mkdir -p         		/home/pat/src/pat
WORKDIR              		/home/pat/src/pat
COPY instondocker.sh 		/home/pat/src/sh/instondocker.sh
COPY archive/mytoken.txt     	/home/pat/src/mytoken.txt    
COPY meshi.sh        		/home/pat/src/sh/meshi.sh    
RUN echo "(cd /home/pat/src/pat/patServer && bash runme.sh &)"                                              >/home/pat/src/runpat.sh
RUN echo "(cd /usr/local/mesh_daemons/meshagent/ && ./meshagent --installedByUser=0)"                       >/home/pat/src/sh/meshstart.sh 
RUN alias pat='(cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'
RUN alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log  &)'
run echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'"                           >>/home/pat/.bash_aliases
run echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log  &)'"    >>/home/pat/.bash_aliases

RUN chown pat:pat -R /home/pat
EXPOSE 80
EXPOSE 3000
EXPOSE 22
RUN touch PATinstallation.done	
STOPSIGNAL SIGTERM
ENV USER=pat
WORKDIR           /home/pat/src/
RUN service ssh restart
CMD /bin/bash  &&  /usr/bin/tail -f /dev/null


