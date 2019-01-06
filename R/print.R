any_to_char <- function(x, max_length = 10, quote_chars = TRUE) {
  x <- unlist(x)
  if (is.character(x) && quote_chars) {
    x <- paste0("\"", x, "\"")
    sep <- ", "
  } else {
    x <- deparse(substitute(x))
    sep <- ""
  }
  if (length(x) > max_length) {
    x <- c(x[seq(1, max(0, max_length - 2L))], "...", x[length(x)])
  }
  paste(x, collapse = sep)
}

cat_if_verbose <- function(...) {
  if (getOption("fallback.verbose") > 0) {
    cat(...)
  }
}
