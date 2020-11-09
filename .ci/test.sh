#!/bin/bash

set -e

export _R_CHECK_CRAN_INCOMING_=false

packages="
  c('assertthat', 'covr', 'data.table', 'DT', 'futile.logger', 'ggplot2',
    'glue', 'igraph', 'knitr', 'magrittr', 'methods', 'R6', 'roxygen2',
    'rlang', 'rmarkdown', 'testthat', tools', 'visNetwork', 'webshot', 'withr')
    "

if [[ "${OS_NAME}" == "macos" ]]; then
    # brew install llvm
    # export PATH="/usr/local/opt/llvm/bin:$PATH"
    # export LDFLAGS="-L/usr/local/opt/llvm/lib"
    # export CFLAGS="-I/usr/local/opt/llvm/include"
    Rscript -e "
      options(install.packages.check.source = 'no');
      install.packages(${packages}, type = 'binary', repos = 'http://cran.rstudio.org')
    "
elif [[ "${OS_NAME}" == "linux" ]]; then
    Rscript -e "install.packages(${packages}, repos = 'http://cran.rstudio.org')"
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
