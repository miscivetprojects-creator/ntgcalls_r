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

  cs <- CustomStream(microphone = as$microphone, camera = vs$camera)
  expect_s3_class(cs, "rtg_custom_stream")
  expect_s3_class(cs, "ntg_media_description")
})

test_that("schema models and participant tracking work properly", {
  gc <- GroupCall$new(chat_id = -1001234567890, title = "Test Voice Chat")
  expect_equal(gc$chat_id, -1001234567890)
  expect_equal(gc$title, "Test Voice Chat")
  expect_true(gc$is_active)

  p <- gc$update_participant(user_id = 112233L, is_muted = FALSE, volume = 85L)
  expect_s3_class(p, "CallParticipant")
  expect_equal(p$user_id, 112233L)
  expect_equal(p$volume, 85L)

  p_get <- gc$get_participant(112233L)
  expect_equal(p_get$volume, 85L)

  gc$remove_participant(112233L)
  expect_null(gc$get_participant(112233L))

  p2p_sess <- P2PSession$new(user_id = 998877L, is_outgoing = TRUE)
  expect_s3_class(p2p_sess, "P2PSession")
  expect_equal(p2p_sess$user_id, 998877L)
  expect_equal(p2p_sess$state, "idle")
})

test_that("MockMTProtoAdapter handles group calls and p2p calls", {
  adapter <- MockMTProtoAdapter$new()
  gc <- adapter$get_group_call(-1001234567890)
  expect_equal(gc$chat_id, -1001234567890)
  expect_true(gc$is_active)

  payload <- "{\"ufrag\":\"mock\"}"
  res <- adapter$join_group_call(-1001234567890, payload)
  expect_true(is.character(res))
  expect_true(grepl("mock_ufrag", res))

  adapter$edit_group_call_participant(-1001234567890, 12345L, is_muted = TRUE, volume = 50L)
  p <- gc$get_participant(12345L)
  expect_equal(p$is_muted, TRUE)
  expect_equal(p$volume, 50L)

  call_id <- adapter$request_p2p_call(554433L, as.raw(c(1, 2, 3)))
  expect_equal(call_id, 55443322L)

  adapter$discard_p2p_call(call_id)
  expect_null(adapter$p2p_calls[["554433"]])

  adapter$leave_group_call(-1001234567890)
  expect_null(adapter$active_calls[["-1001234567890"]])
})

test_that("TDLibAdapter formats JSON requests properly", {
  last_req <- NULL
  mock_send <- function(client_id, json_str) {
    last_req <<- jsonlite::fromJSON(json_str)
    list(ok = TRUE, id = 987654L, title = "TDLib Call")
  }
  tdlib <- TDLibAdapter$new(client_id = 1L, send_fn = mock_send)
  expect_s3_class(tdlib, "TDLibAdapter")

  gc <- tdlib$get_group_call(-100998877L)
  expect_equal(last_req$`@type`, "getGroupCall")
  expect_equal(gc$chat_id, -100998877L)

  tdlib$join_group_call(-100998877L, "{\"ufrag\":\"tdlib\"}", is_muted = FALSE)
  expect_equal(last_req$`@type`, "joinGroupCall")

  tdlib$edit_group_call_participant(-100998877L, 443322L, is_muted = TRUE, volume = 75L)
  expect_equal(last_req$`@type`, "setGroupCallParticipantIsMuted")

  tdlib$leave_group_call(-100998877L)
  expect_equal(last_req$`@type`, "leaveGroupCall")
})

test_that("PyrogramAdapter and TelethonAdapter provide MTProto interfaces", {
  pyro <- PyrogramAdapter$new()
  expect_s3_class(pyro, "PyrogramAdapter")
  gc_pyro <- pyro$get_group_call(-100554433L)
  expect_equal(gc_pyro$chat_id, -100554433L)
  res_pyro <- pyro$join_group_call(-100554433L, "{}")
  expect_true(is.character(res_pyro))

  tele <- TelethonAdapter$new()
  expect_s3_class(tele, "TelethonAdapter")
  gc_tele <- tele$get_group_call(-100665544L)
  expect_equal(gc_tele$chat_id, -100665544L)
  res_tele <- tele$join_group_call(-100665544L, "{}")
  expect_true(is.character(res_tele))

  direct <- DirectMTProtoAdapter$new(dc_id = 2L)
  expect_s3_class(direct, "DirectMTProtoAdapter")
  expect_equal(direct$dc_id, 2L)
  gc_direct <- direct$get_group_call(-100776655L)
  expect_equal(gc_direct$chat_id, -100776655L)
})

test_that("P2PCallManager executes Diffie-Hellman flow", {
  mock_adapter <- MockMTProtoAdapter$new()
  client <- rtg_client(mtproto_adapter = mock_adapter)
  p2p_mgr <- client$p2p
  expect_s3_class(p2p_mgr, "P2PCallManager")

  res <- p2p_mgr$start_call(99887766L)
  expect_equal(res$call_id, 55443322L)
  expect_equal(res$session$state, "exchanging_keys")

  p2p_mgr$discard_call(99887766L)
  expect_null(p2p_mgr$get_session(99887766L))
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
