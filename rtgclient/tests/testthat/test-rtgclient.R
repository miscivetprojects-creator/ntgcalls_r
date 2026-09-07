test_that("stream helpers create valid media descriptions", {
  as <- AudioStream("test.raw", sample_rate = 48000L, channel_count = 2L)
  expect_s3_class(as, "rtg_audio_stream")
  expect_s3_class(as, "ntg_media_description")
  expect_equal(as$microphone$sample_rate, 48000L)
  expect_equal(as$microphone$channel_count, 2L)

  vs <- VideoStream("test.raw", width = 1280L, height = 720L, fps = 30L)
  expect_s3_class(vs, "rtg_video_stream")
  expect_s3_class(vs, "ntg_media_description")
  expect_equal(vs$camera$width, 1280L)
  expect_equal(vs$camera$height, 720L)

  av <- AudioVideoPiped("audio.raw", "video.raw")
  expect_s3_class(av, "rtg_audio_video_piped")
  expect_s3_class(av, "ntg_media_description")
  expect_equal(av$microphone$input, "audio.raw")
  expect_equal(av$camera$input, "video.raw")

  ff <- FFmpegStream("song.mp3", is_video = FALSE)
  expect_s3_class(ff, "rtg_ffmpeg_stream")
  expect_s3_class(ff, "ntg_media_description")
})

test_that("MockMTProtoAdapter handles group calls", {
  adapter <- MockMTProtoAdapter$new()
  gc <- adapter$get_group_call(-1001234567890)
  expect_equal(gc$chat_id, -1001234567890)
  expect_true(gc$is_active)

  payload <- "{\"ufrag\":\"mock\"}"
  res <- adapter$join_group_call(-1001234567890, payload)
  expect_true(is.character(res))
  expect_true(grepl("mock_ufrag", res))

  adapter$edit_group_call_participant(-1001234567890, 12345L, is_muted = TRUE, volume = 50L)
  expect_equal(gc$participants[["12345"]]$is_muted, TRUE)
  expect_equal(gc$participants[["12345"]]$volume, 50L)

  adapter$leave_group_call(-1001234567890)
  expect_null(adapter$active_calls[["-1001234567890"]])
})

test_that("RTgClient full lifecycle with MockMTProtoAdapter", {
  mock_adapter <- MockMTProtoAdapter$new()
  client <- rtg_client(mtproto_adapter = mock_adapter)

  expect_true(inherits(client, "RTgClient"))
  client$start()

  stream <- AudioStream("test.raw")
  client$join_group_call(-1001234567890, stream = stream)

  expect_equal(client$get_status(-1001234567890), CallStatus$PLAYING)

  client$pause(-1001234567890)
  expect_equal(client$get_status(-1001234567890), CallStatus$PAUSED)

  client$resume(-1001234567890)
  expect_equal(client$get_status(-1001234567890), CallStatus$PLAYING)

  client$leave_call(-1001234567890)
  expect_equal(client$get_status(-1001234567890), CallStatus$STOPPED)

  client$stop()
})
