#!/bin/bash

set -e

sudo /home/webscalebuilder/pull-latest.sh

source /home/webscalebuilder/.env

docker run \
  --rm \
  --name cacheclear \
  --net host \
  --mount type=bind,src=/opt/webscale/hosting/secrets/${WEBSERVER_NAME}/env.php,dst=/var/www/html/app/etc/env.php \
  ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${DEPLOY_TAG} \
  php bin/magento c:f

