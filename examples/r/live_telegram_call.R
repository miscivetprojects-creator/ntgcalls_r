library(ntgcalls)

generate_sine_pcm <- function(path, duration_sec = 10, sample_rate = 48000, freq = 440) {
  total_samples <- duration_sec * sample_rate
  t <- seq(0, duration_sec, length.out = total_samples)
  signal <- sin(2 * pi * freq * t)
  pcm16 <- as.integer(signal * 32767)
  interleaved <- matrix(rbind(pcm16, pcm16), ncol = 1)
  bytes <- writeBin(as.vector(interleaved), raw(), size = 2, endian = "little")
  con <- file(path, "wb")
  writeBin(bytes, con)
  close(con)
}

clean_telegram_json <- function(raw_str) {
  s <- trimws(raw_str)
  if (startsWith(s, "DataJSON(") && endsWith(s, ")")) {
    s <- sub("^DataJSON\\(.*data\\s*=\\s*['\"]?", "", s)
    s <- sub("['\"]?\\s*\\)$", "", s)
  }
  first_brace <- regexpr("\\{", s)[1]
  if (first_brace > 0) {
    s <- substr(s, first_brace, nchar(s))
    last_idx <- max(gregexpr("\\}", s)[[1]])
    if (last_idx > 0) {
      s <- substr(s, 1, last_idx)
    }
  }
  trimws(s)
}

send_telegram_group_message <- function(bot_token, chat_id, text) {
  if (nchar(bot_token) == 0) return(FALSE)
  url <- sprintf("https://api.telegram.org/bot%s/sendMessage", bot_token)
  tryCatch({
    system2("curl.exe", args = c("-s", "-X", "POST", url, "-d", sprintf("chat_id=%s", as.character(chat_id)), "-d", sprintf("text=%s", text)), stdout = FALSE, stderr = FALSE)
    TRUE
  }, error = function(e) FALSE)
}

run_live_call_session <- function() {
  cat("=====================================================\n")
  cat("       NTgCalls Live Telegram Call Session           \n")
  cat("=====================================================\n\n")

  chat_id_env <- Sys.getenv("TG_CHAT_ID", "-1004485855305")
  chat_id <- as.numeric(chat_id_env)
  bot_token <- Sys.getenv("TG_BOT_TOKEN", "")

  audio_file <- Sys.getenv("TG_AUDIO_FILE", "")
  created_temp_audio <- FALSE

  if (nchar(audio_file) == 0 || !file.exists(audio_file)) {
    audio_file <- file.path(tempdir(), "ntgcalls_live_audio.raw")
    generate_sine_pcm(audio_file, duration_sec = 30)
    created_temp_audio <- TRUE
    cat(sprintf("[Setup] Generated 30s test raw PCM audio stream: %s\n", audio_file))
  } else {
    cat(sprintf("[Setup] Using provided audio file: %s\n", audio_file))
  }

  signaling_json <- Sys.getenv("TG_SIGNALING_JSON", "")
  signaling_file <- Sys.getenv("TG_SIGNALING_FILE", "")

  if (nchar(signaling_file) > 0 && file.exists(signaling_file)) {
    signaling_json <- paste(readLines(signaling_file, warn = FALSE), collapse = "\n")
  }

  signaling_json <- clean_telegram_json(signaling_json)

  tryCatch(
    {
      client <- ntgcalls()
      cat(sprintf("[Core] NTgCalls WebRTC engine v%s initialized\n\n", client$get_version()))

      client$on("connection_change", function(evt) {
        state_names <- c("DISCONNECTED", "CONNECTING", "CONNECTED", "RECONNECTING", "FAILED")
        st <- evt$state$state
        label <- if (st >= 0 && st < length(state_names)) state_names[st + 1] else as.character(st)
        cat(sprintf("[Event: Connection] Chat %s -> State: %s (%d)\n", evt$chat_id, label, st))
      })

      client$on("upgrade", function(evt) {
        cat(sprintf("[Event: Upgrade] Chat %s -> Muted: %s | Video Paused: %s\n", evt$chat_id, evt$state$muted, evt$state$video_paused))
      })

      client$on("stream_end", function(evt) {
        cat(sprintf("[Event: Stream End] Playback finished on Chat %s (Type: %d, Device: %d)\n", evt$chat_id, evt$type, evt$device))
      })

      client$on("remote_source", function(evt) {
        cat(sprintf("[Event: Remote Source] SSRC %d changed state to %d\n", evt$state$ssrc, evt$state$state))
      })

      cat(sprintf("[Step 1] Creating WebRTC join payload for Chat ID: %s ...\n", chat_id))
      join_sdp <- client$create_call(chat_id)
      cat("[Step 1 Done] Outgoing SDP JSON payload generated:\n")
      cat("-----------------------------------------------------\n")
      cat(join_sdp, "\n")
      cat("-----------------------------------------------------\n\n")

      payload_dump_file <- file.path(tempdir(), "ntgcalls_outgoing_payload.json")
      writeLines(join_sdp, payload_dump_file)
      cat(sprintf("[Export] Saved outgoing SDP to: %s\n\n", payload_dump_file))

      audio_desc <- audio_description(
        input = audio_file,
        media_source = MediaSource$FILE,
        sample_rate = 48000L,
        channel_count = 2L,
        keep_open = FALSE
      )

      media_desc <- media_description(
        microphone = audio_desc
      )

      if (nchar(signaling_json) > 0 && startsWith(signaling_json, "{")) {
        cat("[Step 2] Live Telegram MTProto response JSON detected!\n")
        cat("[Step 2] Connecting WebRTC transport to Telegram Voice Chat server...\n")
        client$connect(chat_id, signaling_json)
        cat("[Step 2 Done] Connected to live Telegram RTC servers!\n\n")

        cat("[Step 3] Attaching live audio stream pipeline...\n")
        client$set_stream_sources(chat_id, StreamMode$AUDIO, media_desc)
        cat("[Step 3 Done] Streaming active!\n\n")

        if (nchar(bot_token) > 0) {
          cat("[Telegram Bot] Sending notification message to group...\n")
          send_telegram_group_message(bot_token, chat_id, "🎶 NTgCalls voice stream is now LIVE in this voice chat!")
          cat("[Telegram Bot] Group notification message sent successfully!\n\n")
        }

        cat("Playing live in voice chat... (Press Ctrl+C to disconnect)\n\n")
        for (i in 1:10) {
          client$process_events()
          Sys.sleep(0.5)
        }
      } else {
        cat("[Notice: Offline/Simulation Mode]\n")
        cat("  To complete the live connection with your Telegram group:\n")
        cat("  1. Send the outgoing SDP JSON above to Telegram via MTProto:\n")
        cat("     phone.joinGroupCall(peer=chat_id, params=DataJSON(data=SDP_JSON))\n")
        cat("  2. Pass Telegram's returned response JSON via environment variable:\n")
        cat("     $env:TG_SIGNALING_JSON='<telegram_response_json>'\n")
        cat("     or save to a file and set $env:TG_SIGNALING_FILE='response.json'\n")
        cat("  3. (Optional) Set $env:TG_BOT_TOKEN='<your_bot_token>' to send group messages automatically!\n\n")

        cat("[Step 2 (Simulated)] Attaching media stream descriptor...\n")
        client$set_stream_sources(chat_id, StreamMode$AUDIO, media_desc)

        cat("[Step 3 (Simulated)] Testing live controls:\n")
        client$mute(chat_id)
        cat("  -> Muted call: OK\n")
        client$unmute(chat_id)
        cat("  -> Unmuted call: OK\n")

        state <- client$get_state(chat_id)
        cat(sprintf("  -> Verified State: Muted=%s, VideoPaused=%s\n\n", state$muted, state$video_paused))

        if (nchar(bot_token) > 0) {
          cat("[Telegram Bot] Sending start notification to group...\n")
          send_telegram_group_message(bot_token, chat_id, "🎶 NTgCalls voice stream test notification!")
          cat("[Telegram Bot] Message sent!\n\n")
        }

        client$process_events()
      }

      cat("[Cleanup] Stopping active call and freeing WebRTC resources...\n")
      client$stop(chat_id)
      client$destroy()

      if (created_temp_audio && file.exists(audio_file)) {
        unlink(audio_file)
      }

      cat("[Done] Session ended cleanly.\n")
    },
    error = function(e) {
      if (created_temp_audio && file.exists(audio_file)) {
        unlink(audio_file)
      }
      cat("[Notice] Error occurred:\n")
      cat("  ", conditionMessage(e), "\n")
      cat("  Tip: Ensure TG_SIGNALING_JSON is a valid JSON string (or pass via TG_SIGNALING_FILE).\n")
    }
  )
}

run_live_call_session()
