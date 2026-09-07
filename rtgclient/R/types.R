GroupCall <- R6::R6Class(
  classname = "GroupCall",
  public = list(
    chat_id = NULL,
    call_id = NULL,
    access_hash = NULL,
    title = NULL,
    is_active = TRUE,
    participants = list(),
    initialize = function(chat_id, call_id = NULL, access_hash = NULL, title = NULL, is_active = TRUE) {
      self$chat_id <- chat_id
      self$call_id <- call_id
      self$access_hash <- access_hash
      self$title <- title
      self$is_active <- is_active
      self$participants <- list()
    },
    update_participant = function(user_id, is_muted = FALSE, is_speaking = FALSE, volume = 100L) {
      self$participants[[as.character(user_id)]] <- list(
        user_id = user_id,
        is_muted = is_muted,
        is_speaking = is_speaking,
        volume = volume
      )
    },
    remove_participant = function(user_id) {
      self$participants[[as.character(user_id)]] <- NULL
    }
  )
)

CallStatus <- list(
  IDLE = "idle",
  CONNECTING = "connecting",
  PLAYING = "playing",
  PAUSED = "paused",
  STOPPED = "stopped",
  ERROR = "error"
)
