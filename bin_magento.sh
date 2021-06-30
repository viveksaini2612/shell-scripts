#!/bin/bash
#
# Allows Users to execute arbitrary bin/magento commands in a container that is based
# on the currently deployed docker image
#
set -e

/home/webscalebuilder/pull-latest.sh

source /home/webscalebuilder/.env

docker run \
  --rm \
  --net host \
  --mount type=bind,src=/opt/webscale/hosting/secrets/${WEBSERVER_NAME}/env.php,dst=/var/www/html/app/etc/env.php \
  ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${DEPLOY_TAG} \
  php -d memory_limit=-1 bin/magento $@
