test_that("client functions and methods exist", {
  expect_true(is.function(ntgcalls))
  expect_true(is.function(audio_description))
  expect_true(is.function(video_description))
  expect_true(is.function(media_description))
})
