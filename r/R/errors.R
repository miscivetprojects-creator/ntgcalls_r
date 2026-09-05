ntg_error_codes <- list(
  OK = 0L,
  UNKNOWN = -1L,
  NULL_POINTER = -2L,
  RTC = -100L,
  SDP_PARSE = -101L,
  TRANSPORT_PARSE = -102L,
  RTMP_STREAMING_UNSUPPORTED = -103L,
  CONNECTION = -200L,
  CONNECTION_NOT_FOUND = -201L,
  CONNECTION_ERROR = -202L,
  CRYPTO_ERROR = -203L,
  TELEGRAM_SERVER_ERROR = -204L,
  RTC_CONNECTION_NEEDED = -205L,
  INVALID_PARAMS = -206L,
  SIGNALING = -300L,
  SIGNALING_ERROR = -301L,
  SIGNALING_UNSUPPORTED = -302L,
  MEDIA = -400L,
  FILE_ERROR = -401L,
  FFMPEG_ERROR = -402L,
  SHELL_ERROR = -403L,
  MEDIA_DEVICE_ERROR = -404L
)

ntg_error_name <- function(code) {
  names <- names(ntg_error_codes)
  values <- unlist(ntg_error_codes)
  match_idx <- which(values == as.integer(code))
  if (length(match_idx) > 0) {
    return(names[match_idx[1]])
  }
  return("UNKNOWN_ERROR")
}

raise_ntg_error <- function(code, message = "") {
  err_name <- ntg_error_name(code)
  full_msg <- if (nzchar(message)) {
    sprintf("NTgCalls [%s (%d)]: %s", err_name, as.integer(code), message)
  } else {
    sprintf("NTgCalls [%s (%d)]", err_name, as.integer(code))
  }
  cond <- structure(
    list(message = full_msg, code = as.integer(code), error_name = err_name),
    class = c(sprintf("ntgcalls_%s", tolower(err_name)), "ntgcalls_error", "error", "condition")
  )
  stop(cond)
}
