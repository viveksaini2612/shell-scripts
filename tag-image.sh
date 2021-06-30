#!/bin/bash

set -ex

source /home/webscalebuilder/.env

mkdir -p /opt/webscale/hosting/secrets/${WEBSERVER_NAME}/
source /home/webscalebuilder/.env

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}
MANIFEST=$(aws ecr --region ${REGION} batch-get-image --registry-id ${ECR_ACCOUNT_ID} --repository-name ${ECR_REPO_NAME} --image-ids imageTag=${1:-master} --query 'images[].imageManifest' --output text)
aws ecr --region ${REGION} put-image --registry-id ${ECR_ACCOUNT_ID} --repository-name ${ECR_REPO_NAME} --image-tag ${DEPLOY_TAG} --image-manifest "$MANIFEST"

