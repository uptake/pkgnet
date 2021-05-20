## Contributing to pkgnet

The goal of this guide is to help you contribute to `pkgnet` as quickly and as easily possible.

# Table of contents
1. [Creating an Issue](#issues)
2. [Submitting a Pull Request](#prs)
3. [Code Style](#style)
4. [Running Tests Locally](#testing)
5. [Package Versioning](#version)
6. [Releasing to CRAN (for maintainer)](#cran)

***
## Creating an Issue <a name="issues"></a>

To report bugs, request features, or ask questions about the structure of the code, please [open an issue](https://github.com/uptake/pkgnet/issues).

### Bug Reports

If you are reporting a bug, please describe as many as possible of the following items in your issue:

- your operating system (type and version)
- your version of R
- your version of `pkgnet`

The text of your issue should answer the question "what did you expect `pkgnet` to do and what did it actually do?".

We welcome any and all bug reports. However, we'll be best able to help you if you can reduce the bug down to a **minimum working example**. A **minimal working example (MWE)** is the minimal code needed to reproduce the incorrect behavior you are reporting. Please consider the [stackoverflow guide on MWE authoring](https://stackoverflow.com/help/mcve).

If you're interested in submitting a pull request to address the bug you're reporting, please indicate that in the issue.

### Feature Requests

We welcome feature requests, and prefer the issues page as a place to log and categorize them. If you would like to request a new feature, please open an issue there and add the `enhancement` tag.

Good feature requests will note all of the following:

- what you would like to do with `pkgnet`
- how valuable you think being able to do that with `pkgnet` would be
- sample code showing how you would use this feature if it was added

If you're interested in submitting a pull request to address the bug you're reporting, please indicate that in the issue.

***
## Submitting a Pull Request <a name="prs"></a>

We welcome [pull requests](https://help.github.com/articles/about-pull-requests/) from anyone interested in contributing to `pkgnet`. This section describes best practices for submitting PRs to this project.

If you are interested in making changes that impact the way `pkgnet` works, please [open an issue](#issues) proposing what you would like to work on before you spend time creating a PR.

If you would like to make changes that do not directly impact how `pkgnet` works, such as improving documentation, adding unit tests, or minor bug fixes, please feel free to implement those changes and directly create PRs.

If you are not sure which of the preceding conditions applies to you, open an issue. We'd love to hear your idea!

To submit a PR, please follow these steps:

1. Fork `pkgnet` to your GitHub account
2. Create a branch on your fork and add your changes
3. If you are changing or adding to the R code in the package, add unit tests confirming that your code works as expected
3. When you are ready, click "Compare & Pull Request". Open A PR comparing your branch to the `main` branch in this repo
4. In the description section on your PR, please indicate the following:
    - description of what the PR is trying to do and how it improves `pkgnet`
    - links to any open [issues](https://github.com/uptake/pkgnet/issues) that your PR is addressing

We will try to review PRs promptly and get back to you within a few days.

***
## Code Style <a name="style"></a>

The code in this project should follow a standard set of conventions for style in R code.

### Declaring Dependencies

We use [roxygen2](https://github.com/klutometis/roxygen) to auto-generate our dependency lists in the package's `NAMESPACE` file. If you use a function from any package other than this package and `base`, you need to add `#' @importFrom package_name function_name` in the roxygen documentation of the function you are adding this call to.

All function non-base function calls should be namespaced with `::`. For example:

```{r}
#' @importFrom data.table data.table
some_function <- function(n){
    data.table::data.table(
        samples = rnorm(n)
    )
}
```

You do not need to namespace special operators in the case where doing so would hurt readability. For example, `%>%` from `magrittr` and `:=` from `data.table` do not need `::` namespacing.

If you are adding new dependencies to the package (i.e. using an entirely new package), you need to also add that dependency to the `Imports` section of the [DESCRIPTION file](https://github.com/uptake/pkgnet/blob/main/DESCRIPTION).

### Indentation and whitespace

All indentation should use only space characters in increments of 4 spaces (unless necessary to align comma-separated elements vertically).

Functions, R6 object definitions, and any other calls using `()` can specify items inline if they are sufficiently short (less than 80 characters). For example:

```{r}
some_vector <- c(TRUE, FALSE, FALSE)
```

Longer calls should use indentation of the following form:

```{r}
sample_list <- list(
    norm_sample = rnorm(100)
    , unif_sample = runif(100)
    , t_sample = rt(100, df = 100)
)
```

### Function calls

All function calls should explicitly use keyword arguments. The only exceptions are very common functions from R's default libraries, such as `print()`.

### Exported R6 classes

This package relies heavily on [R6](https://github.com/r-lib/R6) objects. Elements of these objects should follow standard conventions.

- **class names**: UpperCamelCase
- **public method names**: snake_case
- **private method names**: snake_case
- **public field names**: snake_case
- **private field names**: snake_case
- **method arguments**: snake_case

There is one exception to these rules. `data.table` objects should use the convention `nameDT` (ending in `DT`) so they're easily identified. This is important because `data.table` uses non-standard evaluation.

### Exported Functions

Exported functions should be named with UpperCamelCase. 

### Roxygen documentation (functions)

Functions in this package are documented using [roxygen2](https://github.com/klutometis/roxygen). At an absolute minimum, the Roxygen documentation for exported functions should include the following tags:

- **`#' @title`**: Short title for the function
- **`#' @name`**: The exact name of the object
- **`#' @description`**: Longer detail on what the function does (1-4 sentences)
- **`#' @param`**: Expect type for a parameter, acceptable value range, and (if applicable) default value. You should have one of these entries per parameter in the function signature.
- **`#' @export`**: Add this tag to indicate that the object should be in the public namespace of the package

For example, the code below would be an acceptable submission for a function that plots random numbers:

```{r}
#' @title Plot Random Numbers
#' @name plot_random_numbers
#' @description Given a positive integer, generate two random draws from the standard normal distribution and plot them against each other
#' @param num_samples A positive integer indicating the number of samples. Default is 100.
#' @importFrom data.table data.table
#' @importFrom graphics plot
#' @export
plot_random_numbers <- function(num_samples = 100){
    randDT <- data.table::data.table(
        x = rnorm(num_samples)
        , y = rnorm(num_samples)
    )
    randDT[, plot(x, y, main = "random numbers are fun")]
    return(invisible(NULL))
}
```

### Roxygen documentation (R6 objects)

R6 objects in this package are also documented using [roxygen2](https://github.com/klutometis/roxygen). As of this writing, there was no built-in support for R6 objects in roxygen 2. We use an informal standard throughout `pkgnet`.

First, R6 objects should have all of these standard tags:

- **`#' @title`**: Short title for the object
- **`#' @name`**: The exact name of the object
- **`#' @description`**: Longer detail on what the object does (1-4 sentences)
- **`#' @export`**: Add this tag to indicate that the object should be in the public namespace of the package

All public methods (including the constructor) and public fields should be documented. [Active bindings](https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html#active-bindings) should be documented in exactly the same way as other public fields.

For example:

```{r}
#' @title Plot Random Numbers
#' @name RandomNumberPlotter
#' @description Given a positive integer, generate two random draws from 
#'              the standard normal distribution and plot them against each other
#' @section Class Constructor:
#' \describe{
#'     \item{\code{new(num_samples = 100)}}{
#'         \itemize{
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                     \item{\bold{\code{num_samples}}: A positive integer indicating 
#'                         the number of samples. Default is 100.}
#'                 }
#'             }
#'         }
#'     }
#' }
#' 
#' @section Public Methods:
#' \describe{
#'     \item{\code{plot()}}{
#'         \itemize{
#'             \item{Create a plot using the base plotting system}
#'             \item{\bold{Returns}}{
#'                 \itemize{
#'                     \item{Nothing. This method just generates a plot in the
#'                         active graphics device.}
#'                 }
#'             }
#'         }
#'     }
#' }
#' 
#' @section Public Members:
#' \describe{
#'     \item{\bold{\code{num_samples}}}{: integer indicating number of
#'         random samples to be plotted}
#' }
#' @importFrom data.table data.table
#' @importFrom graphics plot
#' @importFrom R6 R6Class
#' @export
RandomNumberPlotter <- R6::R6Class(
    classname = "RandomNumberPlotter",
    public = list(
        num_samples = NULL,
        initialize = function(num_samples = 100){
            self$num_samples <- num_samples
            return(invisible(NULL))
        },
        plot_data = function(){
            randDT <- data.table::data.table(
                x = rnorm(self$num_samples)
                , y = rnorm(self$num_samples)
            )
            randDT[, plot(x, y, main = "random numbers are fun")]
            return(invisible(NULL))
        }
    )
)
```

### Inline comments

All comments should be above code, not beside it.

***
## Running Tests Locally <a name="testing"></a>

We use GitHub Actions to automatically run unit tests and a series of other automated checks on every PR commit and merge to `main`. Every `pkgnet` release also goes through a battery of automated tests run on CRAN before becoming officially available through CRAN.

However, these options can lengthen your testing cycle and make the process of contributing tedious. If you wish to run tests locally on whatever machine you are developing `pkgnet` code on, run the following from the repo root:

```{bash}
./test.sh
```

### Smoke Tests <a name="smoke-tests"></a>

This repo also contains smoke tests which can be run from time-to-time to see if there are certain types of R packages that break `pkgnet`. If you want to try running `pkgnet::CreatePackageReport()` on every package installed on your system, run the following from the root of this repo:

```{bash}
TEST_DATA_DIR=$(pwd)/smoke_tests/test_data
NUM_PARALLEL=4
./smoke_tests/test.sh ${TEST_DATA_DIR} ${NUM_PARALLEL}
```

`test.sh` will create a file `${TEST_DATA_DIR}/package_run_status.txt` that tells you whether individual packages failed or succeeded in `pkgnet::CreatePackageReport()`. For the failed packages, you can open `${TEST_DATA_DIR}/<that package name>.html` to view the report and see the error.

When you find errors, check the [open issues](https://github.com/uptake/pkgnet/issues) to see if it's already been reported. If not, report it!

NOTE: this may take 20-30 minutes to run, dependning on your available resources and the number of installed packages. Also note that this will spin off `NUM_PARALLEL` parallel processes, so if you stop the process early you will see some weird logs.

***
## Package Versioning <a name="version"></a>

### Version Format
We follow semantic versioning for `pkgnet` releases, `MAJOR`.`MINOR`.`PATCH`: 

* the `MAJOR` version will be updated when incompatible API changes are made,   
* the `MINOR` version will be updated when functionality is added in a backwards-compatible manner, and  
* the `PATCH` version will be updated when backwards-compatible bug fixes are made.   

In addition, the latest development version will have a .9999 appended to the end of the `MAJOR`.`MINOR`.`PATCH`. 

For more details, see https://semver.org/

### Release Planning
The authors of this package have adopted [milestones on github](https://help.github.com/en/articles/about-milestones) as a vehile to scope and schedule upcoming releases.  The main goal for a release is written in the milestone description.  Then, any ideas, specific functionality, bugs, etcs submitted as [issues](https://help.github.com/en/articles/about-issues) pertinent to that goal are tagged for that milestone.  Goals for milestone are dicsused openly via a github issue.  

Past and upcoming releases can be seen on the  [pkgnet milestones page](https://github.com/uptake/pkgnet/milestones). 


***
## Releasing to CRAN (for maintainer) <a name="cran"></a>

Once substantial time has passed or significant changes have been made to `pkgnet`, a new release should be pushed to [CRAN](https://cran.r-project.org). 

**This is the exclusively the responsibility of the package maintainer**, but is documented here for our own reference and to reflect the consensus reached between the maintainer and other contributors.

This is a more-manual-than-it-should-be process, with the following steps.

### Open a PR 

Open a PR with a branch name `release/v0.0.0` (replacing 0.0.0 with the actual version number).

Add a section for this release to `NEWS.md`.  This file details the new features, changes, and bug fixes that occurred since the last version.  

Add a section for this release to `cran-comments.md`. This file holds details of our submission comments to CRAN and their responses to our submissions.  

Change the `Version:` field in `DESCRIPTION` to the official version you want on CRAN (should not have a trailing `.9999`).

Rebuild the documentation by running:

```
Rscript -e "roxygen2::roxygenize()"
Rscript -e "install.packages('pkgdown', repos = 'cran.rstudio.com')"
Rscript -e "pkgdown::build_site()"
```

`pkgdown` is changing pretty rapidly, so it's important to pull the latest from CRAN before building the site.

Check in whichever of the files generated by `pkgdown` seem relevant to you. Anything that shows up as "modified" when you run `git status` should be checked in to the PR branch. New files ("not tracked by git") should be considered on a case-by-case basis.

### Test on latest development version of R (i.e. "R-Devel") 

This is a CRAN requirement, and yes, it's a pain.  Luckily, Dirk Eddelbuettel and friends maintain docker images to make this process (a little) easier.  Specifically, the [rocker/drd](https://hub.docker.com/r/rocker/drd) image from [the Rocker Project](https://www.rocker-project.org/images/) provides a great jumping off point.  It's a lighter r-devel image.  Note, this image is rebuilt every few days, so if you _absolutely need_ to have _bleeding edge_ r-devel and have a extra hour to spare, follow [this docker process](https://alexandereckert.com/post/testing-r-packages-with-latest-r-devel/) from Alexander Eckert. 

1. Navigate to the base directory of the package. 
2. Build the r-devel pkgnet docker image and run CRAN checks via these commands: 
```
# On Windows
docker build -f release_testing\dockerfile -t pkgnet_rdevel . 
docker run --rm -ti -v %cd%:/RPackage pkgnet_rdevel ./r_devel_check.sh

# On Mac
docker build -f release_testing/dockerfile -t pkgnet_rdevel . 
docker run --rm -ti -v $(pwd):/RPackage pkgnet_rdevel ./r_devel_check.sh
```
3. Fix your errors and rerun container (second line) until clean CRAN level checks.
4. Once your satisfied with your results, you're done with _linux_ checks.  
5. To test on windows r-devel (as CRAN will do), take the final package tarball and upload it to this webpage: https://win-builder.r-project.org/upload.aspx
6. Grab a coffee and wait for an email (about 10 minutes later but varies)
7. Fix your errors and reupload until good. 

### Submit to CRAN

Go to https://cran.r-project.org/submit.html, take the tarball that passed the gauntlet and submit it! 
![](https://cdn.dribbble.com/users/30794/screenshots/4088042/e__push-button.gif)

**WAIT! You're not done.**

### Handle feedback from CRAN

The maintainer will get an email from CRAN with the status of the submission. 

If the submission is not accepted, do whatever CRAN asked you to do. Update `cran-comments.md` with some comments explaining the requested changes. Rebuild the `pkgdown` site. Repeat this process until the package gets accepted.

### Rebuild the Website

Rebuilding the website now, after all changes and after CRAN update, will build the site with the latest updates and version status tags.

### Merge the PR

Once the submission is accepted, great! Update `cran-comments.md` and merge the PR.

### Create a Release on GitHub

We use [the releases section](https://github.com/uptake/pkgnet/releases) in the repo to categorize certain important commits as release checkpoints. This makes it easier for developers to associate changes in the source code with the release history on CRAN, and enables features like `remotes::install_github()` for old versions.

Navigate to https://github.com/uptake/pkgnet/releases/new. Click the drop down in the "target" section, then click "recent commits". Choose the latest commit for the release PR you just merged. This will automatically create a [git tag](https://git-scm.com/book/en/v2/Git-Basics-Tagging) on that commit and tell Github which revision to build when people ask for a given release.

Add some notes explaining what has changed since the previous release.

### Open a new PR to begin development on the next version

Now that everything is done, the last thing you have to do is move the repo ahead of the version you just pushed to CRAN.

Make a PR that adds a `.9000` on the end of the version you just released. This is a common practice in open source software development. It makes it obvious that the code in source control is newer than what's available from package managers, but doesn't interfere with the [semantic versioning](https://semver.org/) components of the package version.

### Update pkgnet gallery

Currently, the pkgnet gallery is maintained in a seperate repository, [pkgnet-gallery](https://github.com/uptake/pkgnet-gallery).  Follow the README in that repository to update.  If you do not, the gallery page may look out of sync from the other website pages. 
