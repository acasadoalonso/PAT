# pat

This repo contains the information of how to install the PROXIMITY ANALYSIS TOOL (PAT) on a VM or docker container or LXC container
>
>Runtime production at:  http://patigc.fai.org:3000
>

## To install on docker container:

>bash instasdock.sh


## To install on a VM machine or a LXC container:
>bash instonVM.sh
>
>Update first the environment variables:  **PATHOST & KCHOST** with the appropriate IP addr.
>
>**PATHOST** is the IP addr of the machine where the PAT will be installed
>
>**KCHOST** is the IP addr of the machine where the Keycloak is installed, and where the PAT will connect to get the data from the cluster.>
>

## Further documentation on:

>
>read the notes on directory test/TESTING.md to know how to test the installation and how to use the PAT.
>
