#!/bin/bash

set -e

for CHART in $(ls charts/stable); do
    echo "#####"
    echo "Chart: ${CHART}"
    VERSION=$(cat charts/stable/${CHART}/Chart.yaml | grep version: | cut -d' ' -f2 | tr -d [:cntrl:])
    echo "Version: ${VERSION}"

    set +e
    curl -I -f -s ${REPO_URL}/api/charts/${CHART}/${VERSION} &>/dev/null
    CHECK_VERSION=$?
    set -e

    if [ $CHECK_VERSION -ne 0 ]; then
        echo "Building and uploading chart ${CHART} version ${VERSION} to ${REPO_URL}."
        helm dependency update charts/stable/${CHART}/
        helm package charts/stable/${CHART}/
        curl --data-binary "@${CHART}-${VERSION}.tgz" ${REPO_URL}/api/charts -u ${USER}:${PASS}
        rm "${CHART}-${VERSION}.tgz"
    else
        echo "Chart ${CHART} version ${VERSION} already exists in ${REPO_URL}, skipping."
    fi
    echo "#####"
done
