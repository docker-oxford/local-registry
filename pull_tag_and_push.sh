#!/usr/bin/env sh
function usage() {
  echo "usage: $0 [registry fqdn] [images]"
}
[ "${1}" == "" ] && usage
REGISTRY="${1}"
# Define images
shift
HUB_IMAGES="${@}"
echo ${HUB_IMAGES}
# Pull all images from Docker Hub
echo ${HUB_IMAGES} | xargs -I% -n1 docker pull %
[ $? -ne 0 ] && echo "failed to fetch all images" && exit 1
# Tag all images with local private registry
echo ${HUB_IMAGES} | xargs -I% -n1 docker tag % ${REGISTRY}/%
[ $? -ne 0 ] && echo "failed to tag all images" && exit 1
# Push images to private registry
echo ${HUB_IMAGES} | xargs -I% -n1 docker push ${REGISTRY}/%
[ $? -ne 0 ] && echo "failed to push all images" && exit 1
echo "Done!" && exit 0
