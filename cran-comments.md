# CRAN Submission History

## v 0.3.0  

### Submission on December 19th, 2018
> This is a major release with several improvements to 
> R package diagnostics, report layout, and testing 
> strategy.  New features and changes are now being 
> tracked in NEWS.md.  
>
> This NEWS.md file and all 
> source code is maintained at https://github.com/UptakeOpenSource/pkgnet.
  
### CRAN Response on December 20th, 2018 (Paraphrased)

> Dear maintainer,
>
> package pkgnet_0.3.0.tar.gz does not pass the incoming checks automatically, please see the following pre-tests: Windows (2 ERRORs) & Debian (1 ERROR)
>
> ...
>
> Please fix all problems and resubmit a fixed version via the webform.
>
> ...
>
> Best regards,
> CRAN teams' auto-check service

See [#154](https://github.com/UptakeOpenSource/pkgnet/pull/154) for the issue description and fix. 

### Resubmission on December 20th, 2018
> The attached package addresses issues found earlier today in the CRAN teams' auto-check service.  It has been checked (via R CMD check --as-cran) on both R-core and R-devel versions today. 
>
> This NEWS.md file and all source code is maintained at https://github.com/UptakeOpenSource/pkgnet.

### CRAN response on December 21st (Paraphrased)
>Dear maintainer,
>
>package pkgnet_0.3.0.tar.gz does not pass the incoming checks automatically, please see the following pre-tests:
Windows: ...
Status: 1 ERROR
...
Warning: invalid package 'd:/RCompile/CRANincoming/R-devel/pkgnet.Rcheck/tests_i386'
...
Best regards,
CRAN teams' auto-check service
Flavor: r-devel-linux-x86_64-debian-gcc, r-devel-windows-ix86+x86_64

### Resubmission on January 2nd, 2019
>Hello, 
>
>I hope you had a refreshing holiday break. 
>
>Apologies for the past issues with this build.  I believe we have remedied the functionality that did not pass i386 tests.  However, I cannot confirm this as the last submission alsopassed R CMD check on R-devel without issue.  Is there a separate docker container I can use to check i386 compatibility?   
>
>This submission passes R CMD check tests on r-devel with two warnings regarding URLs that fail within the container but have been confirmed valid and pass on R CMD check on R-core outside the container. 
>
>Here is the version info: 
```
> RD CMD check --as-cran pkgnet_0.3.0.tar.gz
* using log directory ‘/RPackage/pkgnet.Rcheck’
* using R Under development (unstable) (2018-12-21 r75875)
* using platform: x86_64-pc-linux-gnu (64-bit)
...
```
>
>The exact procedure I followed is outlined here: https://alexandereckert.com/post/testing-r-packages-with-latest-r-devel/
>
>All source code is maintained at https://github.com/UptakeOpenSource/pkgnet.
>
>Sincerely, 
>
>Brian Burns (current pkgnet maintainer)

### Response on January 2nd, 2019

>Dear maintainer,
>
>thanks, package pkgnet_0.3.0.tar.gz is on its way to CRAN.
>
>Best regards,
CRAN teams' auto-check service
Flavor: r-devel-linux-x86_64-debian-gcc, r-devel-windows-ix86+x86_64
Check: CRAN incoming feasibility, Result: Note_to_CRAN_maintainers
  Maintainer: 'Brian Burns <brian.burns@uptake.com>'

---

## v 0.2.1

### Submission on November 1st, 2018

>This is a minor release to address a bug with the `report_path` parameter of `CreatePackageReport`.  Prior to this fix, reports would continue to be saved to a default location rather than the file path supplied by the user.  

>Other items in this release are typo corrections, some additional parameter checks, and more verbose error and info messages. 

---

## v 0.2.0

### Submission on April 30th, 2018
* Resubmitted to CRAN without test folder or source vigette code.
* This was to ensure nothing is written outside of the temp folder 
during vignette build or package testing.  
* Future versions will handle this issue more directly. 

----

## v0.1.0

### Submission on April 12, 2018

#### R CMD check results
* No issues

#### CRAN Response
* accepted and available on CRAN

### Submission on April 11, 2018

#### R CMD check results
* One NOTE about license file, will see what they say

#### CRAN Response
* Need to use CRAN recognized LICENSE format
* Need to single-quote `pkgnet` in `DESCRIPTION` file


