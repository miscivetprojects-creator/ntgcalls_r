test_that("error mapping produces structured conditions", {
  err_name <- ntg_error_name(ntg_error_codes$CONNECTION_NOT_FOUND)
  expect_equal(err_name, "CONNECTION_NOT_FOUND")

  expect_error(
    raise_ntg_error(ntg_error_codes$CONNECTION_NOT_FOUND, "chat 123 not found"),
    class = "ntgcalls_connection_not_found"
  )
})
