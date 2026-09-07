P2PCallManager <- R6::R6Class(
  classname = "P2PCallManager",
  public = list(
    ntgcalls = NULL,
    mtproto = NULL,
    sessions = list(),
    initialize = function(ntgcalls_instance, mtproto_adapter) {
      self$ntgcalls <- ntgcalls_instance
      self$mtproto <- mtproto_adapter
      self$sessions <- list()
    },
    start_call = function(user_id, dh_config = NULL) {
      uid <- as.character(user_id)
      self$ntgcalls$create_p2p_call(user_id)

      dh <- if (!is.null(dh_config)) {
        dh_config
      } else {
        ntgcalls::dh_config(
          g = 3L,
          p = as.raw(c(1, 2, 3, 4)),
          random = as.raw(c(5, 6, 7, 8))
        )
      }

      ga_hash <- as.raw(c(9, 10, 11, 12))
      ga <- self$ntgcalls$init_exchange(user_id, dh, ga_hash)

      sess <- P2PSession$new(
        user_id = user_id,
        is_outgoing = TRUE,
        dh_config = dh
      )
      sess$state <- "exchanging_keys"
      self$sessions[[uid]] <- sess

      call_id <- self$mtproto$request_p2p_call(user_id, ga_hash)
      list(call_id = call_id, g_a = ga, session = sess)
    },
    exchange_keys = function(user_id, g_b, fingerprint) {
      uid <- as.character(user_id)
      auth_params <- self$ntgcalls$exchange_keys(user_id, g_b, fingerprint)
      if (!is.null(self$sessions[[uid]])) {
        self$sessions[[uid]]$auth_key <- auth_params$g_a_or_b
        self$sessions[[uid]]$key_fingerprint <- auth_params$key_fingerprint
        self$sessions[[uid]]$state <- "keys_exchanged"
      }
      auth_params
    },
    connect_p2p = function(
      user_id,
      servers = list(),
      versions = list("3.0.0"),
      p2p_allowed = TRUE,
      custom_parameters = NULL
    ) {
      uid <- as.character(user_id)
      self$ntgcalls$connect_p2p(
        user_id = user_id,
        servers = servers,
        versions = versions,
        p2p_allowed = p2p_allowed,
        custom_parameters = custom_parameters
      )
      if (!is.null(self$sessions[[uid]])) {
        self$sessions[[uid]]$state <- "connected"
      }
      invisible(TRUE)
    },
    discard_call = function(user_id, reason = "disconnect") {
      uid <- as.character(user_id)
      tryCatch(self$ntgcalls$stop(user_id), error = function(e) {})
      if (!is.null(self$sessions[[uid]])) {
        self$sessions[[uid]]$state <- "discarded"
        self$sessions[[uid]] <- NULL
      }
      invisible(TRUE)
    },
    get_session = function(user_id) {
      self$sessions[[as.character(user_id)]]
    }
  )
)

GroupCallManager <- R6::R6Class(
  classname = "GroupCallManager",
  public = list(
    ntgcalls = NULL,
    mtproto = NULL,
    active_calls = list(),
    initialize = function(ntgcalls_instance, mtproto_adapter) {
      self$ntgcalls <- ntgcalls_instance
      self$mtproto <- mtproto_adapter
      self$active_calls <- list()
    },
    join = function(chat_id, stream = NULL, is_muted = FALSE, is_video_stopped = FALSE) {
      cid <- as.character(chat_id)
      join_payload <- self$ntgcalls$create_call(chat_id)
      remote_json <- self$mtproto$join_group_call(
        chat_id = chat_id,
        join_payload = join_payload,
        is_muted = is_muted,
        is_video_stopped = is_video_stopped
      )
      if (!is.null(remote_json) && nchar(remote_json) > 0) {
        tryCatch(self$ntgcalls$connect(chat_id, remote_json, FALSE), error = function(e) {})
      }
      if (!is.null(stream)) {
        self$ntgcalls$set_stream_sources(
          chat_id = chat_id,
          mode = ntgcalls::StreamMode$CAPTURE,
          media = stream
        )
      }
      self$active_calls[[cid]] <- TRUE
      invisible(TRUE)
    },
    leave = function(chat_id) {
      cid <- as.character(chat_id)
      tryCatch(self$ntgcalls$stop(chat_id), error = function(e) {})
      tryCatch(self$mtproto$leave_group_call(chat_id), error = function(e) {})
      self$active_calls[[cid]] <- NULL
      invisible(TRUE)
    }
  )
)

ConferenceManager <- R6::R6Class(
  classname = "ConferenceManager",
  public = list(
    ntgcalls = NULL,
    mtproto = NULL,
    initialize = function(ntgcalls_instance, mtproto_adapter) {
      self$ntgcalls <- ntgcalls_instance
      self$mtproto <- mtproto_adapter
    },
    init_conference = function(chat_id, user_id, last_block = NULL) {
      self$ntgcalls$init_conference(chat_id, user_id, last_block)
    },
    apply_blocks = function(chat_id, subchain, next_offset, blocks, from_short_poll = FALSE) {
      self$ntgcalls$apply_blocks(chat_id, subchain, next_offset, blocks, from_short_poll)
    },
    finish_subchain_request = function(chat_id, subchain) {
      self$ntgcalls$finish_subchain_request(chat_id, subchain)
    }
  )
)
