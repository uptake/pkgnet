# pkgnet (dev)
## NEW FEATURES
* Node coloring in DependencyReporter (#243)

## CHANGES
* Removed LazyData field to accomodate change in CRAN policy. (#289)

## BUGFIXES

# pkgnet 0.4.1

## NEW FEATURES

* `CreatePackageReport()` now outputs an object of new class `PackageReport` (instead of a list of reporters). This object will let you interactively manipulate the included reporter objects to customize the report, and regenerate the report on demand. You can also instantiate and interact with a `PackageReport` object directly without `CreatePackageReport()`.

## CHANGES
* Rounding format within report tables improved.
* Contact information updated throughout the package documentation.
* Appveyor testing configured in order to test windows builds in CI process.
* Package logos were created.  They are available within this repository at `./man/figures`.
* Remove vignettes from CRAN hosted package.  They remain as articles on the website.

## BUGFIXES
* Error handling for erroneous colors within `AbstractGraphReporter$set_plot_node_color_scheme()`. ([#262](https://github.com/uptake/pkgnet/pull/262)
* data.table osx install bug for Travis. ([#251](https://github.com/uptake/pkgnet/pull/251) Thanks @TylerGrantSmith
* Single row data.table handling with R6 report code. ([#263](https://github.com/uptake/pkgnet/pull/263) Thanks @TylerGrantSmith
* Jaccard similarity example in pkgnet-intro vignette. Thanks @marcpaterno

# pkgnet 0.4.0

## NEW FEATURES

* Objects of new `DirectedGraph` class now slot into the `pkg_graph` field of network reporters. These objects encapsulate the graph modeling of networks and have a more expressive set of methods for analysis. Check out the full documentation with `?DirectedGraph`.  ([#181](https://github.com/uptake/pkgnet/pull/181))
    * Use `pkg_graph$node_measures` and `pkg_graph$graph_measures` to respectively calculate node-level and graph-level measures. 
    * Use `pkg_graph$default_node_measures` and `pkg_graph$default_graph_measures` to see the measures calculated by default. 
    * Use `pkg_graph$available_node_measures` and `pkg_graph$available_graph_measures` to see the all supported measures.
    * The igraph object is now instead available at `pkg_graph$igraph`.
* pkgnet now has a [gallery](https://uptake.github.io/pkgnet-gallery/docs/articles/pkgnet-gallery.html)! Check out reports for different packages. We welcome contributions---see [here](https://github.com/uptake/pkgnet-gallery) for instructions on how to add a package to the gallery. 
* New function `CreatePackageVignette` that creates an Rmarkdown HTML vignette version of a pkgnet report. This vignette can be built using knitr and distributed with a package, like any other vignette. Check out [our example](https://uptake.github.io/pkgnet-gallery/exhibits/pkgnet-vignette/pkgnet-vignette.html) on the pkgnet gallery. ([#200](https://github.com/uptake/pkgnet/pull/200))
    * A new vignette ["Publishing Your pkgnet Package Report"](https://uptake.github.io/pkgnet/articles/publishing-reports.html) has been added that discusses `CreatePackageVignette` and the new gallery.  
* Roxygen documentation has been improved. Each reporter's documentation is now more complete. Additionally, there is a new package documentation article that introduces pkgnet, accessible with `?pkgnet`. ([#192](https://github.com/uptake/pkgnet/pull/192), [#193](https://github.com/uptake/pkgnet/pull/193), [#198](https://github.com/uptake/pkgnet/pull/198))

## CHANGES

* Standardizing on the language "dependency" and "reverse dependency" to describe the directed graph relationships in the package. This completes the change introduced in v0.3.0 where edge direction convention was set to point in the direction of dependency. So this means that "depend on" follows the edge arrow direction, and "reverse depends on" is reverse edge arrow direction. ([#191](https://github.com/uptake/pkgnet/issues/106), [#181](https://github.com/uptake/pkgnet/pull/181))
* `outSubgraphSize` and `inSubgraphSize` have been replaced with `numRecursiveDeps` and `numRecursiveRevDeps`, which are the former minus one (by not counting the node itself). ([#191](https://github.com/uptake/pkgnet/issues/106), [#181](https://github.com/uptake/pkgnet/pull/181))
* Per the new `DirectedGraph` feature, reporters' `pkg_graph` field now contain an object of new `DirectedGraph` class. Previously it held an igraph object. This igraph object is now instead available at `pkg_graph$igraph`. See NEW FEATURES section for other details about the new `pkg_graph` object. ([#181](https://github.com/uptake/pkgnet/pull/181))
* Default measures now exist for each reporter. These can be calculated with the
new method `calculate_default_measures` on reporters. ([#181](https://github.com/uptake/pkgnet/pull/181))
    * The report from `CreatePackageReport` will now only show default measures.
* Reporters now only allow packages to be set once. To report on a new package, please instantiate a new instance of the reporter of interest. ([#106](https://github.com/uptake/pkgnet/issues/106), [#181](https://github.com/uptake/pkgnet/pull/181))
* The report from `CreatePackageReport` now prints the version of pkgnet used at the bottom. ([#181](https://github.com/uptake/pkgnet/pull/181))
* `AbstractPackageReporter` and `AbstractGraphReporter` are no longer exported. These are base classes that are not meant to be used directly. ([#190](https://github.com/uptake/pkgnet/issues/190), [#198](https://github.com/uptake/pkgnet/pull/198))
* Wide in package reports are now horizontally scrollable instead of making the page wider. ([#200](https://github.com/uptake/pkgnet/pull/200))

## BUG FIXES
* Static outputs shown in the vignette that were outdated have been updated. ([#189](https://github.com/uptake/pkgnet/issues/189), [#181](https://github.com/uptake/pkgnet/pull/181))

# pkgnet 0.3.2

## NEW FEATURES
None

## CHANGES
* Added unit tests for network measure calculations ([#166](https://github.com/uptake/pkgnet/pull/166)).
* Revised unit test setup and teardown files to enable devtools::test() to work as well as CRAN server testing ([#167](https://github.com/uptake/pkgnet/pull/167))

## BUG FIXES
* Corrected node statistics table merging error ([#165](https://github.com/uptake/pkgnet/issues/165), [#166](https://github.com/uptake/pkgnet/pull/166))
* Added a NAMESPACE entry for knitr to suppress warning on CRAN server checks ([#168](https://github.com/uptake/pkgnet/pull/168))

# pkgnet 0.3.1

## NEW FEATURES
None

## CHANGES
* Unit testing strategy on CRAN vs Travis and local. See [#160](https://github.com/uptake/pkgnet/issues/160) for details. 

## BUG FIXES
None

# pkgnet 0.3.0

## NEW FEATURES
* `InheritanceReporter`, a reporter for R6, Reference, and S4 class inheritance relationships within a package. ([#14](https://github.com/uptake/pkgnet/issues/14), [#129](https://github.com/uptake/pkgnet/pull/129))
* Dropdown menu in graph visualizations for selecting which node to highlight. ([#132](https://github.com/uptake/pkgnet/issues/132), [#143](https://github.com/uptake/pkgnet/pull/143))

## CHANGES
* Edge direction reversed to align with [UML dependency diagram](https://en.wikipedia.org/wiki/Dependency_(UML)) convention. Now, if A depends on B, then A->B. ([#131](https://github.com/uptake/pkgnet/issues/131), [#143](https://github.com/uptake/pkgnet/pull/143))
* Reporters now support all layouts available in igraph. Use `grep("^layout_\\S", getNamespaceExports("igraph"), value = TRUE)` to see valid options. ([#143](https://github.com/uptake/pkgnet/pull/143))
* `FunctionReporter` now utilizes graphopt layout by default. ([#143](https://github.com/uptake/pkgnet/pull/143))
* `FunctionReporter` now supports non-exported functions and R6 class methods. ([#123](https://github.com/uptake/pkgnet/issues/123), [#128](https://github.com/uptake/pkgnet/pull/128))
* Orphaned node clustering was removed in favor of using layout to better handle graphs with many orphaned nodes. ([#102](https://github.com/uptake/pkgnet/issues/102), [#143](https://github.com/uptake/pkgnet/pull/143))
* Testing strategy with subpackages are now CRAN and TRAVIS compatible. ([#121](https://github.com/uptake/pkgnet/issues/121), [#139](https://github.com/uptake/pkgnet/pull/139), [#144](https://github.com/uptake/pkgnet/pull/144))
* Test package `milne` created for unit testing of `InheritanceReporter` and R6 method support in `FunctionReporter`. ([#128](https://github.com/uptake/pkgnet/issues/128), [#129](https://github.com/uptake/pkgnet/pull/129))
* Width of html reports now adjust to size of screen. ([#143](https://github.com/uptake/pkgnet/pull/143))
* Default node colors are now colorblind accessible. ([#130](https://github.com/uptake/pkgnet/issues/130), [#141](https://github.com/uptake/pkgnet/pull/141))
* Additional various improvements to UX for package reports. ([#143](https://github.com/uptake/pkgnet/pull/143))

## BUG FIXES
* Rendering of the table in Function Network tab. ([#136](https://github.com/uptake/pkgnet/issues/136), [#138](https://github.com/uptake/pkgnet/pull/138))
