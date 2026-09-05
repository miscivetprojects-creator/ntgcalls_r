MediaSource <- list(
  UNKNOWN = 0L,
  FILE = 1L,
  SHELL = 2L,
  FFMPEG = 3L,
  DEVICE = 4L,
  DESKTOP = 5L,
  EXTERNAL = 6L
)

StreamType <- list(
  AUDIO = 0L,
  VIDEO = 1L
)

StreamStatus <- list(
  ACTIVE = 0L,
  PAUSED = 1L,
  IDLING = 2L
)

StreamMode <- list(
  CAPTURE = 0L,
  PLAYBACK = 1L
)

StreamDevice <- list(
  MICROPHONE = 0L,
  SPEAKER = 1L,
  CAMERA = 2L,
  SCREEN = 3L
)

ConnectionState <- list(
  CONNECTING = 0L,
  CONNECTED = 1L,
  FAILED = 2L,
  TIMEOUT = 3L,
  CLOSED = 4L
)

ConnectionKind <- list(
  NORMAL = 0L,
  PRESENTATION = 1L
)

CallType <- list(
  GROUP = 0L,
  OUTGOING = 1L,
  INCOMING = 2L,
  P2P = 3L,
  CONFERENCE = 4L
)

MediaSegmentQuality <- list(
  NONE = 0L,
  THUMBNAIL = 1L,
  MEDIUM = 2L,
  FULL = 3L
)

MediaSegmentPartStatus <- list(
  NOT_READY = 0L,
  RESYNC_NEEDED = 1L,
  DOWNLOADING = 2L,
  SUCCESS = 3L
)

ConnectionMode <- list(
  NONE = 0L,
  RTC = 1L,
  STREAM = 2L,
  RTMP = 3L
)

LogLevel <- list(
  DEBUG = 1L,
  INFO = 2L,
  WARNING = 4L,
  ERROR = 8L
)

LogSource <- list(
  WEBRTC = 1L,
  SELF = 2L
)

VideoRotation <- list(
  ROTATION_0 = 0L,
  ROTATION_90 = 90L,
  ROTATION_180 = 180L,
  ROTATION_270 = 270L
)

validate_chat_id <- function(chat_id) {
  if (missing(chat_id) || is.null(chat_id)) {
    stop("chat_id must be provided")
  }
  if (is.numeric(chat_id) || is.character(chat_id)) {
    return(chat_id)
  }
  stop("chat_id must be numeric or character string")
}

as_raw_bytes <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  if (is.raw(x)) {
    return(x)
  }
  if (is.character(x)) {
    return(charToRaw(x))
  }
  if (is.numeric(x)) {
    return(as.raw(x))
  }
  stop("Cannot convert value to raw bytes")
}
