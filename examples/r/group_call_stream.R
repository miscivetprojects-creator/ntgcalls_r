library(ntgcalls)

run_group_call_example <- function() {
  cat("=== NTgCalls Group Call Streaming Example ===\n\n")

  audio_desc <- audio_description(
    input = "audio.raw",
    media_source = MediaSource$FILE,
    sample_rate = 48000L,
    channel_count = 2L,
    keep_open = FALSE
  )

  video_desc <- video_description(
    input = "video.raw",
    media_source = MediaSource$FILE,
    width = 1280L,
    height = 720L,
    fps = 30L,
    keep_open = FALSE
  )

  media_desc <- media_description(
    microphone = audio_desc,
    camera = video_desc
  )

  cat("Configured media description:\n")
  cat("  Audio input:", audio_desc$input, "at", audio_desc$sample_rate, "Hz\n")
  cat("  Video input:", video_desc$input, sprintf("(%dx%d @ %dfps)\n\n", video_desc$width, video_desc$height, video_desc$fps))

  tryCatch(
    {
      client <- ntgcalls()
      chat_id <- -1001234567890

      client$on("connection_change", function(evt) {
        cat(sprintf("[Event] Chat %s state = %d\n", evt$chat_id, evt$state$state))
      })

      client$on("upgrade", function(evt) {
        cat(sprintf("[Event] Chat %s upgrade: muted = %s\n", evt$chat_id, evt$state$muted))
      })

      cat("Connecting to call on chat:", chat_id, "...\n")
      client$process_events()
      client$destroy()
    },
    error = function(e) {
      cat("[Notice] Standalone example mode:\n")
      cat("  ", conditionMessage(e), "\n")
      cat("  To link with native WebRTC core, set NTGCALLS_LIB_PATH environment variable to libntgcalls.\n")
    }
  )
}

run_group_call_example()
