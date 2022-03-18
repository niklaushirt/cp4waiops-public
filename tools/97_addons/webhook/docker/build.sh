#!/bin/bash

export CONT_VERSION=2.3

# Create the Image
docker buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-event-gateway:$CONT_VERSION --load .
docker push niklaushirt/cp4waiops-event-gateway:$CONT_VERSION

# Run the Image
docker run -p 8080:8080 -e KAFKA_TOPIC=$KAFKA_TOPIC -e KAFKA_USER=$KAFKA_USER -e KAFKA_PWD=$KAFKA_PWD -e KAFKA_BROKER=$KAFKA_BROKER -e CERT_ELEMENT=$CERT_ELEMENT niklaushirt/cp4waiops-event-gateway:$CONT_VERSION

# Deploy the Image
oc apply -n default -f create-cp4mcm-event-gateway.yaml





exit 1

