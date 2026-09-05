audio_description <- function(input,
                              media_source = MediaSource$FILE,
                              sample_rate = 48000L,
                              channel_count = 2L,
                              keep_open = FALSE) {
  if (missing(input) || !is.character(input) || length(input) != 1) {
    stop("input must be a single character string")
  }
  structure(
    list(
      media_source = as.integer(media_source),
      sample_rate = as.integer(sample_rate),
      channel_count = as.integer(channel_count),
      input = as.character(input),
      keep_open = as.logical(keep_open)
    ),
    class = "ntg_audio_description"
  )
}

video_description <- function(input,
                              media_source = MediaSource$FILE,
                              width = 1280L,
                              height = 720L,
                              fps = 30L,
                              keep_open = FALSE) {
  if (missing(input) || !is.character(input) || length(input) != 1) {
    stop("input must be a single character string")
  }
  structure(
    list(
      media_source = as.integer(media_source),
      width = as.integer(width),
      height = as.integer(height),
      fps = as.integer(fps),
      input = as.character(input),
      keep_open = as.logical(keep_open)
    ),
    class = "ntg_video_description"
  )
}

media_description <- function(microphone = NULL,
                              speaker = NULL,
                              camera = NULL,
                              screen = NULL) {
  structure(
    list(
      microphone = microphone,
      speaker = speaker,
      camera = camera,
      screen = screen
    ),
    class = "ntg_media_description"
  )
}

rtc_server <- function(id,
                       ipv4,
                       ipv6,
                       port,
                       username = NULL,
                       password = NULL,
                       turn = FALSE,
                       stun = FALSE,
                       tcp = FALSE,
                       peer_tag = NULL) {
  structure(
    list(
      id = as.numeric(id),
      ipv4 = as.character(ipv4),
      ipv6 = as.character(ipv6),
      port = as.integer(port),
      username = username,
      password = password,
      turn = as.logical(turn),
      stun = as.logical(stun),
      tcp = as.logical(tcp),
      peer_tag = as_raw_bytes(peer_tag)
    ),
    class = "ntg_rtc_server"
  )
}

dh_config <- function(g, p, random) {
  structure(
    list(
      g = as.integer(g),
      p = as_raw_bytes(p),
      random = as_raw_bytes(random)
    ),
    class = "ntg_dh_config"
  )
}

ssrc_group <- function(semantics, ssrcs) {
  structure(
    list(
      semantics = as.character(semantics),
      ssrcs = as.integer(ssrcs)
    ),
    class = "ntg_ssrc_group"
  )
}

ssrc_mapping <- function(user_id, ssrc) {
  structure(
    list(
      user_id = as.numeric(user_id),
      ssrc = as.integer(ssrc)
    ),
    class = "ntg_ssrc_mapping"
  )
}

frame_data <- function(absolute_capture_timestamp_ms = 0,
                       rotation = VideoRotation$ROTATION_0,
                       width = 0L,
                       height = 0L) {
  structure(
    list(
      absolute_capture_timestamp_ms = as.numeric(absolute_capture_timestamp_ms),
      rotation = as.integer(rotation),
      width = as.integer(width),
      height = as.integer(height)
    ),
    class = "ntg_frame_data"
  )
}

frame <- function(ssrc, data, frame_data = frame_data()) {
  structure(
    list(
      ssrc = as.numeric(ssrc),
      data = as_raw_bytes(data),
      frame_data = frame_data
    ),
    class = "ntg_frame"
  )
}
