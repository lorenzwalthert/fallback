
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

[![Travis build
status](https://travis-ci.org/lorenzwalthert/fallback.svg?branch=master)](https://travis-ci.org/lorenzwalthert/fallback)

[![Coverage
status](https://codecov.io/gh/lorenzwalthert/fallback/branch/master/graph/badge.svg)](https://codecov.io/github/lorenzwalthert/fallback?branch=master)

# fallback

The goal of fallback is to provide a mechanism for determining the value
of arguments of function calls at the time the function is called. It
extends the concept of default values.

See the below example:

``` r
g <- function(x = 1) x
```

If you call `g()` without arguments, the value of the argument `x` is
determined as follows:

1.  check if the function call specifies it.

2.  if not, check if the function declaration specifies it.

fallback provides a mechanism to extend this chain by defining more
places to look for a specification. This can be helpful for functions
that are called often interactively. For portability and similar to the
`.Rprofile`, the configuration could be stored in a config file. Below,
we create a fallback chain that, when used in a function declaration

1.  checks if `config.yaml` in the working directory (`"."`) contains a
    key `"arg_1"`.

2.  if not, checks if the home directory (`"~"`) contains such a file
    and key.

3.  if not sets the argument to `TRUE`.

<!-- end list -->

``` r
library(fallback)
fallback(TRUE, hierarchy = c(".", "~"), source_file = "config.yaml", key = "arg_1")
#> <fallback>
#> key                     "arg_1"
#> value                   
#> hierarchy               . -> ~
#> terminal fallback value TRUE
#> source file             config.yaml
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

some_fun()
#> declaring argument arg_1 
#> ● trying ./config.yaml: ✖ failed (key does not exist in source file)
#> ● trying ~/config.yaml: ✖ failed (source file does not exist)
#> ● resorting to terminal fallback value: ✔success (TRUE)
#> [1] TRUE
```

You can disable message printing with `options(fallback.verbose = 0)`.

## Installation

You can install the released version of fallback from GitHub:

``` r
remotes::install_github("lorenzwalthert/fallback")
```

## Applications

This is premarily for package developers and functions that are called
in interactive use. One use case could be the source code formatter
[styler](https://styler.r-lib.org), where one want to define a
configuration on a project by project basis. We could create the
following config file in a project root:

    strict: False
    scope: spaces

If the declaration of `tidyverse_style` was

``` r
tidyverse_style <- function(scope = fallback("tokens"),
                            strict = fallback(TRUE),
                            indent_by = 2,
                            start_comments_with_one_space = FALSE,
                            reindention = tidyverse_reindention(),
                            math_token_spacing = tidyverse_math_token_spacing()) {
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
