#!/bin/bash

rm *.tar.gz
rm ~/thing.txt
R CMD BUILD .

# Work outside of the source directory to avoid false
# positives (i.e. test the tarball in isolation)
mkdir -p ~/pkgnet_test_dir
cp *.tar.gz ~/pkgnet_test_dir

pushd ~/pkgnet_test_dir
    R CMD CHECK *.tar.gz --as-cran
    cat ~/thing.txt
popd
