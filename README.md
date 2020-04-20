<!-- README.md is generated from README.Rmd. Please edit that file -->

# Tools to create and manipulate closures

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

Foo3 <- toR6("Foo3", Foo1, portable = FALSE)
foo3 <- Foo3$new(1)
# method chaining does not work for non portable class
foo3$add(3)
foo3$counter
#> [1] 4
```

## Details

Why `closure` when there is `R6`? It’s because closures are much faster. Even faster than `R6` when `portable` is `TRUE`.

``` r
bench::mark(
    closure = foo1$add(3),
    R6 = foo2$add(3),
    `R6 Portable` = foo3$add(3),
    check = FALSE
)
#> # A tibble: 3 x 6
#>   expression       min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>  <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 closure        704ns    839ns   714172.        0B     71.4
#> 2 R6               4µs    4.6µs   158280.        0B     15.8
#> 3 R6 Portable   1.75µs      2µs   344639.        0B      0
```

Then why you need this package to write closure? Because it is incredibly easier to make things wrong. See the following example inspired by [advanced-R](https://adv-r.hadley.nz/function-factories.html#forcing-evaluation).

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
