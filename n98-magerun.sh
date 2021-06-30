#!/bin/bash
#
# Helper - allows execution of n98-magerun2 on the currently deployed magento instance
#
# NOTE: Assumes that a current version of n98-magerun2 has been installed on the host
#
set -e

/home/webscalebuilder/pull-latest.sh

source /home/webscalebuilder/.env

docker run \
  --rm \
  -it \
  --net host \
  --mount type=bind,src=/opt/webscale/hosting/secrets/${WEBSERVER_NAME}/env.php,dst=/var/www/html/app/etc/env.php \
  --mount type=bind,src=/home/webscalebuilder/bin/n98-magerun2.phar,dst=/bin/n98magerun2.phar,readonly \
  ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${DEPLOY_TAG} \
  ${@:-sh}
