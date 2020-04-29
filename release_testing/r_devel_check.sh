#!bin/bash
cd /RPackage
rm *.tar.gz

RD CMD build pkgnet/
RD CMD check --as-cran *.tar.gz
