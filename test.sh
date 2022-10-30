#!/bin/bash

set -e pipefail

rm -f *.tar.gz
R CMD build .

# Work outside of the source directory to avoid false
# positives (i.e. test the tarball in isolation)
mkdir -p ~/pkgnet_test_dir
cp *.tar.gz ~/pkgnet_test_dir

export _R_CHECK_CRAN_INCOMING_=false
pushd ~/pkgnet_test_dir
    R CMD check *.tar.gz --as-cran || true

    LOG_FILE_NAME="pkgnet.Rcheck/00check.log"

    echo ""
    echo "----- R CMD check logs -----"
    echo ""
    cat pkgnet.Rcheck/00check.log

    echo ""
    echo "----- test outputs -----"
    echo ""
    cat pkgnet.Rcheck/tests/testthat.Rout

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

popd || exit 0
