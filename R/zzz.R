.onLoad <- function(libname, pkgname) {
  op <- options()
  op.fallback <- list(
    fallback.verbose = 1L
  )
  toset <- !(names(op.fallback) %in% names(op))
  if (any(toset)) options(op.fallback[toset])
  invisible()
}
