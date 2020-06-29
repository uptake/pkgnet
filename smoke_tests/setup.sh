#!/bin/bash

# set up R environment
CRAN_MIRROR="https://cloud.r-project.org/"
R_LIB_PATH=~/Rlib
mkdir -p $R_LIB_PATH
echo "R_LIBS=$R_LIB_PATH" > ${HOME}/.Renviron
export PATH="$R_LIB_PATH/R/bin:$PATH"

export R_LINUX_VERSION="4.0.0-1.1804.0"
export R_APT_REPO="bionic-cran40/"

# installing precompiled R for Ubuntu
# https://cran.r-project.org/bin/linux/ubuntu/#installation
# adding steps from https://stackoverflow.com/a/56378217/3986677 to get latest version
sudo apt-key adv \
    --keyserver keyserver.ubuntu.com \
    --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository \
    "deb https://cloud.r-project.org/bin/linux/ubuntu ${R_APT_REPO}"
sudo apt-get update
sudo apt-get install \
    --no-install-recommends \
    -y \
        libcurl-dev \
        pandoc \
        r-base-dev=${R_LINUX_VERSION} \
        texinfo \
        texlive-latex-recommended \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        qpdf \
        || exit -1

# Manually install Depends and Imports libraries + 'testthat'
# to avoid a CI-time dependency on devtools (for devtools::install_deps())
packages="c('assertthat', 'covr', 'data.table', 'DT', 'futile.logger', 'glue', 'igraph', 'knitr', 'magrittr', 'R6', 'rlang', 'rmarkdown', 'visNetwork')"
Rscript --vanilla -e "install.packages(${packages}, repos = '${CRAN_MIRROR}', lib = '${R_LIB_PATH}', dependencies = c('Depends', 'Imports', 'LinkingTo'))" || exit -1
