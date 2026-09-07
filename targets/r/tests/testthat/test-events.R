test_that("event registry works properly", {
  reg <- EventRegistry$new()
  called <- FALSE
  data_received <- NULL

  reg$on("test_event", function(d) {
    called <<- TRUE
    data_received <<- d
  })

  reg$emit("test_event", list(chat_id = 12345L))
  expect_true(called)
  expect_equal(data_received$chat_id, 12345L)

  called <- FALSE
  reg$off("test_event")
  reg$emit("test_event", list(chat_id = 12345L))
  expect_false(called)
})
