test_that("enums are properly defined", {
  expect_equal(MediaSource$UNKNOWN, 0L)
  expect_equal(MediaSource$FILE, 1L)
  expect_equal(MediaSource$SHELL, 2L)
  expect_equal(MediaSource$FFMPEG, 3L)
  expect_equal(MediaSource$DEVICE, 4L)
  expect_equal(MediaSource$DESKTOP, 5L)
  expect_equal(MediaSource$EXTERNAL, 6L)

  expect_equal(StreamType$AUDIO, 0L)
  expect_equal(StreamType$VIDEO, 1L)

  expect_equal(StreamStatus$ACTIVE, 0L)
  expect_equal(StreamStatus$PAUSED, 1L)
  expect_equal(StreamStatus$IDLING, 2L)

  expect_equal(StreamMode$CAPTURE, 0L)
  expect_equal(StreamMode$PLAYBACK, 1L)

  expect_equal(StreamDevice$MICROPHONE, 0L)
  expect_equal(StreamDevice$SPEAKER, 1L)
  expect_equal(StreamDevice$CAMERA, 2L)
  expect_equal(StreamDevice$SCREEN, 3L)

  expect_equal(ConnectionState$CONNECTING, 0L)
  expect_equal(ConnectionState$CONNECTED, 1L)
  expect_equal(ConnectionState$FAILED, 2L)
  expect_equal(ConnectionState$TIMEOUT, 3L)
  expect_equal(ConnectionState$CLOSED, 4L)

  expect_equal(ConnectionKind$NORMAL, 0L)
  expect_equal(ConnectionKind$PRESENTATION, 1L)

  expect_equal(CallType$GROUP, 0L)
  expect_equal(CallType$OUTGOING, 1L)
  expect_equal(CallType$INCOMING, 2L)
  expect_equal(CallType$P2P, 3L)
  expect_equal(CallType$CONFERENCE, 4L)

  expect_equal(ConnectionMode$NONE, 0L)
  expect_equal(ConnectionMode$RTC, 1L)
  expect_equal(ConnectionMode$STREAM, 2L)
  expect_equal(ConnectionMode$RTMP, 3L)

  expect_equal(VideoRotation$VIDEO_ROTATION_0, 0L)
  expect_equal(VideoRotation$VIDEO_ROTATION_90, 1L)
  expect_equal(VideoRotation$VIDEO_ROTATION_180, 2L)
  expect_equal(VideoRotation$VIDEO_ROTATION_270, 3L)
})
