AudioStream <- function(
  path,
  sample_rate = 48000L,
  channel_count = 2L,
  keep_open = FALSE
) {
  ad <- ntgcalls::audio_description(
    media_source = ntgcalls::MediaSource$FILE,
    sample_rate = as.integer(sample_rate),
    channel_count = as.integer(channel_count),
    input = as.character(path),
    keep_open = as.logical(keep_open)
  )
  out <- ntgcalls::media_description(
    microphone = ad,
    speaker = NULL,
    camera = NULL,
    screen = NULL
  )
  class(out) <- c("rtg_audio_stream", class(out))
  out
}

VideoStream <- function(
  path,
  width = 1280L,
  height = 720L,
  fps = 30L,
  keep_open = FALSE
) {
  vd <- ntgcalls::video_description(
    media_source = ntgcalls::MediaSource$FILE,
    width = as.integer(width),
    height = as.integer(height),
    fps = as.integer(fps),
    input = as.character(path),
    keep_open = as.logical(keep_open)
  )
  out <- ntgcalls::media_description(
    microphone = NULL,
    speaker = NULL,
    camera = vd,
    screen = NULL
  )
  class(out) <- c("rtg_video_stream", class(out))
  out
}

AudioVideoPiped <- function(
  audio_path,
  video_path,
  sample_rate = 48000L,
  channel_count = 2L,
  width = 1280L,
  height = 720L,
  fps = 30L,
  keep_open = FALSE
) {
  ad <- ntgcalls::audio_description(
    media_source = ntgcalls::MediaSource$FILE,
    sample_rate = as.integer(sample_rate),
    channel_count = as.integer(channel_count),
    input = as.character(audio_path),
    keep_open = as.logical(keep_open)
  )
  vd <- ntgcalls::video_description(
    media_source = ntgcalls::MediaSource$FILE,
    width = as.integer(width),
    height = as.integer(height),
    fps = as.integer(fps),
    input = as.character(video_path),
    keep_open = as.logical(keep_open)
  )
  out <- ntgcalls::media_description(
    microphone = ad,
    speaker = NULL,
    camera = vd,
    screen = NULL
  )
  class(out) <- c("rtg_audio_video_piped", class(out))
  out
}

FFmpegStream <- function(
  path,
  is_video = FALSE,
  width = 1280L,
  height = 720L,
  fps = 30L
) {
  if (is_video) {
    vd <- ntgcalls::video_description(
      media_source = ntgcalls::MediaSource$FFMPEG,
      width = as.integer(width),
      height = as.integer(height),
      fps = as.integer(fps),
      input = as.character(path),
      keep_open = FALSE
    )
    ad <- ntgcalls::audio_description(
      media_source = ntgcalls::MediaSource$FFMPEG,
      sample_rate = 48000L,
      channel_count = 2L,
      input = as.character(path),
      keep_open = FALSE
    )
    out <- ntgcalls::media_description(
      microphone = ad,
      speaker = NULL,
      camera = vd,
      screen = NULL
    )
    class(out) <- c("rtg_ffmpeg_stream", class(out))
    out
  } else {
    ad <- ntgcalls::audio_description(
      media_source = ntgcalls::MediaSource$FFMPEG,
      sample_rate = 48000L,
      channel_count = 2L,
      input = as.character(path),
      keep_open = FALSE
    )
    out <- ntgcalls::media_description(
      microphone = ad,
      speaker = NULL,
      camera = NULL,
      screen = NULL
    )
    class(out) <- c("rtg_ffmpeg_stream", class(out))
    out
  }
}
