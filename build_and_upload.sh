#!/bin/sh

set -e

for CHART in $(ls charts); do
    echo "#####"
    echo "Chart: ${CHART}"
    VERSION=$(cat charts/${CHART}/Chart.yaml | grep version: | cut -d' ' -f2)
    echo "Version: ${VERSION}"

    set +e
    curl -I -f -s ${REPO_URL}/api/charts/${CHART}/${VERSION} &>/dev/null
    CHECK_VERSION=$?
    set -e

    if [ $CHECK_VERSION -ne 0 ]; then
        echo "Building and uploading chart ${CHART} version ${VERSION} to ${REPO_URL}."
        helm dependency update charts/${CHART}/
        helm package charts/${CHART}/
        echo curl --data-binary "@${CHART}-${VERSION}.tgz" ${REPO_URL}/api/charts -u ${USER}:${PASS}
    else
        echo "Chart ${CHART} version ${VERSION} already exists in ${REPO_URL}, skipping."
    fi
    echo "#####"
done
