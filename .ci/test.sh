#!/bin/bash

set -e

export _R_CHECK_CRAN_INCOMING_=false

packages="
  c('assertthat', 'covr', 'data.table', 'DT', 'futile.logger', 'ggplot2',
    'glue', 'igraph', 'knitr', 'magrittr', 'methods', 'pkgdown', 'R6', 'roxygen2',
    'rlang', 'rmarkdown', 'testthat', 'tools', 'visNetwork', 'webshot', 'withr')
    "

if [[ "${OS_NAME}" == "macos" ]]; then
    brew install \
        checkbashisms \
        qpdf
    brew cask install basictex
    export PATH="/Library/TeX/texbin:$PATH"
    sudo tlmgr --verify-repo=none update --self
    sudo tlmgr --verify-repo=none install inconsolata helvetic
    Rscript -e "
      options(install.packages.check.source = 'no');
      install.packages(${packages}, type = 'binary', repos = 'https://cran.r-project.org')
    "
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
            texinfo \
            texlive-latex-recommended \
            texlive-fonts-recommended \
            texlive-fonts-extra \
            qpdf \
        || exit -1
    Rscript -e "install.packages(${packages}, repos = 'https://cran.r-project.org')"
fi

R CMD build .
R CMD check --as-cran *.tar.gz

LOG_FILE_NAME="pkgnet.Rcheck/00check.log"

if grep -q -R "WARNING" "$LOG_FILE_NAME"; then
    echo "WARNINGS have been found by R CMD check!"
    exit 1
fi

ALLOWED_CHECK_NOTES=0
NUM_CHECK_NOTES=$(
    cat ${LOG_FILE_NAME} \
        | grep -e '^Status: .* NOTE.*' \
        | sed 's/[^0-9]*//g'
)
if [[ ${NUM_CHECK_NOTES} -gt ${ALLOWED_CHECK_NOTES} ]]; then
    echo "Found ${NUM_CHECK_NOTES} NOTEs from R CMD check. Only ${ALLOWED_CHECK_NOTES} are allowed"
    exit 1
fi
