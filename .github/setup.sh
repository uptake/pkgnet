#!/bin/bash

set -e

if [[ "${OS_NAME}" == "macos" ]]; then
    brew install \
        checkbashisms \
        qpdf
elif [[ "${OS_NAME}" == "linux" ]]; then
    sudo apt-get update
    sudo apt-get install \
        --no-install-recommends \
        -y \
        --allow-downgrades \
            libcurl4-openssl-dev \
            libfribidi-dev \
            libharfbuzz-dev \
            curl \
            devscripts \
            qpdf \
        || exit -1
fi

Rscript -e "
    options(install.packages.check.source = 'no');
    install.packages('remotes', repos = 'https://cran.r-project.org')
    remotes::install_deps(dependencies = TRUE)
"
