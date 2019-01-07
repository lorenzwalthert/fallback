any_to_char <- function(x, max_width = 60, quote_chars = TRUE) {
  x <- unlist(x)
  if (is.character(x) && quote_chars) {
    x <- paste0("\"", x, "\"")
    sep <- ", "
  } else {
    x <- deparse(substitute(x))
    sep <- ""
  }
  all <- paste(x, collapse = sep)
  if (nchar(all) > max_width) {
    end <- substr(all, nchar(all) - 10L, nchar(all))
  } else {
    end <- ""
  }
  paste(substr(all, 1, max_width - 10L), "...", end)
}

cat_if_verbose2 <- function(...) {
  if (getOption("fallback.verbose") >= 2) {
    cat(...)
  }
}

cat_if_verbose1 <- function(...) {
  if (getOption("fallback.verbose") == 1) {
    cat(...)
  }
}
