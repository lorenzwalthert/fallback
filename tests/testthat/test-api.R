context("test-api")

test_that("basic usage with verbose = 2", {

  # write basic yaml
  dir <- tempdir()
  dir1 <- fs::path(dir, "dir1")
  fs::dir_create(dir1)
  yaml::write_yaml(list(frog = 100), fs::path(dir1, "config.yaml"))

  # hierarchy: dir1 -> terminal fallback
  g <- function(frog = fallback(letters, hierarchy = dir1, source_file = "config.yaml")) {
    resolve_fallback(frog)$value
  }
  withr::with_options(list(fallback.verbose = 1), {
    capture_output(out <- g())
  })
  expect_equivalent(
    out, 100
  )

  # hierarchy: ~ -> terminal fallback
  f <- function(frog = fallback(letters, hierarchy = "~", source_file = "config.yaml")) {
    resolve_fallback(frog)$value
  }
  withr::with_options(list(fallback.verbose = 1), {
    capture_output(out <- f())
  })
  expect_equivalent(
    out, letters
  )
})

test_that("basic usage with verbose = 1", {

  # write basic yaml
  dir <- tempdir()
  dir1 <- fs::path(dir, "dir1")
  fs::dir_create(dir1)
  yaml::write_yaml(list(frog = 100), fs::path(dir1, "fallbacks.yaml"))

  # hierarchy: dir1 -> terminal fallback
  g <- function(frog = fallback(letters, hierarchy = dir1)) {
    resolve_fallback(frog)$value
  }
  withr::with_options(list(fallback.verbose = 1), {
    expect_output(g(), "resolving argument frog \\(.*fallbacks")
  })
  # hierarchy: ~ -> terminal fallback
  f <- function(frog = fallback(letters, hierarchy = "~")) {
    resolve_fallback(frog)$value
  }
  withr::with_options(list(fallback.verbose = 1), {
    expect_output(f(), "resolving argument frog \\(term")
  })
})

test_that("can disable verbose", {
  out <- withr::with_options(list(fallback.verbose = 0), {
    capture_output(resolve_fallback(fallback(3)))
  })
  expect_equivalent(out, "")

  withr::with_options(list(fallback.verbose = 2), {
    expect_output(resolve_fallback(fallback(3)), "trying")
  })
})
