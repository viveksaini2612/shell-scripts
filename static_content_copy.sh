#!/bin/bash

set -ex

cleanup() {
  #remove docker container
  docker rm staticcontentcopy || true
  rm -rf ${tmpStaticDir} || true
}

trap cleanup EXIT

sudo /home/webscalebuilder/pull-latest.sh

source /home/webscalebuilder/.env

base=/mnt/shared/${WEBSERVER_NAME}/pub/static
tmpVersion=$(date +tmpVersion%Y%m%d%H%M%S)
tmpStaticDir=${base}/${tmpVersion}
sudo -u www-data mkdir -p ${tmpStaticDir}
sudo chgrp www-data ${tmpStaticDir}
sudo chmod g+w ${tmpStaticDir}

# creating container filesystem to pull static files from
echo "creating container filesystem to pull static files from"
docker create \
  --name staticcontentcopy \
  --net host \
  ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${DEPLOY_TAG} \
  /bin/sh

# copy files from docker image to NFS share
docker cp staticcontentcopy:/var/www/html/pub/static/. ${tmpStaticDir}

realVersion=version$(cat ${tmpStaticDir}/deployed_version.txt)
sudo -u www-data mv ${tmpStaticDir} ${base}/${realVersion}
sudo -u www-data cp ${base}/${realVersion}/deployed_version.txt ${base}/deployed_version.txt

