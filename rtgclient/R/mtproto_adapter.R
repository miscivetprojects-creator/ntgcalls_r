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
    },
    request_p2p_call = function(user_id, g_a_hash) {
      stop("request_p2p_call must be implemented by subclass")
    },
    accept_p2p_call = function(call_id, g_b, fingerprint) {
      stop("accept_p2p_call must be implemented by subclass")
    },
    confirm_p2p_call = function(call_id, g_a, fingerprint) {
      stop("confirm_p2p_call must be implemented by subclass")
    },
    discard_p2p_call = function(call_id, reason = "disconnect") {
      stop("discard_p2p_call must be implemented by subclass")
    }
  )
)

MockMTProtoAdapter <- R6::R6Class(
  classname = "MockMTProtoAdapter",
  inherit = MTProtoAdapter,
  public = list(
    active_calls = list(),
    joined_payloads = list(),
    p2p_calls = list(),
    initialize = function() {
      self$active_calls <- list()
      self$joined_payloads <- list()
      self$p2p_calls <- list()
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
    },
    request_p2p_call = function(user_id, g_a_hash) {
      uid <- as.character(user_id)
      call_id <- 55443322L
      self$p2p_calls[[uid]] <- list(
        call_id = call_id,
        user_id = user_id,
        g_a_hash = g_a_hash,
        state = "requested"
      )
      call_id
    },
    accept_p2p_call = function(call_id, g_b, fingerprint) {
      invisible(TRUE)
    },
    confirm_p2p_call = function(call_id, g_a, fingerprint) {
      invisible(TRUE)
    },
    discard_p2p_call = function(call_id, reason = "disconnect") {
      for (uid in names(self$p2p_calls)) {
        if (identical(self$p2p_calls[[uid]]$call_id, call_id)) {
          self$p2p_calls[[uid]] <- NULL
        }
      }
      invisible(TRUE)
    }
  )
)

TDLibAdapter <- R6::R6Class(
  classname = "TDLibAdapter",
  inherit = MTProtoAdapter,
  public = list(
    client_id = NULL,
    send_fn = NULL,
    receive_fn = NULL,
    initialize = function(client_id = NULL, send_fn = NULL, receive_fn = NULL) {
      self$client_id <- client_id
      self$send_fn <- send_fn
      self$receive_fn <- receive_fn
    },
    execute = function(request_data) {
      if (is.function(self$send_fn)) {
        req_json <- if (is.character(request_data)) request_data else jsonlite::toJSON(request_data, auto_unbox = TRUE)
        self$send_fn(self$client_id, req_json)
      } else {
        list(ok = TRUE)
      }
    },
    get_group_call = function(chat_id) {
      req <- list(
        `@type` = "getGroupCall",
        group_call_id = as.integer(chat_id)
      )
      res <- self$execute(req)
      GroupCall$new(
        chat_id = chat_id,
        call_id = if (!is.null(res$id)) res$id else chat_id,
        access_hash = res$access_hash,
        title = res$title
      )
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      req <- list(
        `@type` = "joinGroupCall",
        group_call_id = as.integer(chat_id),
        payload = join_payload,
        is_muted = is_muted,
        is_my_video_enabled = !is_video_stopped
      )
      res <- self$execute(req)
      if (is.character(res)) res else jsonlite::toJSON(res, auto_unbox = TRUE)
    },
    leave_group_call = function(chat_id, source = 0L) {
      req <- list(
        `@type` = "leaveGroupCall",
        group_call_id = as.integer(chat_id)
      )
      self$execute(req)
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      req_vol <- list(
        `@type` = "setGroupCallParticipantVolume",
        group_call_id = as.integer(chat_id),
        participant_id = list(`@type` = "messageSenderUser", user_id = as.integer(participant_id)),
        volume = as.integer(volume * 100L)
      )
      self$execute(req_vol)
      req_mute <- list(
        `@type` = "setGroupCallParticipantIsMuted",
        group_call_id = as.integer(chat_id),
        participant_id = list(`@type` = "messageSenderUser", user_id = as.integer(participant_id)),
        is_muted = is_muted
      )
      self$execute(req_mute)
      invisible(TRUE)
    },
    create_group_call = function(chat_id, title = "Live Voice Chat") {
      req <- list(
        `@type` = "createGroupCall",
        chat_id = as.integer(chat_id),
        title = as.character(title)
      )
      res <- self$execute(req)
      GroupCall$new(
        chat_id = chat_id,
        call_id = res$id,
        title = title
      )
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
        return(GroupCall$new(chat_id = chat_id, call_id = 998877L, access_hash = 112233L, title = "Pyrogram Voice Chat"))
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
        return(jsonlite::toJSON(list(transport = list(fingerprint = "mock_fp", pwd = "pwd", ufrag = "ufrag"), ssrc = 1001L), auto_unbox = TRUE))
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
      if (is.character(res)) res else res$params$data
    },
    leave_group_call = function(chat_id, source = 0L) {
      if (!is.null(self$client)) {
        self$client$invoke(
          raw_name = "phone.LeaveGroupCall",
          chat_id = chat_id,
          source = source
        )
      }
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      if (!is.null(self$client)) {
        self$client$invoke(
          raw_name = "phone.EditGroupCallParticipant",
          chat_id = chat_id,
          participant = participant_id,
          muted = is_muted,
          volume = as.integer(volume * 100L)
        )
      }
      invisible(TRUE)
    },
    create_group_call = function(chat_id, title = "Live Voice Chat") {
      if (!is.null(self$client)) {
        res <- self$client$invoke(
          raw_name = "phone.CreateGroupCall",
          chat_id = chat_id,
          title = title
        )
        return(GroupCall$new(chat_id = chat_id, call_id = res$call$id, access_hash = res$call$access_hash, title = title))
      }
      GroupCall$new(chat_id = chat_id, call_id = 123456L, access_hash = 654321L, title = title)
    }
  )
)

TelethonAdapter <- R6::R6Class(
  classname = "TelethonAdapter",
  inherit = MTProtoAdapter,
  public = list(
    client = NULL,
    initialize = function(client = NULL) {
      self$client <- client
    },
    start = function() {
      if (!is.null(self$client) && is.function(self$client$connect)) {
        self$client$connect()
      }
      invisible(TRUE)
    },
    stop = function() {
      if (!is.null(self$client) && is.function(self$client$disconnect)) {
        self$client$disconnect()
      }
      invisible(TRUE)
    },
    get_group_call = function(chat_id) {
      GroupCall$new(chat_id = chat_id, call_id = 998877L, access_hash = 112233L, title = "Telethon Group Call")
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      if (is.null(self$client)) {
        return(jsonlite::toJSON(list(transport = list(fingerprint = "telethon_fp", pwd = "pwd", ufrag = "ufrag"), ssrc = 2002L), auto_unbox = TRUE))
      }
      res <- self$client$invoke(chat_id, join_payload)
      if (is.character(res)) res else jsonlite::toJSON(res, auto_unbox = TRUE)
    },
    leave_group_call = function(chat_id, source = 0L) {
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      invisible(TRUE)
    }
  )
)

DirectMTProtoAdapter <- R6::R6Class(
  classname = "DirectMTProtoAdapter",
  inherit = MTProtoAdapter,
  public = list(
    dc_id = 2L,
    ip = "149.154.167.50",
    port = 443L,
    auth_key = NULL,
    session_id = NULL,
    initialize = function(dc_id = 2L, ip = "149.154.167.50", port = 443L, auth_key = NULL) {
      self$dc_id <- as.integer(dc_id)
      self$ip <- as.character(ip)
      self$port <- as.integer(port)
      self$auth_key <- auth_key
      self$session_id <- sample.int(1000000000L, 1L)
    },
    get_group_call = function(chat_id) {
      GroupCall$new(chat_id = chat_id, call_id = 887766L, access_hash = 332211L, title = "Direct MTProto Call")
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      mock_response <- list(
        transport = list(
          fingerprint = "direct_mtproto_fingerprint",
          pwd = "direct_pwd",
          ufrag = "direct_ufrag"
        ),
        ssrc = 3003L
      )
      jsonlite::toJSON(mock_response, auto_unbox = TRUE)
    },
    leave_group_call = function(chat_id, source = 0L) {
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      invisible(TRUE)
    }
  )
)
