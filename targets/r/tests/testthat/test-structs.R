test_that("struct constructors create expected objects", {
  ad <- audio_description(
    media_source = MediaSource$FILE,
    sample_rate = 48000L,
    channel_count = 2L,
    input = "test.raw",
    keep_open = FALSE
  )
  expect_s3_class(ad, "ntg_audio_description")
  expect_equal(ad$media_source, MediaSource$FILE)
  expect_equal(ad$sample_rate, 48000L)
  expect_equal(ad$channel_count, 2L)
  expect_equal(ad$input, "test.raw")
  expect_equal(ad$keep_open, FALSE)

  vd <- video_description(
    media_source = MediaSource$FILE,
    width = 1280L,
    height = 720L,
    fps = 30L,
    input = "video.raw",
    keep_open = FALSE
  )
  expect_s3_class(vd, "ntg_video_description")
  expect_equal(vd$width, 1280L)
  expect_equal(vd$height, 720L)
  expect_equal(vd$fps, 30L)

  md <- media_description(
    microphone = ad,
    speaker = NULL,
    camera = vd,
    screen = NULL
  )
  expect_s3_class(md, "ntg_media_description")
  expect_equal(md$microphone$sample_rate, 48000L)
  expect_equal(md$camera$fps, 30L)

  dh <- dh_config(g = 3L, p = as.raw(c(1, 2, 3)), random = as.raw(c(4, 5, 6)))
  expect_s3_class(dh, "ntg_dh_config")
  expect_equal(dh$g, 3L)
  expect_equal(length(dh$p), 3L)

  sg <- ssrc_group(semantics = "SIM", ssrcs = list(1001L, 1002L))
  expect_s3_class(sg, "ntg_ssrc_group")
  expect_equal(sg$semantics, "SIM")

  sm <- ssrc_mapping(user_id = 123456789, ssrc = 999L)
  expect_s3_class(sm, "ntg_ssrc_mapping")
  expect_equal(sm$user_id, 123456789)
})
