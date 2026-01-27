# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

pkgnet is an R package for analyzing R packages using graph theory. It builds network representations of packages to:
- Analyze function interdependencies within a package
- Map recursive package dependencies
- Trace class inheritance structures (S4, R5/Reference Classes, R6)
- Prioritize functions for unit testing based on centrality metrics

The core functionality is `CreatePackageReport()` which generates HTML reports analyzing package structure.

## Architecture

### Reporter System (R6-based)

The package uses an object-oriented architecture built on R6 classes with a hierarchical reporter system:

**Base Classes:**
- `AbstractPackageReporter` (R/AbstractPackageReporter.R): Base class for all reporters. Handles package setup via `set_package()` method.
- `AbstractGraphReporter` (R/AbstractGraphReporter.R): Extends AbstractPackageReporter for network-based reporters. Provides `nodes`, `edges`, `network_measures`, and `pkg_graph` active bindings.

**Concrete Reporters:**
- `DependencyReporter` (R/DependencyReporter.R): Analyzes recursive package dependencies
- `FunctionReporter` (R/FunctionReporter.R): Maps function call networks and test coverage
- `InheritanceReporter` (R/InheritanceReporter.R): Traces S4/R5/R6 class inheritance

**Report Generation:**
- `PackageReport` (R/CreatePackageReport.R): Aggregates multiple reporters and renders HTML via rmarkdown
- `CreatePackageReport()`: Convenience function that instantiates PackageReport with default reporters

### Graph Models

`DirectedGraph` class (R/GraphClasses.R) wraps igraph functionality and provides:
- Node and graph measure calculations
- Network visualization via visNetwork
- Integration with reporter system

### Key Patterns

1. **Reporter Lifecycle**: Instantiate → `set_package()` → extract nodes/edges → calculate measures → render
2. **Active Bindings**: Reporters use R6 active bindings for lazy evaluation of `nodes`, `edges`, and `network_measures`
3. **Namespacing**: All non-base function calls must use `::` namespace operator (e.g., `data.table::data.table()`)
4. **data.table convention**: data.table objects named with `DT` suffix (e.g., `nodesDT`)

## Commands

### Testing

Run full test suite (builds tarball and runs R CMD check):
```bash
./test.sh
```

This script:
- Builds package tarball with `R CMD build`
- Runs `R CMD check --as-cran` in isolated directory
- Fails if any WARNINGs found
- Fails if NOTEs exceed allowed count (currently 0)

Run tests interactively in R:
```R
# Set to run NOT_CRAN tests
Sys.setenv(NOT_CRAN = "true")

# Run all tests
devtools::test()

# Run specific test file
devtools::test(filter = "FunctionReporter")
```

### Test Environment

Tests use a temporary package library (`PKGNET_TEST_LIB`) with fake test packages (baseballstats, sartre, milne). Setup/teardown in:
- `tests/testthat/setup-setTestEnv.R`
- `tests/testthat/teardown-setTestEnv.R`

On CRAN, only `test-cran-true.R` runs due to complications with temporary package handling.

### Building

```bash
# Build tarball
R CMD build .

# Install locally
R CMD INSTALL pkgnet_*.tar.gz

# Build documentation
Rscript -e "devtools::document()"
```

### Coverage

```R
covr::package_coverage()
```

## Code Style

### Naming Conventions

- **R6 classes**: UpperCamelCase (e.g., `FunctionReporter`)
- **Exported functions**: UpperCamelCase (e.g., `CreatePackageReport`)
- **Methods/fields**: snake_case (e.g., `set_package`, `pkg_name`)
- **data.table objects**: camelCase ending in `DT` (e.g., `nodesDT`)

### Dependencies

- Always use `::` namespacing for non-base calls
- Add `#' @importFrom package function` in roxygen docs
- Exceptions: operators like `%>%` and `:=` don't need namespacing
- New package dependencies must be added to DESCRIPTION `Imports`

### Indentation

- Use 4 spaces (never tabs)
- Comma-first style for multi-line lists:
```r
sample_list <- list(
    norm_sample = rnorm(100)
    , unif_sample = runif(100)
    , t_sample = rt(100, df = 100)
)
```

### Comments

- All comments above code, never beside
- Avoid comments where code is self-evident

### Roxygen Documentation

**Functions** require:
- `#' @title`
- `#' @name`
- `#' @description`
- `#' @param` (for each parameter)
- `#' @export` (if public API)

**R6 Classes** require sections:
- `#' @section Class Constructor:`
- `#' @section Public Methods:`
- `#' @section Public Members:`
- Document all public methods and active bindings

## R6 Method Support

**FunctionReporter** treats R6 methods as functions with naming convention:
- Format: `<classname>$<methodtype>$<methodname>`
- Example: `FunctionReporter$private$extract_nodes`
- Uses **generator object name** from namespace, not `classname` attribute

**InheritanceReporter** naming:
- **Reference Classes**: Uses `Class` arg from `setRefClass()`
- **R6 Classes**: Uses generator object name in namespace (not `classname` arg)

## Known Limitations

1. **FunctionReporter**:
   - Non-standard evaluation can cause false positives when column names match function names
   - Functions stored in lists (not namespace) are invisible
   - Instantiated R6/reference object method calls not recognized
   - Reference class methods not yet supported

2. **InheritanceReporter**:
   - S3 classes not supported (no formal class definitions)

## Package Versioning

Follows semantic versioning (MAJOR.MINOR.PATCH):
- Development versions append `.9999` (e.g., `0.5.0.9999`)
- Release versions remove `.9999` for CRAN submission

## CI/CD

GitHub Actions workflows:
- `.github/workflows/ci.yml`: Tests on Ubuntu/macOS with R release
- `.github/workflows/release.yml`: Tests on R-devel for CRAN submission
- `.github/workflows/smoke-tests.yaml`: Runs `CreatePackageReport()` on many packages
- `.github/workflows/website.yaml`: Builds pkgdown site

## Rendering Reports

Reports use rmarkdown templates from `inst/package_report/`:
- Work done in temp directory to avoid writing to package repo
- See `PackageReport$render_report()` in R/CreatePackageReport.R:67-98
