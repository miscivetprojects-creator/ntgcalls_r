test_that("client lifecycle and validation logic work as expected", {
  expect_error(validate_chat_id(NULL))
  expect_equal(validate_chat_id(12345), 12345)
  expect_equal(validate_chat_id("12345"), "12345")

  raw_b <- as_raw_bytes("hello")
  expect_type(raw_b, "raw")
  expect_equal(rawToChar(raw_b), "hello")
})
