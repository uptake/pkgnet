#!/bin/bash

# [description]
#     Run pkgnet report on every R package installed
#     on a system
# [usage]
#     ./smoke_tests/test.sh $(pwd)/smoke_tests/test_data 4

# failure is a natural part of life
set -e

OUT_DIR=${1:-$(pwd)/smoke_tests/test_data}
NUM_PARALLEL=${2:-2}

# Set up summary file and be sure it's blank
STATUS_FILE=${OUT_DIR}/package_run_status.txt
echo "" > ${STATUS_FILE}

R_LIB=$(
    Rscript -e "cat(.libPaths()[1])"
)
ALL_R_PACKAGES=$(ls ${R_LIB})
NUM_PACKAGES=$(echo ${ALL_R_PACKAGES} | wc -w)

msg="You have ${NUM_PACKAGES} R packages installed."
echo ${msg}

# Randomly select packages then write that
# randomly-ordered list to a file
PKG_LIST_FILE=${OUT_DIR}/pkgs.txt
echo $ALL_R_PACKAGES \
    | tr ' ' "\n" \
    | sort --sort=random \
    > ${PKG_LIST_FILE}

# parallelization details
CHUNK_DIR=${OUT_DIR}/chunks
LINES_PER_CHUNK=$(((${NUM_PACKAGES}+1) / ${NUM_PARALLEL}))
echo "Running smoke tests with ${NUM_PARALLEL} sub-processes"
echo "parallel details:"
echo "    chunk_dir: ${CHUNK_DIR}"
echo "    lines per chunk: ${LINES_PER_CHUNK}"

# split up packages into multiple pieces
mkdir -p ${CHUNK_DIR}
split \
    -l ${LINES_PER_CHUNK} \
    ${PKG_LIST_FILE} \
    ${CHUNK_DIR}/pkg.chunk.

# Don't open each individual .html in the browser
export PKGNET_SUPPRESS_BROWSER=0

run_pkgnet_report(){
    local chunk_file=${1}
    for pkg in $(cat ${chunk_file}); do
        local report_path="${OUT_DIR}/${pkg}.html"
        Rscript \
            -e "pkgnet::CreatePackageReport(pkg_name='${pkg}', report_path='${report_path}')" \
            > /dev/null \
        || \
            echo "Error in package '${pkg}': failed to even create report" > ${report_path}

        # a lot of code in CreatePackageReport() is try-catched, so
        # doing this to check for issues in the logs of the reports
        local errors_found=$(
            cat ${report_path} \
            | grep 'Error in' \
            | wc -l
        )

        # the error message like
        # "Package 'svGUI' does not have any dependencies in" is known
        # and expected behavior, so we can ignore it
        local allowed_errors=$(
            cat ${report_path} \
            | grep 'does not have any dependencies in ' \
            | wc -l
        )

        if ! (( ${errors_found} - ${allowed_errors} == 0 )); then
            local msg="FAILURE: ${pkg}"
        else
            local msg="SUCCESS: ${pkg}"
        fi
        echo ${msg} >> ${STATUS_FILE}
    done
}

for chunk_file in $(ls ${CHUNK_DIR}); do
    run_pkgnet_report ${CHUNK_DIR}/${chunk_file} &
done
wait

# sort all the failures to the top of the status file
tmp_file=${OUT_DIR}/blegh.txt
cat ${STATUS_FILE} \
    | sort \
    > ${tmp_file}
mv ${tmp_file} ${STATUS_FILE}

echo ""
echo "===== RESULTS ====="
echo "successes: $(cat ${STATUS_FILE} | grep 'SUCCESS' | wc -l)"
echo "failures: $(cat ${STATUS_FILE} | grep 'FAILURE' | wc -l)"

open ${STATUS_FILE}
