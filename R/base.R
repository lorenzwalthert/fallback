#' Create a fallback
#'
#' Creates a fallback that can be evaluated with [resolve_fallback()].
#' @param terminal_fallback_value The value the fallback will resolve to when
#'   no other instance in the hierarchy defines the key.
#' @param hierarchy,source_file Define the paths to the yaml files where we
#'   look for a key to be defined. By default, it is a file called `config.yaml`
#'   in the working directory and the home directory.
#' @param key The key, that is, the name of the argument the fallback is created
#'   for. Can be `NULL`, so the definition of the key is deferred until
#'   [resolve_fallback()] is called to avoid redundancy.
#' @export
#' @examples
#' fallback(TRUE)
fallback <- function(terminal_fallback_value, hierarchy = c("./", "~/"),
                     source_file = "config.yaml", key = NULL) {
  Fallback$new(key, hierarchy, source_file, terminal_fallback_value = terminal_fallback_value)
}

Fallback <- R6::R6Class("Fallback", public = list(
  key = NULL, key_retrieved = NULL,
  hierarchy = NULL, source_file = NULL, terminal_fallback_value = NULL, value = NULL,
  value_retrieved = NULL,
  initialize = function(key, hierarchy, source_file, terminal_fallback_value) {
    self$key <- as.character(key)
    self$key_retrieved <- !is.null(key)
    self$hierarchy <- hierarchy
    self$source_file <- source_file
    self$value <- NULL
    self$value_retrieved <- FALSE
    self$terminal_fallback_value <- terminal_fallback_value
  },
  print = function() {
    compose_pair <- function(key, value, is_available, quote_chars = FALSE) {
      paste0(key, if (is_available) any_to_char(value, is_available), "\n")
    }
    cli::cat_line(
    "<fallback>\n",
    compose_pair(
      "key                     ", self$key, self$key_retrieved, quote_chars = FALSE
    ),
    compose_pair(
      "value                   ", self$value, self$value_retrieved
    ),
    "hierarchy               ",
    paste0(self$hierarchy, collapse = " -> "), "\n",
    compose_pair(
      "terminal fallback value ",
      self$terminal_fallback_value, is_available = TRUE
    ),
    "source file             ", self$source_file, col = "gray30"
  )
  },
  add_value = function(value) {
    self$value <- value
    self$value_retrieved <- TRUE
  },
  add_key = function(key) {
    if (!self$key_retrieved) {
      self$key <- as.character(key)
      self$key_retrieved <- TRUE
    }
  }
))

Value <- R6::R6Class("Value", public = list(
  value = NULL, retrieved = NULL,
  initialize = function(value = NULL, retrieved = FALSE) {
    self$value <- value
    self$retrieved <- retrieved
  },
  print = function() {
    if (self$retrieved) {
      cat_if_verbose("value:", self$value)
    } else {
      cat_if_verbose("value: ")
    }

  }
))
