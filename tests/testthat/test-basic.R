context("test-basic")


test_that("can retrieve basic key and walk hierarchy", {

  # Create dir1 and retrieve
  dir <- tempdir()
  dir1 <- fs::path(dir, "dir1")
  fs::dir_create(dir1)
  yaml::write_yaml(list(x = 3), fs::path(dir1, "fallbacks.yaml"))
  withr::with_options(list(fallback.verbose = 2), {
    expect_output(
      value <- resolve_fallback(fallback(22, key = "x", hierarchy = dir1))$value,
      c("trying .*fallbacks.yaml:.* success")
    )
  })
  expect_equal(value, 3)

  # Prepend dir2 and config that does not contain key. Fallback to dir1
  dir2 <- fs::path(dir, "dir2")
  fs::dir_create(dir2)
  yaml::write_yaml(list(y = 7), fs::path(dir2, "fallbacks.yaml"))
  withr::with_options(list(fallback.verbose = 2), {
    expect_output(
      value <- resolve_fallback(fallback(TRUE, hierarchy = c(dir2, dir1), key = "x"))$value,
      c("trying .*fallbacks.yaml:.*fail.*success")
    )
  })
  expect_equal(value, 3)

  # Prepend inexistend source file. Fallback to dir 1
  withr::with_options(list(fallback.verbose = 2), {
    expect_output(
      value <- resolve_fallback(fallback("x1", hierarchy = c("~", dir1), key = "x"))$value,
      c("trying .*fallbacks.yaml: .*failed \\(source file does not.*success")
    )
  })
  expect_equal(value, 3)

  fs::dir_delete(dir)
})

test_that("can retrieve NULL value", {
  dir <- tempdir()
  dir1 <- fs::path(dir, "dir1")
  fs::dir_create(dir1)
  yaml::write_yaml(list(x = NULL), fs::path(dir1, "fallbacks.yaml"))
  withr::with_options(list(fallback.verbose = 2), {
    expect_output(
      value <- resolve_fallback(fallback("2x", hierarchy = dir1, key = "x"))$value,
      c("trying .*fallbacks.yaml:.*success")
    )
  })
  expect_equal(value, NULL)
})


test_that("for inexistent key, the fallback is returned", {
  dir <- tempdir()
  dir1 <- fs::path(dir, "dir1")
  fs::dir_create(dir1)
  yaml::write_yaml(list(x = NULL), fs::path(dir1, "fallbacks.yaml"))
  withr::with_options(list(fallback.verbose = 2), {
    expect_output(
      value <- resolve_fallback(fallback("TRUE", hierarchy = dir1, key = "2x"))$value,
      c("trying .*fallbacks.yaml:.*failed.*resorting to terminal")
    )
  })
  expect_equal(value, "TRUE")
})
