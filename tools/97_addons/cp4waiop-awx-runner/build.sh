#!/bin/bash

export CONT_VERSION=0.1.3

docker buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-awx:$CONT_VERSION --load -f Dockerfile.awx .
docker push niklaushirt/cp4waiops-awx:$CONT_VERSION


