#' Resolve a fallback
#'
#' Resolves the value of a fallback chain defined with [fallback()].
#' @param fallback A fallback chain defined with [fallback()].
#' @examples
#'
#' f <- function(x = fallback(TRUE)) {
#'   resolve_fallback(x)$value
#' }
#'
#' f() # with no config files in place, this resolves to the terminal fallback.
#' dir <- tempdir()
#' dir1 <- fs::path(dir, "dir1")
#' fs::dir_create(dir1)
#' yaml::write_yaml(list(frog = 100), fs::path(dir1, "config.yaml"))
#'
#'
#' g <- function(frog = fallback(letters, hierarchy = dir1)) {
#'   resolve_fallback(frog)$value
#' }
#'
#' # this should resolve to the fallback declared in dir1
#' g()
#' @export
resolve_fallback <- function(fallback) {
  key <- deparse(substitute(fallback))
  cat_if_verbose(crayon::silver(paste("declaring argument", key, "\n")))

  if (!(inherits(fallback, "Fallback"))) {
    cat_if_verbose(crayon::silver(paste0(
      cli::symbol$bullet, " resorting to literal input value: "
    ), crayon::green(paste0(cli::symbol$tick, " success (", fallback, ")\n")
    )))
    fallback_ <- fallback(fallback)
    fallback_$add_key(key)
    fallback_$add_value(fallback)
    return(fallback_)
  }
  fallback$add_key(key)

  value <- declare_value(
    fallback$key,
    fallback$hierarchy,
    fallback$source_file,
    fallback$terminal_fallback_value
  )

  fallback$add_value(value$value)
  fallback
}


set_null_to <- function(test, alternative) {
  if (is.null(test)) {
    alternative
  } else {
    test
  }
}

declare_value <- function(key, hierarchy, source_file, terminal_fallback_value) {
  paths <- fs::path(hierarchy, source_file)
  value <- Value$new(NULL, retrieved = FALSE)
  for (path in paths) {
    value <- retrieve_from_path(key, path)
    if (value$retrieved) break
  }
  if (!value$retrieved) {
    cat_if_verbose(crayon::silver(paste0(
      cli::symbol$bullet, " resorting to terminal fallback value: "
    )))
    cat_if_verbose(crayon::green(paste0(cli::symbol$tick, " success (", any_to_char(terminal_fallback_value), ")\n")))
    value <- Value$new(terminal_fallback_value, retrieved = TRUE)
  }
  value
}

retrieve_from_path <- function(key, path) {
  cat_if_verbose(crayon::silver(paste0(cli::symbol$bullet, " trying ", path, ": ", collapse = "")))
  if (!fs::file_exists(path)) {
    cat_if_verbose(crayon::red(cli::symbol$cross, "failed (source file does not exist)\n"))
    return(Value$new(NULL, retrieved = FALSE))
  }
  content <- yaml::read_yaml(path, eval.expr = TRUE)
  if (key %in% names(content)) {
    cat_if_verbose(crayon::green(paste0(cli::symbol$tick, " success (", paste(content[[key]], collapse = ", "), ")\n")))
    Value$new(content[[key]], retrieved = TRUE)
  } else {
    cat_if_verbose(crayon::red(cli::symbol$cross, "failed (key does not exist in source file)\n"))
    Value$new(NULL, retrieved = FALSE)

  }
}
