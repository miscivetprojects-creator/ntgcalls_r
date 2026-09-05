test_that("media and description objects can be constructed", {
  aud <- audio_description("test.raw", sample_rate = 48000L, channel_count = 2L)
  expect_s3_class(aud, "ntg_audio_description")
  expect_equal(aud$input, "test.raw")
  expect_equal(aud$sample_rate, 48000L)
  expect_equal(aud$channel_count, 2L)

  vid <- video_description("video.raw", width = 1280L, height = 720L, fps = 30L)
  expect_s3_class(vid, "ntg_video_description")
  expect_equal(vid$input, "video.raw")
  expect_equal(vid$width, 1280L)
  expect_equal(vid$height, 720L)

  med <- media_description(microphone = aud, camera = vid)
  expect_s3_class(med, "ntg_media_description")
  expect_equal(med$microphone$input, "test.raw")
  expect_equal(med$camera$input, "video.raw")
})

test_that("data structures and enums validate properly", {
  srv <- rtc_server(
    id = 1,
    ipv4 = "127.0.0.1",
    ipv6 = "::1",
    port = 3478L,
    turn = TRUE,
    stun = TRUE
  )
  expect_s3_class(srv, "ntg_rtc_server")
  expect_equal(srv$port, 3478L)
  expect_true(srv$turn)
  expect_true(srv$stun)

  dh <- dh_config(g = 3L, p = charToRaw("prime"), random = charToRaw("rand"))
  expect_s3_class(dh, "ntg_dh_config")
  expect_equal(dh$g, 3L)

  grp <- ssrc_group("SIM", c(100L, 101L))
  expect_s3_class(grp, "ntg_ssrc_group")
  expect_equal(grp$semantics, "SIM")
  expect_equal(length(grp$ssrcs), 2L)

  map <- ssrc_mapping(user_id = 12345, ssrc = 999L)
  expect_s3_class(map, "ntg_ssrc_mapping")
  expect_equal(map$ssrc, 999L)

  fd <- frame_data(absolute_capture_timestamp_ms = 1000, rotation = VideoRotation$ROTATION_0, width = 1920L, height = 1080L)
  expect_s3_class(fd, "ntg_frame_data")
  expect_equal(fd$width, 1920L)

  f <- frame(ssrc = 555, data = charToRaw("frame_bytes"), frame_data = fd)
  expect_s3_class(f, "ntg_frame")
  expect_equal(f$ssrc, 555)
})
