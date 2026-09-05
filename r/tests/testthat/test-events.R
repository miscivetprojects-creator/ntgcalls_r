test_that("event registry manages listeners and dispatches events", {
  reg <- ntgcalls:::EventRegistry$new()
  received <- list()

  cb <- function(evt) {
    received <<- append(received, list(evt))
  }

  reg$add_listener("upgrade", cb)
  reg$dispatch(list(event = "upgrade", chat_id = 12345, state = list(muted = TRUE)))

  expect_equal(length(received), 1L)
  expect_equal(received[[1]]$chat_id, 12345)
  expect_true(received[[1]]$state$muted)

  reg$remove_listener("upgrade", cb)
  reg$dispatch(list(event = "upgrade", chat_id = 12345, state = list(muted = FALSE)))
  expect_equal(length(received), 1L)
})

