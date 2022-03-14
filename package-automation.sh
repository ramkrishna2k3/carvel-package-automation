#!/bin/bash
set -e 
APP_NAME=$1
VERSION=$2
GITHUB_LOGIN=$3
echo "${APP_NAME} ${VERSION} ${GITHUB_LOGIN}"
rm -rf package-contents/config/
rm -rf my-pkg-repo

mkdir -p package-contents/config/
cp ./config/* package-contents/config/
mkdir -p package-contents/.imgpkg
kbld -f package-contents/config/ --imgpkg-lock-output package-contents/.imgpkg/images.yml
export REPO_HOST=ghcr.io/${GITHUB_LOGIN}
imgpkg push -b ${REPO_HOST}/packages/${APP_NAME}:${VERSION} -f package-contents

ytt -f package-contents/config/values.yml --data-values-schema-inspect -o openapi-v3 > schema-openapi.yml

cp -f package-template-template.yml package-template.yml
# For APP_NAME convert first later to capitol ex: Apache
sed -i "s/APP_NAME Carvel package/${APP_NAME^} Carvel package/g" package-template.yml
sed -i "s/APP_NAME/${APP_NAME}/g" package-template.yml

sed -i "s/GITHUB_LOGIN/${GITHUB_LOGIN}/g" package-template.yml

mkdir -p my-pkg-repo/.imgpkg my-pkg-repo/packages/${APP_NAME}.bitnami.vmware.com

ytt -f package-template.yml  --data-value-file openapi=schema-openapi.yml -v version="${VERSION}" > my-pkg-repo/packages/${APP_NAME}.bitnami.vmware.com/${VERSION}.yml

cp -f metadata-template.yml my-pkg-repo/packages/${APP_NAME}.bitnami.vmware.com/metadata.yml
# For APP_NAME convert first later to capitol ex: Apache
sed -i "s/APP_NAME app/${APP_NAME^} app/g" my-pkg-repo/packages/${APP_NAME}.bitnami.vmware.com/metadata.yml
sed -i "s/APP_NAME/${APP_NAME}/g" my-pkg-repo/packages/${APP_NAME}.bitnami.vmware.com/metadata.yml

kbld -f my-pkg-repo/packages/ --imgpkg-lock-output my-pkg-repo/.imgpkg/images.yml

imgpkg push -b ${REPO_HOST}/packages/my-${APP_NAME}-repo:${VERSION} -f my-pkg-repo
