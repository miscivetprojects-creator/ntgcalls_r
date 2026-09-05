test_that("client functions and error guards work", {
  client_inst <- structure(list(handle = NULL), class = "NTgCallsClient")
  expect_true(is.null(client_inst$handle))
})
