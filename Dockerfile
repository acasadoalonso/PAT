FROM ubuntu:noble
USER root
VOLUME /home/pat/src/pat
# <<<<<<<<<<<<<<<<<  CHECK those values first >>>>>>>>>>
RUN export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
RUN export KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
ENV KCversion='25.0.2'
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo "KCversion:         "$KCversion  		>/tmp/docker.installation
RUN echo "========================================"  	>>/tmp/docker.installation
RUN echo
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
#ARG NODE_MAJOR=18
ARG NODE_MAJOR=20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN apt update && sudo apt install -y nodejs 
RUN npm install -g npm@10.9.0 
# change password root
RUN echo "root:docker"|chpasswd
ARG USER=pat
ARG UID=1001
ARG GID=1001
# default password for user
ARG PW=docker
# Option1: Using unencrypted password/ specifying password
#RUN useradd -m ${USER} --uid=${UID} --shell=/bin/bash && echo "${USER}:${PW}" |  chpasswd
RUN useradd -m ${USER} --uid ${UID}
RUN echo "pat:docker"|chpasswd
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
RUN mkdir -p         		/home/pat/src/keycloak
WORKDIR              		/home/pat/src/
RUN echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> /etc/environment
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
RUN wget https://github.com/keycloak/keycloak/releases/download/$KCversion/keycloak-$KCversion.tar.gz
RUN tar zxvf keycloak-$KCversion.tar.gz
RUN rm keycloak-$KCversion.tar.gz
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
WORKDIR /home/pat/src/keycloak-$KCversion/
# COPY configuration files
COPY keycloak/* /home/pat/src/keycloak-$KCversion/conf
#
# "Install gh ... we need it for authentification of a private github account"
#
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh -y

RUN mkdir -p         		/home/pat/src/sh
RUN mkdir -p         		/home/pat/src/pat
WORKDIR              		/home/pat/src/pat
# instondocker is the script to run after building the image
COPY instondocker.sh 		/home/pat/src/sh/instondocker.sh
COPY archive/mytoken.txt     	/home/pat/src/mytoken.txt    
COPY meshi.sh        		/home/pat/src/sh/meshi.sh    
COPY meshstart.sh        	/home/pat/src/sh/meshstart.sh    
COPY runpat.sh                  /home/pat/src/sh/runpat.sh
COPY runkc.sh                   /home/pat/src/sh/runkc.sh
RUN echo "(cd /usr/local/mesh_daemons/meshagent/ && ./meshagent --installedByUser=0)"                       >/home/pat/src/sh/meshstart.sh 
RUN alias pat='(cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'
RUN alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log  &)'
RUN alias startkc='(sudo ~/src/$KCversion/bin/kc.sh --verbose start-dev --http-host 172.19.0.2 --http-port 8081  --http-enabled true  &)'
RUN echo "alias pat='(cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log &)'"                           >>/home/pat/.bash_aliases
RUN echo "alias patrestart='(pkill node  && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log  &)'"    >>/home/pat/.bash_aliases
RUN echo "alias startkc='(sudo ~/src/*2/bin/kc.sh --verbose start-dev --http-host 172.19.0.2 --http-port 8081  --http-enabled true >>/tmp/kc.log &)'" >>/home/pat/.bash_aliases

RUN echo "export KEYCLOAK_ADMIN='admin'"                                                                  >>/home/pat/.profile
RUN echo "export KEYCLOAK_ADMIN_PASSWORD='admin'"                                                         >>/home/pat/.profile
RUN echo "neofetch      "                                                                                 >>/home/pat/.profile
RUN echo '(echo ;pgrep -a node;echo ;pgrep -a java;echo )'                                                >>/home/pat/.profile
RUN echo "echo '__________________________________________________________________________________'     " >>/home/pat/.profile
RUN echo "date      "                                                                                     >>/home/pat/.profile
RUN echo "export KCversion="$KCversion                                                                    >>/home/pat/.profile
RUN echo "export PATHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)"				      >>/home/pat/.profile
RUN echo "export KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)"				      >>/home/pat/.profile
RUN echo 'echo "Host IP addr:      "$PATHOST      '                                                       >>/home/pat/.profile
RUN echo 'echo "Keycloak IP addr:  "$KCHOST      '                                                        >>/home/pat/.profile
RUN echo 'echo "Keycloak Version:  "$KCversion      '                                                     >>/home/pat/.profile
RUN echo 'echo "User:              "$USER           '                                                     >>/home/pat/.profile
RUN echo 'echo "========================================"      '                                          >>/home/pat/.profile
RUN echo 'echo      '                                                                                     >>/home/pat/.profile

RUN chown pat:pat -R /home/pat
EXPOSE 80
EXPOSE 3000
EXPOSE 8081
EXPOSE 22
RUN echo "============================================================"
RUN touch PATinstallation.done	
RUN echo "============================================================"
STOPSIGNAL SIGTERM
ENV USER=pat
WORKDIR           /home/pat/src/
RUN service ssh restart
CMD /bin/bash  &&  /usr/bin/tail -f /dev/null


