# pkgnet 0.3.0

## NEW FEATURES
* `InheritanceReporter`, a reporter for R6, Reference, and S4 class inheritance relationships within a package. ([#14](https://github.com/UptakeOpenSource/pkgnet/issues/14), [#129](https://github.com/UptakeOpenSource/pkgnet/pull/129))
* Dropdown menu in graph visualizations for selecting which node to highlight. ([#132](https://github.com/UptakeOpenSource/pkgnet/issues/132), [#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))

## CHANGES
* Edge direction reversed to align with [UML dependency diagram](https://en.wikipedia.org/wiki/Dependency_(UML)) convention. Now, if A depends on B, then A->B. ([#131](https://github.com/UptakeOpenSource/pkgnet/issues/131), [#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))
* Reporters now support all layouts available in igraph. Use `grep("^layout_\\S", getNamespaceExports("igraph"), value = TRUE)` to see valid options. ([#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))
* `FunctionReporter` now utilizes graphopt layout by default. ([#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))
* `FunctionReporter` now supports non-exported functions and R6 class methods. ([#123](https://github.com/UptakeOpenSource/pkgnet/issues/123), [#128](https://github.com/UptakeOpenSource/pkgnet/pull/128))
* Orphaned node clustering was removed in favor of using layout to better handle graphs with many orphaned nodes. ([#102](https://github.com/UptakeOpenSource/pkgnet/issues/102), [#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))
* Testing strategy with subpackages are now CRAN and TRAVIS compatible. ([#121](https://github.com/UptakeOpenSource/pkgnet/issues/121), [#139](https://github.com/UptakeOpenSource/pkgnet/pull/139), [#144](https://github.com/UptakeOpenSource/pkgnet/pull/144))
* Test package `milne` created for unit testing of `InheritanceReporter` and R6 method support in `FunctionReporter`. ([#128](https://github.com/UptakeOpenSource/pkgnet/issues/128), [#129](https://github.com/UptakeOpenSource/pkgnet/pull/129))
* Width of html reports now adjust to size of screen. ([#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))
* Default node colors are now colorblind accessible. ([#130](https://github.com/UptakeOpenSource/pkgnet/issues/130), [#141](https://github.com/UptakeOpenSource/pkgnet/pull/141))
* Additional various improvements to UX for package reports. ([#143](https://github.com/UptakeOpenSource/pkgnet/pull/143))

## BUG FIXES
* Rendering of the table in Function Network tab. ([#136](https://github.com/UptakeOpenSource/pkgnet/issues/136), [#138](https://github.com/UptakeOpenSource/pkgnet/pull/138))

<!--- Start of NEWS.md --->
