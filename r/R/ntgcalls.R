NTgCallsClient <- R6::R6Class(
  "NTgCallsClient",
  public = list(
    handle = NULL,
    events = NULL,
    initialize = function() {
      self$handle <- .Call("r_ntg_instance_create", PACKAGE = "ntgcalls")
      self$events <- EventRegistry$new()
      .Call("r_ntg_setup_callbacks", self$handle, PACKAGE = "ntgcalls")
      invisible(self)
    },
    destroy = function() {
      if (!is.null(self$handle)) {
        .Call("r_ntg_instance_destroy", self$handle, PACKAGE = "ntgcalls")
        self$handle <- NULL
      }
      invisible(self)
    },
    close = function() {
      self$destroy()
    },
    ping = function() {
      .Call("r_ntg_ping", PACKAGE = "ntgcalls")
    },
    get_version = function() {
      .Call("r_ntg_get_version", PACKAGE = "ntgcalls")
    },
    cpu_usage = function() {
      self$check_open()
      .Call("r_ntg_cpu_usage", self$handle, PACKAGE = "ntgcalls")
    },
    get_protocol = function() {
      .Call("r_ntg_get_protocol", PACKAGE = "ntgcalls")
    },
    get_media_devices = function() {
      .Call("r_ntg_get_media_devices", PACKAGE = "ntgcalls")
    },
    enable_glib_loop = function(enable = TRUE) {
      .Call("r_ntg_enable_glib_loop", as.logical(enable), PACKAGE = "ntgcalls")
      invisible(self)
    },
    create_p2p_call = function(user_id) {
      self$check_open()
      .Call("r_ntg_create_p2p_call", self$handle, validate_chat_id(user_id), PACKAGE = "ntgcalls")
      invisible(self)
    },
    init_exchange = function(user_id, dh_config, ga_hash = NULL) {
      self$check_open()
      if (!inherits(dh_config, "ntg_dh_config") && !is.list(dh_config)) {
        stop("dh_config must be an ntg_dh_config object")
      }
      .Call(
        "r_ntg_init_exchange",
        self$handle,
        validate_chat_id(user_id),
        dh_config,
        as_raw_bytes(ga_hash),
        PACKAGE = "ntgcalls"
      )
    },
    exchange_keys = function(user_id, g_a_or_b, fingerprint) {
      self$check_open()
      .Call(
        "r_ntg_exchange_keys",
        self$handle,
        validate_chat_id(user_id),
        as_raw_bytes(g_a_or_b),
        validate_chat_id(fingerprint),
        PACKAGE = "ntgcalls"
      )
    },
    skip_exchange = function(user_id, encryption_key, is_outgoing) {
      self$check_open()
      .Call(
        "r_ntg_skip_exchange",
        self$handle,
        validate_chat_id(user_id),
        as_raw_bytes(encryption_key),
        as.logical(is_outgoing),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    connect_p2p = function(user_id,
                           servers,
                           versions,
                           p2p_allowed = TRUE,
                           custom_parameters = NULL) {
      self$check_open()
      if (!is.list(servers)) {
        stop("servers must be a list of rtc_server objects")
      }
      .Call(
        "r_ntg_connect_p2p",
        self$handle,
        validate_chat_id(user_id),
        servers,
        as.character(versions),
        as.logical(p2p_allowed),
        custom_parameters,
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    create_call = function(chat_id) {
      self$check_open()
      .Call("r_ntg_create_call", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    init_presentation = function(chat_id) {
      self$check_open()
      .Call("r_ntg_init_presentation", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    init_conference = function(chat_id, user_id, last_block = NULL) {
      self$check_open()
      .Call(
        "r_ntg_init_conference",
        self$handle,
        validate_chat_id(chat_id),
        validate_chat_id(user_id),
        as_raw_bytes(last_block),
        PACKAGE = "ntgcalls"
      )
    },
    connect = function(chat_id, params, is_presentation = FALSE) {
      self$check_open()
      if (!is.character(params) || length(params) != 1) {
        stop("params must be a single character string")
      }
      .Call(
        "r_ntg_connect",
        self$handle,
        validate_chat_id(chat_id),
        as.character(params),
        as.logical(is_presentation),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    add_incoming_video = function(chat_id, user_id, endpoint, ssrc_groups) {
      self$check_open()
      if (!is.list(ssrc_groups)) {
        stop("ssrc_groups must be a list of ssrc_group objects")
      }
      .Call(
        "r_ntg_add_incoming_video",
        self$handle,
        validate_chat_id(chat_id),
        validate_chat_id(user_id),
        as.character(endpoint),
        ssrc_groups,
        PACKAGE = "ntgcalls"
      )
    },
    remove_incoming_video = function(chat_id, endpoint) {
      self$check_open()
      .Call(
        "r_ntg_remove_incoming_video",
        self$handle,
        validate_chat_id(chat_id),
        as.character(endpoint),
        PACKAGE = "ntgcalls"
      )
    },
    set_stream_sources = function(chat_id, mode, media) {
      self$check_open()
      if (!inherits(media, "ntg_media_description") && !is.list(media)) {
        stop("media must be an ntg_media_description object")
      }
      .Call(
        "r_ntg_set_stream_sources",
        self$handle,
        validate_chat_id(chat_id),
        as.integer(mode),
        media,
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    pause = function(chat_id) {
      self$check_open()
      .Call("r_ntg_pause", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    resume = function(chat_id) {
      self$check_open()
      .Call("r_ntg_resume", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    mute = function(chat_id) {
      self$check_open()
      .Call("r_ntg_mute", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    unmute = function(chat_id) {
      self$check_open()
      .Call("r_ntg_unmute", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    stop = function(chat_id) {
      self$check_open()
      .Call("r_ntg_stop", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
      invisible(self)
    },
    stop_presentation = function(chat_id) {
      self$check_open()
      .Call("r_ntg_stop_presentation", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
      invisible(self)
    },
    get_emojis_fingerprint = function(chat_id) {
      self$check_open()
      .Call("r_ntg_get_emojis_fingerprint", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    time = function(chat_id, mode = StreamMode$PLAYBACK) {
      self$check_open()
      .Call("r_ntg_time", self$handle, validate_chat_id(chat_id), as.integer(mode), PACKAGE = "ntgcalls")
    },
    get_state = function(chat_id) {
      self$check_open()
      .Call("r_ntg_get_state", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    get_call_type = function(chat_id) {
      self$check_open()
      .Call("r_ntg_get_call_type", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    get_connection_mode = function(chat_id) {
      self$check_open()
      .Call("r_ntg_get_connection_mode", self$handle, validate_chat_id(chat_id), PACKAGE = "ntgcalls")
    },
    calls = function() {
      self$check_open()
      .Call("r_ntg_calls", self$handle, PACKAGE = "ntgcalls")
    },
    send_broadcast_timestamp = function(chat_id, timestamp) {
      self$check_open()
      .Call(
        "r_ntg_send_broadcast_timestamp",
        self$handle,
        validate_chat_id(chat_id),
        as.numeric(timestamp),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    send_broadcast_part = function(chat_id,
                                   segment_id,
                                   part_id,
                                   status,
                                   quality_update = FALSE,
                                   data = NULL) {
      self$check_open()
      .Call(
        "r_ntg_send_broadcast_part",
        self$handle,
        validate_chat_id(chat_id),
        as.numeric(segment_id),
        as.integer(part_id),
        as.integer(status),
        as.logical(quality_update),
        as_raw_bytes(data),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    send_signaling_data = function(chat_id, data) {
      self$check_open()
      .Call(
        "r_ntg_send_signaling_data",
        self$handle,
        validate_chat_id(chat_id),
        as_raw_bytes(data),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    send_external_frame = function(chat_id, device, data, frame_data = frame_data()) {
      self$check_open()
      .Call(
        "r_ntg_send_external_frame",
        self$handle,
        validate_chat_id(chat_id),
        as.integer(device),
        as_raw_bytes(data),
        frame_data,
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    update_audio_ssrc_mappings = function(chat_id, mappings) {
      self$check_open()
      if (!is.list(mappings)) {
        stop("mappings must be a list of ssrc_mapping objects")
      }
      .Call(
        "r_ntg_update_audio_ssrc_mappings",
        self$handle,
        validate_chat_id(chat_id),
        mappings,
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    apply_blocks = function(chat_id,
                            subchain,
                            next_offset,
                            blocks,
                            from_short_poll = FALSE) {
      self$check_open()
      if (!is.list(blocks)) {
        stop("blocks must be a list of raw byte vectors")
      }
      raw_blocks <- lapply(blocks, as_raw_bytes)
      .Call(
        "r_ntg_apply_blocks",
        self$handle,
        validate_chat_id(chat_id),
        as.integer(subchain),
        as.integer(next_offset),
        raw_blocks,
        as.logical(from_short_poll),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    finish_subchain_request = function(chat_id, subchain) {
      self$check_open()
      .Call(
        "r_ntg_finish_subchain_request",
        self$handle,
        validate_chat_id(chat_id),
        as.integer(subchain),
        PACKAGE = "ntgcalls"
      )
      invisible(self)
    },
    on = function(event, callback) {
      self$events$add_listener(event, callback)
      invisible(self)
    },
    off = function(event, callback = NULL) {
      self$events$remove_listener(event, callback)
      invisible(self)
    },
    poll_events = function(max_events = 1000L) {
      self$check_open()
      .Call("r_ntg_poll_events", self$handle, as.integer(max_events), PACKAGE = "ntgcalls")
    },
    process_events = function(max_events = 1000L) {
      events <- self$poll_events(max_events)
      if (length(events) > 0) {
        for (evt in events) {
          self$events$dispatch(evt)
        }
      }
      invisible(length(events))
    },
    check_open = function() {
      if (is.null(self$handle)) {
        stop("NTgCalls client is closed")
      }
    }
  )
)

ntgcalls <- function() {
  NTgCallsClient$new()
}
