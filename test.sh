#!/bin/bash

rm *.tar.gz
rm ~/repos/thing.txt
R CMD BUILD .
cp *.tar.gz ~/Desktop
pushd ~/Desktop
    R CMD CHECK *.tar.gz --as-cran
    cat ~/repos/thing.txt
popd
