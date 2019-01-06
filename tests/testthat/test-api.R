context("test-api")

test_that("basic usage", {
  # write basic yaml
  dir <- tempdir()
  dir1 <- fs::path(dir, "dir1")
  fs::dir_create(dir1)
  yaml::write_yaml(list(frog = 100), fs::path(dir1, "config.yaml"))

  # hierarchy: dir1 -> terminal fallback
  g <- function(frog = fallback(letters, hierarchy = dir1)) {
    resolve_fallback(frog)$value
  }
  capture_output(out <- g())
  expect_equivalent(
    out, 100
  )

  # hierarchy: ~ -> terminal fallback
  f <- function(frog = fallback(letters, hierarchy = "~")) {
    resolve_fallback(frog)$value
  }
  capture_output(out <- f())
  expect_equivalent(
    out, letters
  )
})

test_that("can disable verbose", {
  out <- withr::with_options(list(fallback.verbose = 0), {
    capture_output(resolve_fallback(fallback(3)))
  })
  expect_equivalent(out, "")

  withr::with_options(list(fallback.verbose = 1), {
    expect_output(resolve_fallback(fallback(3)), "trying")
  })
})

