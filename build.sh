#!/usr/bin/env bash
set -o errexit
set -o xtrace
 
# Ensure build is performed inside a container
if ! grep -c docker /proc/1/cgroup > /dev/null; then
    image_tag="$(basename $PWD | sed 's/_/-/g' | cut -c 1-40 | tr '[:upper:]' '[:lower:]'):$(git rev-parse --short HEAD)"
    docker build --build-arg BUILD_UID=$(id -u) --build-arg BUILD_GID=$(id -g) --tag local/$image_tag .
    docker run --rm -v $PWD:/home/builduser/workdir local/$image_tag $0 $*
    exit $?
fi
 
if [ -v BUILD_NUMBER ]; then
    # Use CI build number and mark package as released
    sed -i "1 s/.[0-9]*)/.${BUILD_NUMBER})/g" debian/changelog
    dch --maintmaint "Build $(git describe --tags) ${BUILD_URL}"
    dch --maintmaint --release ""
else
    # Increment the last version field so each build is unique
    dch --maintmaint --local '.' "Build $(git describe --tags)"
fi
 
debuild -us -uc -b -tc --lintian-opts --profile debian
 
mkdir -p output
cp --preserve=all -v ../* output || true

