<!-- README.md is generated from README.Rmd. Please edit that file -->

# Tools to create and manipulate closures

<!-- badges: start -->

<!-- badges: end -->

Closures are often a poorman alternative to OOP (object oriental programming). However, closures are not portable and difficult to be inherited. Tools are provided to create and manipulate closures.

## Installation

You can install the released version of closure from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("closure")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("randy3k/closure")
```

## Example

``` r
library(closure)

foo_closure <- function(x) {
    self <- environment()
    on.exit(rm(x))

    counter <- NULL
    initialize <- function(x) {
        counter <<- x
    }
    add <- function(x) {
        counter <<- counter + x
        invisible(self)
    }
    initialize(x)
    self
}

foo <- foo_closure(1)
foo$add(3)$counter
#> [1] 4

Foo <- toR6("Foo", foo_closure)
foo <- Foo$new(2)
foo$add(3)$counter
#> [1] 5
```
