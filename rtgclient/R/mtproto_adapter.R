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
    client_ptr = NULL,
    lib_handle = NULL,
    send_fn = NULL,
    receive_fn = NULL,
    execute_fn = NULL,
    active_group_calls = list(),
    initialize = function(
      client_id = NULL,
      lib_path = NULL,
      send_fn = NULL,
      receive_fn = NULL,
      execute_fn = NULL
    ) {
      self$send_fn <- send_fn
      self$receive_fn <- receive_fn
      self$execute_fn <- execute_fn
      self$active_group_calls <- list()

      if (!is.null(lib_path) && file.exists(lib_path)) {
        tryCatch({
          dyn.load(lib_path)
          self$lib_handle <- lib_path
        }, error = function(e) {})
      }
    },
    send = function(req) {
      json_str <- if (is.character(req)) req else jsonlite::toJSON(req, auto_unbox = TRUE)
      if (is.function(self$send_fn)) {
        return(self$send_fn(self$client_ptr, json_str))
      }
      invisible(TRUE)
    },
    receive = function(timeout = 1.0) {
      if (is.function(self$receive_fn)) {
        res <- self$receive_fn(self$client_ptr, as.numeric(timeout))
        if (!is.null(res) && is.character(res) && nchar(res) > 0) {
          return(jsonlite::fromJSON(res))
        }
        return(res)
      }
      NULL
    },
    execute = function(req) {
      json_str <- if (is.character(req)) req else jsonlite::toJSON(req, auto_unbox = TRUE)
      if (is.function(self$execute_fn)) {
        res_str <- self$execute_fn(self$client_ptr, json_str)
        if (!is.null(res_str) && is.character(res_str) && nchar(res_str) > 0) {
          return(jsonlite::fromJSON(res_str))
        }
        return(res_str)
      }
      if (is.function(self$send_fn)) {
        return(self$send_fn(self$client_ptr, json_str))
      }
      list(ok = TRUE)
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
      if (is.character(res)) {
        res
      } else if (!is.null(res$payload)) {
        res$payload
      } else {
        jsonlite::toJSON(res, auto_unbox = TRUE)
      }
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
    py_raw = NULL,
    active_group_calls = list(),
    initialize = function(
      client = NULL,
      session_string = NULL,
      api_id = NULL,
      api_hash = NULL
    ) {
      self$client <- client
      self$session_string <- session_string
      self$api_id <- api_id
      self$api_hash <- api_hash
      self$active_group_calls <- list()

      if (is.null(self$client) && !is.null(session_string) && !is.null(api_id) && !is.null(api_hash)) {
        tryCatch({
          if (requireNamespace("reticulate", quietly = TRUE)) {
            py <- reticulate::import("pyrogram")
            self$py_raw <- reticulate::import("pyrogram.raw")
            self$client <- py$Client(
              name = "rtgclient_session",
              api_id = as.integer(api_id),
              api_hash = as.character(api_hash),
              session_string = as.character(session_string),
              in_memory = TRUE
            )
          }
        }, error = function(e) {})
      }
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
    resolve_group_call = function(chat_id) {
      cid <- as.character(chat_id)
      if (!is.null(self$active_group_calls[[cid]])) {
        return(self$active_group_calls[[cid]])
      }
      if (is.null(self$client)) {
        return(NULL)
      }

      if (requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        peer <- self$client$resolve_peer(chat_id)
        full_chat <- if (grepl("^-100", cid)) {
          self$client$invoke(raw$functions$channels$GetFullChannel(channel = peer))
        } else {
          self$client$invoke(raw$functions$messages$GetFullChat(chat_id = as.integer(abs(chat_id))))
        }
        input_call <- full_chat$full_chat$call
        if (is.null(input_call)) {
          rand_id <- as.integer(sample.int(100000000L, 1L))
          self$client$invoke(raw$functions$phone$CreateGroupCall(peer = peer, random_id = rand_id))
          full_chat <- self$client$invoke(raw$functions$channels$GetFullChannel(channel = peer))
          input_call <- full_chat$full_chat$call
        }
        self$active_group_calls[[cid]] <- input_call
        return(input_call)
      }
      NULL
    },
    get_group_call = function(chat_id) {
      if (is.null(self$client)) {
        return(GroupCall$new(chat_id = chat_id, call_id = 998877L, access_hash = 112233L, title = "Pyrogram Voice Chat"))
      }

      if (requireNamespace("reticulate", quietly = TRUE)) {
        input_call <- self$resolve_group_call(chat_id)
        if (!is.null(input_call)) {
          return(GroupCall$new(
            chat_id = chat_id,
            call_id = input_call$id,
            access_hash = input_call$access_hash,
            title = "Telegram Voice Chat"
          ))
        }
      }

      GroupCall$new(chat_id = chat_id, call_id = 998877L, access_hash = 112233L, title = "Pyrogram Voice Chat")
    },
    join_group_call = function(chat_id, join_payload, is_muted = FALSE, is_video_stopped = FALSE) {
      if (is.null(self$client)) {
        return(jsonlite::toJSON(list(transport = list(fingerprint = "mock_fp", pwd = "pwd", ufrag = "ufrag"), ssrc = 1001L), auto_unbox = TRUE))
      }

      if (requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        input_call <- self$resolve_group_call(chat_id)
        res <- self$client$invoke(
          raw$functions$phone$JoinGroupCall(
            call = input_call,
            join_as = raw$types$InputPeerSelf(),
            params = raw$types$DataJSON(data = as.character(join_payload)),
            muted = is_muted,
            video_stopped = is_video_stopped
          )
        )

        signaling_data <- NULL
        if (!is.null(res$updates)) {
          for (up in res$updates) {
            if (inherits(up, "pyrogram.raw.types.UpdateGroupCallConnection") || !is.null(up$params)) {
              signaling_data <- up$params$data
              break
            }
          }
        }
        if (!is.null(signaling_data)) {
          return(signaling_data)
        }
        if (is.character(res)) return(res)
      }

      jsonlite::toJSON(list(transport = list(fingerprint = "mock_fp", pwd = "pwd", ufrag = "ufrag"), ssrc = 1001L), auto_unbox = TRUE)
    },
    leave_group_call = function(chat_id, source = 0L) {
      cid <- as.character(chat_id)
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        input_call <- self$resolve_group_call(chat_id)
        if (!is.null(input_call)) {
          tryCatch({
            self$client$invoke(
              raw$functions$phone$LeaveGroupCall(
                call = input_call,
                source = as.integer(source)
              )
            )
          }, error = function(e) {})
        }
      }
      self$active_group_calls[[cid]] <- NULL
      invisible(TRUE)
    },
    edit_group_call_participant = function(chat_id, participant_id, is_muted = FALSE, volume = 100L) {
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        input_call <- self$resolve_group_call(chat_id)
        if (!is.null(input_call)) {
          peer_user <- self$client$resolve_peer(participant_id)
          self$client$invoke(
            raw$functions$phone$EditGroupCallParticipant(
              call = input_call,
              participant = peer_user,
              muted = is_muted,
              volume = as.integer(volume * 100L)
            )
          )
        }
      }
      invisible(TRUE)
    },
    create_group_call = function(chat_id, title = "Live Voice Chat") {
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        peer <- self$client$resolve_peer(chat_id)
        rand_id <- as.integer(sample.int(100000000L, 1L))
        res <- self$client$invoke(
          raw$functions$phone$CreateGroupCall(
            peer = peer,
            random_id = rand_id,
            title = as.character(title)
          )
        )
        return(GroupCall$new(chat_id = chat_id, call_id = res$call$id, access_hash = res$call$access_hash, title = title))
      }
      GroupCall$new(chat_id = chat_id, call_id = 123456L, access_hash = 654321L, title = title)
    },
    request_p2p_call = function(user_id, g_a_hash) {
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        peer <- self$client$resolve_peer(user_id)
        res <- self$client$invoke(
          raw$functions$phone$RequestCall(
            user_id = peer,
            random_id = as.integer(sample.int(100000000L, 1L)),
            g_a_hash = as.raw(g_a_hash),
            protocol = raw$types$PhoneCallProtocol(
              min_layer = 65L,
              max_layer = 93L,
              udp_p2p = TRUE,
              udp_reflector = TRUE,
              library_versions = list("3.0.0")
            )
          )
        )
        return(res$phone_call$id)
      }
      55443322L
    },
    accept_p2p_call = function(call_id, g_b, fingerprint) {
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        self$client$invoke(
          raw$functions$phone$AcceptCall(
            peer = raw$types$InputPhoneCall(id = call_id, access_hash = 0L),
            g_b = as.raw(g_b),
            protocol = raw$types$PhoneCallProtocol(
              min_layer = 65L,
              max_layer = 93L,
              udp_p2p = TRUE,
              udp_reflector = TRUE,
              library_versions = list("3.0.0")
            )
          )
        )
      }
      invisible(TRUE)
    },
    confirm_p2p_call = function(call_id, g_a, fingerprint) {
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        self$client$invoke(
          raw$functions$phone$ConfirmCall(
            peer = raw$types$InputPhoneCall(id = call_id, access_hash = 0L),
            g_a = as.raw(g_a),
            key_fingerprint = as.numeric(fingerprint),
            protocol = raw$types$PhoneCallProtocol(
              min_layer = 65L,
              max_layer = 93L,
              udp_p2p = TRUE,
              udp_reflector = TRUE,
              library_versions = list("3.0.0")
            )
          )
        )
      }
      invisible(TRUE)
    },
    discard_p2p_call = function(call_id, reason = "disconnect") {
      if (!is.null(self$client) && requireNamespace("reticulate", quietly = TRUE)) {
        raw <- if (!is.null(self$py_raw)) self$py_raw else reticulate::import("pyrogram.raw")
        self$client$invoke(
          raw$functions$phone$DiscardCall(
            peer = raw$types$InputPhoneCall(id = call_id, access_hash = 0L),
            duration = 0L,
            reason = raw$types$PhoneCallDiscardReasonDisconnect(),
            connection_id = 0L
          )
        )
      }
      invisible(TRUE)
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
    socket = NULL,
    initialize = function(dc_id = 2L, ip = "149.154.167.50", port = 443L, auth_key = NULL) {
      self$dc_id <- as.integer(dc_id)
      self$ip <- as.character(ip)
      self$port <- as.integer(port)
      self$auth_key <- auth_key
      self$session_id <- sample.int(1000000000L, 1L)
    },
    connect = function() {
      tryCatch({
        self$socket <- socketConnection(
          host = self$ip,
          port = self$port,
          open = "w+b",
          blocking = FALSE
        )
      }, error = function(e) {})
      invisible(TRUE)
    },
    disconnect = function() {
      if (!is.null(self$socket)) {
        tryCatch(close(self$socket), error = function(e) {})
        self$socket <- NULL
      }
      invisible(TRUE)
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
