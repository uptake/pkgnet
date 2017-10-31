# pkgnet

**WARNING: This package is still under construction. It's API can and will change. Please contribute to the conversation about its future by submitting issues and pull requests, or by contacting the package maintainer (see the DESCRIPTION file) directly.**

## Introduction

`pkgnet` is an R library designed for the analysis of R libraries! The goal of the package is to build a graph representation of a package and its dependencies to inform a variety of activities, including:

- prioritizing functions to unit test based on their centrality
- examining the recursive depdencies you are taking on by using a given package
- exploring the structure of a new package provided by a coworker or downloaded from the internet

# Table of contents
1. [How it Works](#howitworks)
2. [Installation](#installation)
3. [Usage Examples](#examples)
4. [Next Steps](#nextsteps)

## How it Works <a name="howitworks"></a>

The core functionality of this package is the `CreatePackageReport` function.

## Installation <a name="installation"></a>

This package has not yet been submitted to [CRAN](https://cran.r-project.org/), though we intend to do so soon.

To use the development version of the package, you can install directly from [GitHub](https://github.com/UptakeOpenSource/pkgnet)

```
devtools::install_github("UptakeOpenSource/pkgnet")
```

## Usage Examples <a name="examples"></a>

TODO: Add examples

## Next Steps <a name="nextsteps"></a>

This is a fairly new project and, as the version number indicates, should be regarded as a work in progress.
