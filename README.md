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

foo1 <- foo_closure(1)
foo1$add(3)$counter
#> [1] 4

Foo <- toR6("Foo", foo_closure)
foo2 <- Foo$new(1)
foo2$add(3)$counter
#> [1] 4
```

## Why?

Closures are much faster.

``` r
bench::mark(
    closure = foo1$add(3)$counter,
    R6 = foo2$add(3)$counter
)
#> # A tibble: 2 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 closure       909ns   1.12µs   690452.        0B      0  
#> 2 R6           5.49µs   6.08µs   106857.        0B     21.4
```
