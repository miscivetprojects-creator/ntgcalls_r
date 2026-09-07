CallParticipant <- R6::R6Class(
  classname = "CallParticipant",
  public = list(
    user_id = NULL,
    is_muted = FALSE,
    is_speaking = FALSE,
    volume = 100L,
    is_video_active = FALSE,
    is_screen_active = FALSE,
    source = 0L,
    initialize = function(
      user_id,
      is_muted = FALSE,
      is_speaking = FALSE,
      volume = 100L,
      is_video_active = FALSE,
      is_screen_active = FALSE,
      source = 0L
    ) {
      self$user_id <- user_id
      self$is_muted <- is_muted
      self$is_speaking <- is_speaking
      self$volume <- as.integer(volume)
      self$is_video_active <- is_video_active
      self$is_screen_active <- is_screen_active
      self$source <- as.integer(source)
    }
  )
)

GroupCall <- R6::R6Class(
  classname = "GroupCall",
  public = list(
    chat_id = NULL,
    call_id = NULL,
    access_hash = NULL,
    title = NULL,
    is_active = TRUE,
    participants = list(),
    connection_mode = "rtc",
    initialize = function(
      chat_id,
      call_id = NULL,
      access_hash = NULL,
      title = NULL,
      is_active = TRUE,
      connection_mode = "rtc"
    ) {
      self$chat_id <- chat_id
      self$call_id <- call_id
      self$access_hash <- access_hash
      self$title <- title
      self$is_active <- is_active
      self$participants <- list()
      self$connection_mode <- connection_mode
    },
    update_participant = function(
      user_id,
      is_muted = FALSE,
      is_speaking = FALSE,
      volume = 100L,
      is_video_active = FALSE,
      is_screen_active = FALSE,
      source = 0L
    ) {
      p <- CallParticipant$new(
        user_id = user_id,
        is_muted = is_muted,
        is_speaking = is_speaking,
        volume = volume,
        is_video_active = is_video_active,
        is_screen_active = is_screen_active,
        source = source
      )
      self$participants[[as.character(user_id)]] <- p
      p
    },
    remove_participant = function(user_id) {
      self$participants[[as.character(user_id)]] <- NULL
      invisible(TRUE)
    },
    get_participant = function(user_id) {
      self$participants[[as.character(user_id)]]
    }
  )
)

P2PSession <- R6::R6Class(
  classname = "P2PSession",
  public = list(
    user_id = NULL,
    is_outgoing = TRUE,
    dh_config = NULL,
    auth_key = NULL,
    key_fingerprint = NULL,
    rtc_servers = list(),
    state = "idle",
    initialize = function(
      user_id,
      is_outgoing = TRUE,
      dh_config = NULL,
      auth_key = NULL,
      key_fingerprint = NULL,
      rtc_servers = list()
    ) {
      self$user_id <- user_id
      self$is_outgoing <- is_outgoing
      self$dh_config <- dh_config
      self$auth_key <- auth_key
      self$key_fingerprint <- key_fingerprint
      self$rtc_servers <- rtc_servers
      self$state <- "idle"
    }
  )
)

CallStatus <- list(
  IDLE = "idle",
  CONNECTING = "connecting",
  PLAYING = "playing",
  PAUSED = "paused",
  STOPPED = "stopped",
  FAILED = "failed",
  ERROR = "error"
)
