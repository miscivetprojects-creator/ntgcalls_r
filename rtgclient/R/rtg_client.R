RTgClient <- R6::R6Class(
  classname = "RTgClient",
  public = list(
    mtproto = NULL,
    ntgcalls = NULL,
    active_calls = list(),
    call_statuses = list(),
    handlers = list(
      stream_end = list(),
      upgrade = list(),
      connection_change = list()
    ),
    initialize = function(
      mtproto_adapter = NULL,
      ntgcalls_instance = NULL
    ) {
      if (is.null(mtproto_adapter)) {
        self$mtproto <- MockMTProtoAdapter$new()
      } else {
        self$mtproto <- mtproto_adapter
      }

      if (is.null(ntgcalls_instance)) {
        self$ntgcalls <- ntgcalls::ntgcalls()
      } else {
        self$ntgcalls <- ntgcalls_instance
      }

      self$active_calls <- list()
      self$call_statuses <- list()

      if (!is.null(self$ntgcalls) && is.function(self$ntgcalls$on)) {
        self$ntgcalls$on("stream_end", function(ev) {
          chat_id <- ev$chat_id
          type <- ev$type
          device <- ev$device
          for (h in self$handlers$stream_end) {
            tryCatch(h(chat_id, type, device), error = function(e) {})
          }
        })

        self$ntgcalls$on("connection_change", function(ev) {
          chat_id <- ev$chat_id
          state <- ev$state
          for (h in self$handlers$connection_change) {
            tryCatch(h(chat_id, state), error = function(e) {})
          }
        })

        self$ntgcalls$on("upgrade", function(ev) {
          chat_id <- ev$chat_id
          state <- ev$state
          for (h in self$handlers$upgrade) {
            tryCatch(h(chat_id, state), error = function(e) {})
          }
        })
      }
    },
    start = function() {
      self$mtproto$start()
      invisible(self)
    },
    stop = function() {
      for (cid in names(self$active_calls)) {
        tryCatch(self$leave_call(as.numeric(cid)), error = function(e) {})
      }
      self$mtproto$stop()
      invisible(self)
    },
    join_group_call = function(
      chat_id,
      stream = NULL,
      is_muted = FALSE,
      is_video_stopped = FALSE
    ) {
      cid <- as.character(chat_id)
      join_payload <- self$ntgcalls$create_call(chat_id)

      remote_json <- self$mtproto$join_group_call(
        chat_id = chat_id,
        join_payload = join_payload,
        is_muted = is_muted,
        is_video_stopped = is_video_stopped
      )

      if (!is.null(remote_json) && nchar(remote_json) > 0) {
        tryCatch(
          self$ntgcalls$connect(chat_id, remote_json, FALSE),
          error = function(e) {}
        )
      }

      if (!is.null(stream)) {
        self$ntgcalls$set_stream_sources(
          chat_id = chat_id,
          mode = ntgcalls::StreamMode$CAPTURE,
          media = stream
        )
      }

      self$active_calls[[cid]] <- TRUE
      self$call_statuses[[cid]] <- CallStatus$PLAYING
      invisible(TRUE)
    },
    play = function(chat_id, stream) {
      cid <- as.character(chat_id)
      if (is.null(self$active_calls[[cid]])) {
        self$join_group_call(chat_id, stream = stream)
      } else {
        self$ntgcalls$set_stream_sources(
          chat_id = chat_id,
          mode = ntgcalls::StreamMode$CAPTURE,
          media = stream
        )
        self$call_statuses[[cid]] <- CallStatus$PLAYING
      }
      invisible(TRUE)
    },
    pause = function(chat_id) {
      cid <- as.character(chat_id)
      res <- self$ntgcalls$pause(chat_id)
      self$call_statuses[[cid]] <- CallStatus$PAUSED
      res
    },
    resume = function(chat_id) {
      cid <- as.character(chat_id)
      res <- self$ntgcalls$resume(chat_id)
      self$call_statuses[[cid]] <- CallStatus$PLAYING
      res
    },
    mute = function(chat_id) {
      self$ntgcalls$mute(chat_id)
    },
    unmute = function(chat_id) {
      self$ntgcalls$unmute(chat_id)
    },
    change_volume = function(chat_id, participant_id, volume = 100L) {
      self$mtproto$edit_group_call_participant(
        chat_id = chat_id,
        participant_id = participant_id,
        volume = as.integer(volume)
      )
    },
    leave_call = function(chat_id) {
      cid <- as.character(chat_id)
      tryCatch(self$ntgcalls$stop(chat_id), error = function(e) {})
      tryCatch(self$mtproto$leave_group_call(chat_id), error = function(e) {})
      self$active_calls[[cid]] <- NULL
      self$call_statuses[[cid]] <- CallStatus$STOPPED
      invisible(TRUE)
    },
    get_status = function(chat_id) {
      cid <- as.character(chat_id)
      st <- self$call_statuses[[cid]]
      if (is.null(st)) CallStatus$IDLE else st
    },
    on_stream_end = function(handler) {
      if (is.function(handler)) {
        self$handlers$stream_end <- c(self$handlers$stream_end, list(handler))
      }
      invisible(self)
    },
    on_upgrade = function(handler) {
      if (is.function(handler)) {
        self$handlers$upgrade <- c(self$handlers$upgrade, list(handler))
      }
      invisible(self)
    },
    on_connection_change = function(handler) {
      if (is.function(handler)) {
        self$handlers$connection_change <- c(self$handlers$connection_change, list(handler))
      }
      invisible(self)
    }
  )
)

RTgCalls <- RTgClient

rtg_client <- function(mtproto_adapter = NULL, ntgcalls_instance = NULL) {
  RTgClient$new(
    mtproto_adapter = mtproto_adapter,
    ntgcalls_instance = ntgcalls_instance
  )
}

rtg_calls <- function(mtproto_adapter = NULL, ntgcalls_instance = NULL) {
  rtg_client(
    mtproto_adapter = mtproto_adapter,
    ntgcalls_instance = ntgcalls_instance
  )
}
