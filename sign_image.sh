#!/bin/sh

IMAGE_NAME="${1}"
PRIVATE_KEY="${2}"
KEY_PASSWORD="${3}"

KEYDIR=$(pwd)/sign.tmp
mkdir -p ${KEYDIR}
chmod 0777 ${KEYDIR}
rm -f ${KEYDIR}/cosign.key ${KEYDIR}/cosign.pub
cp ${HOME}/.docker/config.json ${KEYDIR}
echo "${PRIVATE_KEY}" > ${KEYDIR}/cosign.key
chmod 0444 ${KEYDIR}/config.json ${KEYDIR}/cosign.key

docker pull ${IMAGE_NAME}
IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ${IMAGE_NAME})
docker run --rm -e "COSIGN_PASSWORD=${KEY_PASSWORD}" -v ${KEYDIR}/cosign.key:/cosign.key \
  -v ${KEYDIR}/config.json:/.docker/config.json bitnami/cosign:latest sign --key /cosign.key \
  --tlog-upload --upload -y ${IMAGE_DIGEST}

rm -rf ${KEYDIR}
