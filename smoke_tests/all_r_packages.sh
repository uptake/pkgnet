#!/bin/bash

# [description]
#     Run pkgnet report on every R package installed
#     on a system
# [usage]
#     ./smoke_tests/all_r_packages.sh | tee out.log  | cat

# failure is a natural part of life
set -e

OUT_DIR=${1:-$(pwd)/smoke_tests/test_data}

# Set up summary file and be sure it's blank
SUCCESS_FILE=${OUT_DIR}/successful_r_packages.txt
FAILURE_FILE=${OUT_DIR}/failed_r_packages.txt
echo "" > ${SUMMARY_FILE}
echo "" > ${FAILURE_FILE}

R_LIB=$(
    Rscript -e "cat(.libPaths()[1])"
)
ALL_R_PACKAGES=$(ls ${R_LIB})
NUM_PACKAGES=$(echo ${ALL_R_PACKAGES} | wc -w)

msg="You have ${NUM_PACKAGES} R packages installed."
echo ${msg}

# Randomly select packages and start working through them
RANDOM_PACKAGES=$(
    echo $ALL_R_PACKAGES | tr ' ' "\n" | sort --sort=random
)

# Don't open each individual .html in the browser
export PKGNET_SUPPRESS_BROWSER=0

for pkg in ${RANDOM_PACKAGES}; do
    echo "Running pkgnet on package: ${pkg}"

    report_path="${OUT_DIR}/${pkg}.html"
    Rscript -e "pkgnet::CreatePackageReport(pkg_name='${pkg}', report_path='${report_path}')"

    # a lot of code in CreatePackageReport() is try-catched, so
    # doing this to check for issues in the logs of the reports
    errors_found=$(cat ${report_path} | grep 'Error in' | wc -l)

    # the error message like
    # "Package 'svGUI' does not have any dependencies in" is known
    # and expected behavior, so we can ignore it
    allowed_errors=$(cat ${report_path} | grep 'does not have any dependencies in ' | wc -l)

    if ! (( ${errors_found} - ${allowed_errors} == 0 )); then
        echo "found errors for package '${pkg}'"
        echo ${pkg} >> ${FAILURE_FILE}
    else
        echo ${pkg} >> ${SUCCESS_FILE}
    fi
done

echo ""
echo "===== RESULTS ====="
echo "successes: $(cat ${SUCCESS_FILE} | wc -l)"
echo "failures: $(cat ${FAILURE_FILE} | wc -l)"
