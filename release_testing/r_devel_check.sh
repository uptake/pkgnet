#!bin/bash
cd /RPackage
rm *.tar.gz

RD CMD build .
RD CMD check --as-cran *.tar.gz
