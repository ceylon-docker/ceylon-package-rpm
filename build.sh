#!/bin/bash

set -e

if [[ -f /output/.novolume ]]; then
    echo "Missing -v /your/output/path:/output argument to docker"
    exit
fi

if [[ $# -eq 0 ]]; then
    SEARCH_VERSION="*"
else
    SEARCH_VERSION=$1
fi

ZIPS=( $(find /output -maxdepth 1 -type f -name "ceylon-${SEARCH_VERSION}.zip" -printf '%f\n') )
if [[ ${#ZIPS[@]} -eq 0 ]]; then
    echo "No Ceylon source zip file found"
    exit
elif [[ ${#ZIPS[@]} -ne 1 ]]; then
    echo "Multiple Ceylon source zip files found, please specify version argument"
    exit
else
    CEYLON_VERSION=$(echo ${ZIPS[0]} | sed -r 's/ceylon-(.*).zip/\1/')
fi

wget https://github.com/ceylon/ceylon-rpm-repo/archive/${CEYLON_VERSION}.zip
unzip ${CEYLON_VERSION}.zip
ln -s /home/ceylon/ceylon-rpm-repo-${CEYLON_VERSION}/dist-pkg/ceylon.spec /home/ceylon/rpmbuild/SPECS/
ln -s /output/ceylon-${CEYLON_VERSION}.zip /home/ceylon/rpmbuild/SOURCES/
rpmbuild -ba --clean /home/ceylon/rpmbuild/SPECS/ceylon.spec
sudo cp -a /home/ceylon/rpmbuild/RPMS/noarch/ceylon-*.rpm /output
sudo cp -a /home/ceylon/rpmbuild/SRPMS/ceylon-*.rpm /output

