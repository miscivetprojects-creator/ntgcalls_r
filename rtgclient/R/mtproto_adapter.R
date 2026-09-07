MTProtoAdapter <- R6::R6Class(
  classname = "MTProtoAdapter",
  public = list(
    initialize = function() {},
    start = function() {
      invisible(TRUE)
    },
    stop = function() {
      invisible(TRUE)
    },
    get_group_call = function(chat_id) {
      stop("get_group_call must be implemented by subclass")
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      stop("join_group_call must be implemented by subclass")
    },
    leave_group_call = function(chat_id, source = 0L) {
      stop("leave_group_call must be implemented by subclass")
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      stop("edit_group_call_participant must be implemented by subclass")
    },
    create_group_call = function(chat_id, title = "Live Voice Chat") {
      stop("create_group_call must be implemented by subclass")
    }
  )
)

MockMTProtoAdapter <- R6::R6Class(
  classname = "MockMTProtoAdapter",
  inherit = MTProtoAdapter,
  public = list(
    active_calls = list(),
    joined_payloads = list(),
    initialize = function() {
      self$active_calls <- list()
      self$joined_payloads <- list()
    },
    get_group_call = function(chat_id) {
      cid <- as.character(chat_id)
      if (is.null(self$active_calls[[cid]])) {
        self$active_calls[[cid]] <- GroupCall$new(
          chat_id = chat_id,
          call_id = 99887766L,
          access_hash = 11223344L,
          title = "Mock Voice Chat"
        )
      }
      self$active_calls[[cid]]
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      cid <- as.character(chat_id)
      self$joined_payloads[[cid]] <- join_payload
      gc <- self$get_group_call(chat_id)
      mock_response_params <- list(
        transport = list(
          fingerprint = "00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF",
          pwd = "mock_transport_password",
          ufrag = "mock_ufrag"
        ),
        ssrc = 12345678L
      )
      jsonlite::toJSON(mock_response_params, auto_unbox = TRUE)
    },
    leave_group_call = function(chat_id, source = 0L) {
      cid <- as.character(chat_id)
      self$active_calls[[cid]] <- NULL
      self$joined_payloads[[cid]] <- NULL
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      gc <- self$get_group_call(chat_id)
      gc$update_participant(participant_id, is_muted = is_muted, volume = volume)
      invisible(TRUE)
    },
    create_group_call = function(chat_id, title = "Live Voice Chat") {
      cid <- as.character(chat_id)
      gc <- GroupCall$new(
        chat_id = chat_id,
        call_id = 12345678L,
        access_hash = 87654321L,
        title = title
      )
      self$active_calls[[cid]] <- gc
      gc
    }
  )
)

PyrogramAdapter <- R6::R6Class(
  classname = "PyrogramAdapter",
  inherit = MTProtoAdapter,
  public = list(
    client = NULL,
    session_string = NULL,
    api_id = NULL,
    api_hash = NULL,
    initialize = function(client = NULL, session_string = NULL, api_id = NULL, api_hash = NULL) {
      self$client <- client
      self$session_string <- session_string
      self$api_id <- api_id
      self$api_hash <- api_hash
    },
    start = function() {
      if (!is.null(self$client) && is.function(self$client$start)) {
        self$client$start()
      }
      invisible(TRUE)
    },
    stop = function() {
      if (!is.null(self$client) && is.function(self$client$stop)) {
        self$client$stop()
      }
      invisible(TRUE)
    },
    get_group_call = function(chat_id) {
      if (is.null(self$client)) {
        stop("Pyrogram client is not initialized")
      }
      call_data <- self$client$invoke(
        raw_name = "phone.GetGroupCall",
        chat_id = chat_id
      )
      GroupCall$new(
        chat_id = chat_id,
        call_id = call_data$call$id,
        access_hash = call_data$call$access_hash,
        title = call_data$call$title
      )
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      if (is.null(self$client)) {
        stop("Pyrogram client is not initialized")
      }
      res <- self$client$invoke(
        raw_name = "phone.JoinGroupCall",
        chat_id = chat_id,
        params = list(
          data = join_payload,
          muted = is_muted,
          video_stopped = is_video_stopped
        )
      )
      res$params$data
    },
    leave_group_call = function(chat_id, source = 0L) {
      if (is.null(self$client)) {
        stop("Pyrogram client is not initialized")
      }
      self$client$invoke(
        raw_name = "phone.LeaveGroupCall",
        chat_id = chat_id,
        source = source
      )
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      if (is.null(self$client)) {
        stop("Pyrogram client is not initialized")
      }
      self$client$invoke(
        raw_name = "phone.EditGroupCallParticipant",
        chat_id = chat_id,
        participant = participant_id,
        muted = is_muted,
        volume = as.integer(volume * 100L)
      )
      invisible(TRUE)
    }
  )
)
