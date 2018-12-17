# Version 0.3.0

## NEW FEATURES
* InheritanceReporter, a reporter for R6, Reference, and S4 class inheritance relationships within a package.
* Dropdown menu in graph visualizations for node selection.

## CHANGES
* Edge direction reversed to align with UML class diagram convention. Now, if A depends on B, then A->B.
* Default node colors are now colorblind accessible. 
* Function network design utilizes graphopt layout.
* Reporters now support all layouts available in igraph. Use grep("^layout_\\S", getNamespaceExports("igraph"), value = TRUE) to see valid options.
* `FunctionReporter` now supports non-exported functions and R6 class methods.
* Testing strategy with subpackages are now CRAN and TRAVIS compatible. 
* Test package `milne` created for unit testing of `InheritanceReporter` and R6 method support in `FunctionReporter`.
* Width of html reports adjust to size of screen. 
* Orphaned node clustering was removed in favor of using layout to better handle graphs with many orphaned nodes.
* Various misc. improvements to UX for package reports.

## BUG FIXES
* Rendering of the table in Function Network tab. 

<!--- Start of NEWS.md --->
