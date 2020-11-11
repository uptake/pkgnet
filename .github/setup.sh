#!/bin/bash

set -e

if [[ "${OS_NAME}" == "macos" ]]; then
    brew install \
        checkbashisms \
        qpdf
    brew cask install basictex
    export PATH="/Library/TeX/texbin:$PATH"
    sudo tlmgr --verify-repo=none update --self
    sudo tlmgr --verify-repo=none install inconsolata helvetic
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
        || exit -1
            # texinfo \
            # texlive-latex-recommended \
            # texlive-fonts-recommended \
            # texlive-fonts-extra \
            # qpdf \
fi

Rscript -e "
    options(install.packages.check.source = 'no');
    install.packages('remotes', repos = 'https://cran.r-project.org')
    remotes::install_deps(dependencies = TRUE)
"
