#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
VERSION="1.0.1"
IMAGE_NAME="quay.io/ckoenig/gamearch"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
REPO="https://github.com/Cryptec/GameArch.git"
BRANCH="main"

echo -e "\nBuilding image...\n"
docker build -t $IMAGE_NAME:$VERSION \
    --build-arg REPO=$REPO \
    --build-arg BRANCH=$BRANCH \
    --build-arg BUILD_DATE=$BUILD_DATE \
    --build-arg VERSION=$VERSION \
    $SCRIPT_DIR

echo -e "\nSetting 'latest' image tag...\n"
docker image tag $IMAGE_NAME:$VERSION $IMAGE_NAME:latest

echo -e "\ndone\n"
