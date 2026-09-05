call_info <- function(playback = StreamStatus$IDLING, capture = StreamStatus$IDLING) {
  structure(
    list(
      playback = as.integer(playback),
      capture = as.integer(capture)
    ),
    class = "ntg_call_info"
  )
}

media_state <- function(muted = FALSE,
                        video_paused = FALSE,
                        video_stopped = TRUE,
                        presentation_paused = FALSE,
                        presentation_stopped = TRUE) {
  structure(
    list(
      muted = as.logical(muted),
      video_paused = as.logical(video_paused),
      video_stopped = as.logical(video_stopped),
      presentation_paused = as.logical(presentation_paused),
      presentation_stopped = as.logical(presentation_stopped)
    ),
    class = "ntg_media_state"
  )
}

connection_info <- function(state = ConnectionState$CONNECTING,
                            kind = ConnectionKind$NORMAL) {
  structure(
    list(
      state = as.integer(state),
      kind = as.integer(kind)
    ),
    class = "ntg_connection_info"
  )
}

remote_source <- function(ssrc = 0L,
                          state = StreamStatus$IDLING,
                          device = StreamDevice$MICROPHONE) {
  structure(
    list(
      ssrc = as.integer(ssrc),
      state = as.integer(state),
      device = as.integer(device)
    ),
    class = "ntg_remote_source"
  )
}

protocol <- function(min_layer,
                     max_layer,
                     udp_p2p,
                     udp_reflector,
                     library_versions) {
  structure(
    list(
      min_layer = as.integer(min_layer),
      max_layer = as.integer(max_layer),
      udp_p2p = as.logical(udp_p2p),
      udp_reflector = as.logical(udp_reflector),
      library_versions = as.character(library_versions)
    ),
    class = "ntg_protocol"
  )
}

segment_part_request <- function(segment_id,
                                 part_id,
                                 limit,
                                 timestamp,
                                 quality_update = FALSE,
                                 channel_id = 0L,
                                 quality = MediaSegmentQuality$NONE) {
  structure(
    list(
      segment_id = as.numeric(segment_id),
      part_id = as.integer(part_id),
      limit = as.integer(limit),
      timestamp = as.numeric(timestamp),
      quality_update = as.logical(quality_update),
      channel_id = as.integer(channel_id),
      quality = as.integer(quality)
    ),
    class = "ntg_segment_part_request"
  )
}

subchain_request <- function(subchain, height, limit) {
  structure(
    list(
      subchain = as.integer(subchain),
      height = as.integer(height),
      limit = as.integer(limit)
    ),
    class = "ntg_subchain_request"
  )
}
