
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

[![Travis build
status](https://travis-ci.org/lorenzwalthert/fallback.svg?branch=master)](https://travis-ci.org/lorenzwalthert/fallback)

[![Coverage
status](https://codecov.io/gh/lorenzwalthert/fallback/branch/master/graph/badge.svg)](https://codecov.io/github/lorenzwalthert/fallback?branch=master)

# fallback

The goal of fallback is to provide a mechanism for resolving the value
of arguments of function calls at the time the function is called. It
extends the concept of default values but the value resolution can also
be used outside of this context.

See the below example for the primary use case:

``` r
g <- function(x = 1) x
```

If you call `g()` without arguments, the value of the argument `x` is
determined as follows:

1.  check if the function call specifies it.

2.  if not, check if the function declaration specifies it.

fallback provides a mechanism to extend this chain by defining more
places to look for a specification. This can be helpful for functions
that are called often interactively. For portability and transparency,
the configuration could be stored in a config file. Below, we create a
fallback chain that, when used in a function declaration

1.  checks if the function call specifies the argument value.

2.  If not, check if `fallbacks.yaml` in the working directory (`"."`)
    contains a key `"arg_1"`.

3.  if not, checks if the home directory (`"~"`) contains such a file
    and key.

4.  if not sets the argument to `TRUE`.

<!-- end list -->

``` r
library(fallback)
fallback(TRUE, source_file = "fallbacks.yaml", hierarchy = c(".", "~"), key = "arg_1")
#> <fallback>
#> key                     "arg_1" ... 
#> value                   
#> hierarchy               . -> ~
#> terminal fallback value TRUE ... 
#> source file             fallbacks.yaml
```

The above values apart from `key` are defaults, so we can omit them.
`key` will be set to `"arg_1"` below only when the fallback is
evaluated. Then, the chain will be walked and the final value of `arg_1`
will be determined.

``` r
some_fun <- function(arg_1 = fallback(TRUE)) {
  arg_1 <- resolve_fallback(arg_1)
  arg_1$value
}

options(fallback.verbose = 2) # make chain walk explicit

some_fun()
#> resolving argument arg_1 
#> ● trying ./fallbacks.yaml: ✖ failed (source file does not exist)
#> ● trying ~/fallbacks.yaml: ✖ failed (source file does not exist)
#> ● resorting to terminal fallback value: ✔ success (TRUE ... )
#> [1] TRUE

some_fun("q")
#> resolving argument arg_1 
#> ● resorting to literal input value:  ✔ success (q)
#> [1] "q"

options(fallback.verbose = 1) # less verbose

some_fun()
#> resolving argument arg_1 (terminal fallback)
#> [1] TRUE

some_fun("q")
#> resolving argument arg_1 (literal input value)
#> [1] "q"
```

You can disable message printing completely with
`options(fallback.verbose = 0)`.

## Installation

You can install the released version of fallback from GitHub:

``` r
remotes::install_github("lorenzwalthert/fallback")
```

## Applications

This is primarily for package developers and functions that are called
in interactive use. One use case could be the source code formatter
[styler](https://styler.r-lib.org), where one want to define a
configuration on a project by project basis. We could create the
following config file in a project root:

    strict: False
    scope: spaces

Note that we can place R code in the YAML file like `!expr seq(1, 2)`.

If the declaration of `tidyverse_style` was

``` r
tidyverse_style <- function(scope = fallback("tokens"),
                            strict = fallback(TRUE),
                            indent_by = fallback(2),
                            start_comments_with_one_space = fallback(FALSE),
                            reindention = fallback(tidyverse_reindention()),
                            math_token_spacing = fallback(tidyverse_math_token_spacing())) {
  strict <- resolve_fallback(strict)
  # ...
}
```

We could just call

``` r
style_file("R/testing.R", style = tidyverse_style)
```

To use the default values from the config file or even omit `style`
because `tidyverse_style` is the default. We could also place the config
file in the home directory so it can be accessed for every project and
only declare the deviation from the *global* style in the project root.
