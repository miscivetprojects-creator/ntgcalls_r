test_that("error mapping produces structured conditions", {
  err_name <- ntgcalls:::ntg_error_name(ntgcalls:::ntg_error_codes$CONNECTION_NOT_FOUND)
  expect_equal(err_name, "CONNECTION_NOT_FOUND")

  expect_error(
    ntgcalls:::raise_ntg_error(ntgcalls:::ntg_error_codes$CONNECTION_NOT_FOUND, "chat 123 not found"),
    class = "ntgcalls_connection_not_found"
  )
})

