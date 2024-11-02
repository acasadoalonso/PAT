# pat

This repo contains the information of how to install the PROXIMITY ANALYSIS OOL (PAT) on a VM or docker container ot LXC container

## To install on docker container:
>make build
>
>make run
>
>now on the docker container:
>
>su pat
>
>bash sh/instondocker.sh
>
>bash sh/runkc.sh
>
>bash sh/runpat.sh
>
>to run the keycloak console:   on a browser:  172.19.0.2:8081
>
>to run the PAT                 on a browser:  172.19.0.2:3000
>



## To install on a VM machine or a LXC container:
>bash instonVM.sh
>
>Update first the environment variables:  **PATHOST & KCHOST** with the appropriate IP addr.
>
