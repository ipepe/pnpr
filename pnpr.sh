#!/bin/bash

if [ "x$1" = "xbuild" ] ; then
    if [ "x$2" = "x" ] ; then
        # za jakis czas pewnie tutaj dam github.com/ipepe/pnpr/raw/master/pnpr/Dockerfile
        docker build -t ipepe/pnpr ./pnpr
    else
        docker build -t ipepe/pnpr $2
    fi
else
    containerName=$1
    manageCommand=$2

    if [ "x$containerName" = "x" -o "x$manageCommand" = "x" ]; then
      echo "Usage: $0 <image name> <command>"
      echo "Example: $0 foosball start"
      exit 1
    fi

    imageName="ipepe/pnpr"
    extraArgs="--restart=unless-stopped -i -t -P -v /opt/docker/$containerName/data:/data"
    containerExists="x`docker ps -a -f name=${containerName} | grep -v CONTAINER`"

    if [ "$manageCommand" = "start" ] ; then
        if [ "x${containerExists}" = "x" ] ; then
            docker start ${containerName}
        else
            if [ "x$3" = "x" ] ; then
                echo pnpr also needs virtual_hosts information when starting container
            else
                docker run -d --name ${containerName} -h ${containerName} -e VIRTUAL_HOST=$3 ${extraArgs} ${imageName}
            fi
        fi
    fi

    if [ "$manageCommand" = "destroy" ] ; then
        docker rm $containerName
    fi
fi
