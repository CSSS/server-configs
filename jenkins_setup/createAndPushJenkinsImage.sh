#!/bin/bash

IMAGENAME="csss_jenkins"
DOCKERFILE="Dockerfile"
DOCKERREGISTRY="sfucsssorg"
VERSION="0.0.1"
DOCKER_HUB_USER_NAME="sfucsss"

docker build -t ${IMAGENAME} \
            -f ${DOCKERFILE} .

cat password | docker login --username=${DOCKER_HUB_USER_NAME} --password-stdin

docker tag ${IMAGENAME} ${DOCKERREGISTRY}/${IMAGENAME}
docker tag ${IMAGENAME} ${DOCKERREGISTRY}/${IMAGENAME}:${VERSION}
docker push ${DOCKERREGISTRY}/${IMAGENAME}
docker push ${DOCKERREGISTRY}/${IMAGENAME}:${VERSION}
