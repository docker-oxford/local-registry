#!/usr/bin/env sh
function usage() {
  echo "usage: $0 [registry fqdn]"
}
[ "${1}" == "" ] && usage
# Define images
HUB_IMAGES="redis python:2.7 node:0.10 java:7 postgres:9.4"
# Pull all images from Docker Hub
echo ${HUB_IMAGES} | xargs  -I% -n1 docker pull %
[ $? -ne 0 ] && echo "failed to fetch all images" && exit 1
# Tag all images with local private registry
echo ${HUB_IMAGES} | xargs -I% -n1 docker tag -f % ${1}/library/%
[ $? -ne 0 ] && echo "failed to tag all images" && exit 1
# Push images to private registry
echo ${HUB_IMAGES} | xargs -I% -n1 docker push ${1}/library/%
[ $? -ne 0 ] && echo "failed to push all images" && exit 1
echo "Done!" && exit 0
