#!/bin/bash

cd /home/devjava/git/Omnimed-solutions/omnimed-docker-postgresql-init/

# Pull de l'image de base
docker pull artifacts.omnimed.com/docker/busybox:1.32.0

docker tag artifacts.omnimed.com/docker/busybox:1.32.0 localhost:32000/busybox:1.32.0

# Build
docker build --build-arg DOCKER_REPOSITORY_URL=localhost:32000 --build-arg DD_GIT_REPOSITORY_URL=`git config --get remote.upstream.url` --build-arg DD_GIT_COMMIT_SHA=`git rev-parse HEAD` . -t localhost:32000/omnimed-docker-postgresql-init:0.0.0
docker push localhost:32000/omnimed-docker-postgresql-init:0.0.0

# Push au registry
docker push localhost:32000/omnimed-docker-postgresql-init:0.0.0


