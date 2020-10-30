
<!-- README.md is generated from README.Rmd. Please edit that file -->

# groundhog

<!-- badges: start -->

[![R build
status](https://github.com/CredibilityLab/groundhog/workflows/R-CMD-check/badge.svg)](https://github.com/CredibilityLab/groundhog/actions)
[![Codecov test
coverage](https://codecov.io/gh/CredibilityLab/groundhog/branch/master/graph/badge.svg)](https://codecov.io/gh/CredibilityLab/groundhog?branch=master)
<!-- badges: end -->

## Installation

groundhog has not yet been released on CRAN and must be installed from
our custom repository:

``` r
install.packages("groundhog", repos = "https://cran.groundhogr.com")
```

## Example 1 - Recovering broken code with backwards incompatible change in dplyr

With version 0.5, [dplyr](https://dplyr.tidyverse.org/) changed how the
[`distinct`](https://dplyr.tidyverse.org/reference/distinct.html)
function worked, leading to dropped variables:

Say you have data with repeat values of `x`:

``` r
df1 <- data.frame(
  x1 = c(1, 1, 2),
  x2 = c("a", "b", "c")
)
```

To drop repeated rows you can use the package dplyr and run:

``` r
dplyr::distinct(df1, x1) 
```

The problem is that in June 2016, the function
[`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html)
was modified in a non backwards-compatible way. Up to that date it would
keep all variables but, afterward the SAME function drops all other
variables, The same line of code, run in the same computer, on the same
date, has one effect before june 2016 vs after.

With groundhog the script tells us which version of dplyr to use keeping
the same results:

``` r
library(groundhog)
# if before the change, then both variables are kept
groundhog.library("dplyr", date = "2016-06-22")
```

``` r
distinct(df1, x1) 
```

``` r
# if after the change, only x1 is kept
#Now as it was two days after 
#IMPORTANT: since another version of dplyr is loaded, we do CTRL-SHIFT-F10 to restart the R Session and load the newer version
groundhog.library("dplyr",date = "2016-06-26")
distinct(df1, x1) 
```
