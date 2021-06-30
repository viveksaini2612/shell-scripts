#!/bin/bash

set -ex

source /home/webscalebuilder/.env

mkdir -p /opt/webscale/hosting/secrets/${WEBSERVER_NAME}/
source /home/webscalebuilder/.env
aws s3 cp s3://${CUSTOMER}-${ENVIRONMENT}-secrets/${WEBSERVER_NAME}/env.php /opt/webscale/hosting/secrets/${WEBSERVER_NAME}/env.php
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}
docker pull ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${DEPLOY_TAG}
chown 33 /opt/webscale/hosting/secrets/${WEBSERVER_NAME}/env.php

