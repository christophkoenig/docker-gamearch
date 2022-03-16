#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
VERSION="0.8.5"
IMAGE_NAME="quay.io/ckoenig/gamearch"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
REPO="https://github.com/christophkoenig/GameArch.git"
BRANCH="update-env-settings"

echo -e "\nBuilding image...\n"
docker build -t $IMAGE_NAME:$VERSION \
    --build-arg REPO=$REPO \
    --build-arg BRANCH=$BRANCH \
    --build-arg BUILD_DATE=$BUILD_DATE \
    --build-arg VERSION=$VERSION \
    $SCRIPT_DIR

echo -e "\ndone\n"