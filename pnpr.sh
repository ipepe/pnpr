#!/bin/bash
imageName="ipepe/pnpr:v4"
letsencryptEmail=""

if [ "x${letsencryptEmail}" = "x" ] ; then
    echo "Please insert email into file pnpr.sh"
else
    if [ "x$1" = "xbuild" ] ; then
        if [ "x$2" = "x" ] ; then
            # za jakis czas pewnie tutaj dam github.com/ipepe/pnpr/raw/master/pnpr/Dockerfile
            docker build -t ${imageName} ./src
        else
            docker build -t ${imageName} $2
        fi
    else
        containerName=$1
        manageCommand=$2

        if [ "x$containerName" = "x" -o "x$manageCommand" = "x" ]; then
          echo "Usage: $0 <container name> <command>"
          echo "Example: $0 foosball start"
          exit 1
        fi

        extraArgs="--restart=unless-stopped -i -t -P -v /opt/docker/$containerName/data:/data"
        containerExists="x`docker ps -a -f name=${containerName} | grep -v CONTAINER`"

        if [ "$manageCommand" = "start" ] ; then
            if [ "${containerExists}" = "x" ] ; then
                if [ "x$3" = "x" ] ; then
                    echo pnpr also needs virtual_hosts information when starting container
                else
                    docker run -d --name ${containerName} -h ${containerName} -e VIRTUAL_HOST=$3 -e LETSENCRYPT_HOST=$3 -e LETSENCRYPT_EMAIL=${letsencryptEmail} ${extraArgs} ${imageName}
                    echo docker run -d --name ${containerName} -h ${containerName} -e VIRTUAL_HOST=$3 -e LETSENCRYPT_HOST=$3 -e LETSENCRYPT_EMAIL=${letsencryptEmail} ${extraArgs} ${imageName}
                fi
            else
                docker start ${containerName}
                echo docker start ${containerName}
            fi
        elif [ "$manageCommand" = "destroy" ] ; then
            docker stop $containerName
            docker rm $containerName
        elif [ "$manageCommand" = "stop" ] ; then
            docker stop $containerName
        elif [ "$manageCommand" = "console" ] ; then
            docker exec -i -t $containerName bash
        else
            echo Unknown command $manageCommand
        fi
    fi
fi
