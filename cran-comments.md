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


