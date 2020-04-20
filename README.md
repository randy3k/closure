<!-- README.md is generated from README.Rmd. Please edit that file -->

# Tools to create and manipulate closures

**WORKING IN PROGESS**

<!-- badges: start -->

<!-- badges: end -->

Closures are often a poorman alternative to OOP (object oriental programming), not only because they could be easier implemented but because they are fast. However, it is quite easy to get things wrong if one is not careful enough. Tools are provided to create and manipulate closures.

## Installation

You can install the released version of closure from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("closure")  # not yet released
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("randy3k/closure")
```

## Example

``` r
library(closure)

Foo1 <- new_closure(list(
    counter = NULL,
    initialize = function(x) {
        counter <<- x
    },
    add = function(x) {
        counter <<- counter + x
        invisible(self)
    }
))
foo1 <- Foo1(1)
foo1$add(3)$counter
#> [1] 4

Foo2 <- toR6("Foo2", Foo1)
foo2 <- Foo2$new(1)
foo2$add(3)$counter
#> [1] 4
```

## Why?

First of all, closures are much faster.

``` r
bench::mark(
    closure = foo1$add(3)$counter,
    R6 = foo2$add(3)$counter
)
#> # A tibble: 2 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 closure      1.07µs   1.28µs   471158.        0B      0  
#> 2 R6           5.99µs   6.69µs    95307.        0B     19.1
```

And it is incredibly easier to make things wrong.

``` r
g <- function(k) {
    function(x) {
        x^k
    }
}
m <- 2
h1 <- g(2)
h2 <- g(m)
m <- 3
identical(h1(2), h2(2))
#> [1] FALSE
```

See also, [advanced-R](https://adv-r.hadley.nz/function-factories.html#forcing-evaluation).
