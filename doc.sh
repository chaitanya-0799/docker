#! /bin/bash

docker ps -aq | xargs docker stop
docker ps -aq | xargs docker rm
docker images -q | xargs docker rmi

