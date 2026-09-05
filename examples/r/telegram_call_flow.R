library(ntgcalls)

generate_pcm_audio <- function(file_path, duration_sec = 2, sample_rate = 48000, freq = 440) {
  total_samples <- duration_sec * sample_rate
  t <- seq(0, duration_sec, length.out = total_samples)
  signal <- sin(2 * pi * freq * t)
  pcm_int16 <- as.integer(signal * 32767)
  stereo_interleaved <- matrix(rbind(pcm_int16, pcm_int16), ncol = 1)
  raw_bytes <- writeBin(as.vector(stereo_interleaved), raw(), size = 2, endian = "little")
  con <- file(file_path, "wb")
  writeBin(raw_bytes, con)
  close(con)
}

run_telegram_flow <- function() {
  cat("=== Real Telegram Call Update Flow Example ===\n\n")

  pcm_path <- file.path(tempdir(), "test_stream_audio.raw")
  generate_pcm_audio(pcm_path, duration_sec = 2)
  cat(sprintf("[1] Generated 48kHz Stereo PCM audio test file at: %s\n", pcm_path))

  chat_id <- -1001234567890

  audio_desc <- audio_description(
    input = pcm_path,
    media_source = MediaSource$FILE,
    sample_rate = 48000L,
    channel_count = 2L,
    keep_open = FALSE
  )

  media_desc <- media_description(
    microphone = audio_desc
  )

  tryCatch(
    {
      client <- ntgcalls()
      cat("[2] Initialized NTgCalls WebRTC engine version:", client$get_version(), "\n")

      client$on("connection_change", function(evt) {
        cat(sprintf("[Event] Telegram Connection state changed -> State: %d for Chat: %s\n", evt$state$state, evt$chat_id))
      })

      client$on("upgrade", function(evt) {
        cat(sprintf("[Event] Stream upgrade update: muted = %s\n", evt$state$muted))
      })

      client$on("stream_end", function(evt) {
        cat(sprintf("[Event] Stream playback ended for chat %s\n", evt$chat_id))
      })

      cat("[3] Generating Telegram join group call payload via client$create_call()...\n")
      join_payload <- client$create_call(chat_id)
      cat("    Outgoing MTProto phone.joinGroupCall payload (first 100 chars):\n    ", substr(join_payload, 1, 100), "...\n\n")

      cat("[4] Simulating Telegram MTProto phone.joinGroupCall response update...\n")
      cat("[5] Configuring audio media stream on chat", chat_id, "...\n")
      client$set_stream_sources(chat_id, StreamMode$AUDIO, media_desc)

      cat("[6] Controlling stream playback (mute, unmute, state inspection)...\n")
      is_muted <- client$mute(chat_id)
      cat("    Call mute applied:", is_muted, "\n")
      is_unmuted <- client$unmute(chat_id)
      cat("    Call unmute applied:", is_unmuted, "\n")

      state <- client$get_state(chat_id)
      cat("    Current call media state -> Muted:", state$muted, "| Video Paused:", state$video_paused, "\n")

      call_type <- client$get_call_type(chat_id)
      cat("    Active call type identifier:", call_type, "\n")

      cat("[7] Polling internal WebRTC event dispatcher...\n")
      client$process_events()

      cat("[8] Gracefully stopping call and releasing WebRTC instance...\n")
      client$stop(chat_id)
      client$destroy()

      if (file.exists(pcm_path)) {
        unlink(pcm_path)
      }

      cat("\nTelegram Call Update workflow completed successfully.\n")
    },
    error = function(e) {
      if (file.exists(pcm_path)) {
        unlink(pcm_path)
      }
      cat("[Notice] Standalone example mode:\n")
      cat("  ", conditionMessage(e), "\n")
      cat("  To link with native WebRTC core, set NTGCALLS_LIB_PATH environment variable to libntgcalls.\n")
    }
  )
}

run_telegram_flow()
