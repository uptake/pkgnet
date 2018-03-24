## Contributing to pkgnet

The goal of this guide is to help you contribute to `pkgnet` as quickly and as easily possible.

# Table of contents
1. [Creating an Issue](#issues)
2. [Submitting a Pull Request](#prs)
3. [Code Style](#style)

## Creating an Issue <a name="issues"></a>

To report bugs, request features, or ask questions about the structure of the code, please [open an issue](https://github.com/UptakeOpenSource/pkgnet/issues).

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

## Submitting a Pull Request <a name="prs"></a>

We welcome [pull requests](https://help.github.com/articles/about-pull-requests/) from anyone interested in contributing to `pkgnet`. This section describes best practices for submitting PRs to this project.

If you are interested in making changes that impact the way `pkgnet` works, please [open an issue](#issues) proposing what you would like to work on before you spend time creating a PR.

If you would like to make changes that do not directly impact how `pkgnet` works, such as improving documentation, adding unit tests, or minor bug fixes, please feel free to implement those changes and directly create PRs.

If you are not sure which of the preceding conditions applies to you, open an issue. We'd love to hear your idea!

To submit a PR, please follow these steps:

1. Fork `pkgnet` to your GitHub account
2. Create a branch on your fork and add your changes
3. If you are changing or adding to the R code in the package, add unit tests confirming that your code works as expected
3. When you are ready, click "Compare & Pull Request". Open A PR comparing your branch to the `master` branch in this repo
4. In the description section on your PR, please indicate the following:
    - description of what the PR is trying to do and how it improves `pkgnet`
    - links to any open [issues](https://github.com/UptakeOpenSource/pkgnet/issues) that your PR is addressing

We will try to review PRs promptly and get back to you within a few days.

## Code Style <a name="style"></a>

The code in this project should follow a standard set of conventions for style in R code.

### Declaring Dependencies

We use [roxygen2](https://github.com/klutometis/roxygen) to auto-generate our dependency lists in the package's `NAMESPACE` file. If you use a function from any package other than this package and `base`, you need to add `#' @importFrom package_name function_name` in the roxygen documentation of the function you are adding this call to.

All function non-base funciton calls should be namespaced with `::`. For example:

```{r}
#' @importFrom data.table data.table
some_function <- function(n){
    data.table::data.table(
        samples = rnorm(n)
    )
}
```

You do not need to namespace special operators in the case where doing so would hurt readablility. For example, `%>%` from `magrittr` and `:=` from `data.table` do not need `::` namespacing.

If you are adding new dependencies to the package (i.e. using an entirely new package), you need to also add that dependency to the `Imports` section of the [DESCRIPTION file](https://github.com/UptakeOpenSource/pkgnet/blob/master/DESCRIPTION).

### Indentation and whitespace

All indentation should use only space characters in increments of 4 spaces (unless necessary to align comma-separated elements vertically).

Functions, R6 object definitions, and any other calls using `()` can specify items inline if they are sufficiently short (less than 80 characters). For example:

```{r}
some_vector <- c(TRUE, FALSE, FALSE)
```

Longer calls should use indentation of the following form:

```{r}
sample_ist <- list(
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
#' @description Given a positive integer, generate two random drawns from the standard normal distribution and plot them against each other
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
#' @description Given a positive integer, generate two random drawns from 
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

