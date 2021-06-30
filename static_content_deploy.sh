#!/bin/bash

set -e

sudo /home/webscalebuilder/pull-latest.sh

source /home/webscalebuilder/.env

mkdir -p /opt/webscale/hosting/secrets/${WEBSERVER_NAME}/


base=/mnt/shared/${WEBSERVER_NAME}/pub/static/
tmpVersion=$(date +tmpVersion%Y%m%d%H%M%S)
tmpStaticDir=${base}${tmpVersion}
sudo -u www-data mkdir -p ${tmpStaticDir}
sudo chgrp www-data ${tmpStaticDir}
sudo chmod g+w ${tmpStaticDir}


# Build static content and copy it to NFS
docker run \
  --rm \
  --name staticcontentdeploy \
  --net host \
  --mount type=bind,src=/opt/webscale/hosting/secrets/${WEBSERVER_NAME}/env.php,dst=/var/www/html/app/etc/env.php \
  -v ${tmpStaticDir}:/var/www/html/pub/static \
  ${ECR_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${DEPLOY_TAG} \
  /bin/sh -c 'set -ex && ( \
    php bin/magento setup:static-content:deploy en_US en_GB -fj=16 \
    && php bin/magento cache:enable \
  )'

# Set the deployed_version.txt new static content directory
if [ -f ${tmpStaticDir}/deployed_version.txt ]; then
  realVersion="version$(cat ${tmpStaticDir}/deployed_version.txt)"
else
  echo "No new static version file found in new static directory (${tmpStaticDir})" >&2
  exit 1
fi

sudo -u www-data mv ${tmpStaticDir} ${base}${realVersion}
# Symlink the _cache directory for merged files
#sudo -u www-data mv ${base}_cache ${base}${realVersion}/_cache
# Magento also needs to know what the version is in order to run
sudo -u www-data cp ${base}${realVersion}/deployed_version.txt ${base}/deployed_version.txt

