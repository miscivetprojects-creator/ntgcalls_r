\name{ntgcalls}
\alias{ntgcalls}
\alias{NTgCallsClient}
\alias{audio_description}
\alias{video_description}
\alias{media_description}
\alias{rtc_server}
\alias{dh_config}
\alias{protocol}
\alias{ssrc_group}
\alias{ssrc_mapping}
\alias{frame_data}
\alias{frame}
\alias{segment_part_request}
\alias{subchain_request}
\alias{call_info}
\alias{media_state}
\alias{connection_info}
\alias{remote_source}
\alias{MediaSource}
\alias{StreamType}
\alias{StreamStatus}
\alias{StreamMode}
\alias{StreamDevice}
\alias{ConnectionState}
\alias{ConnectionKind}
\alias{CallType}
\alias{MediaSegmentQuality}
\alias{MediaSegmentPartStatus}
\alias{ConnectionMode}
\alias{LogLevel}
\alias{LogSource}
\alias{VideoRotation}
\title{NTgCalls R Interface}
\description{
First-class R language bindings for NTgCalls WebRTC Telegram client.
Provides complete control over Telegram voice and video calls, screen sharing,
dynamic stream controls, encryption key exchange, and real-time media pipeline.
}
\usage{
ntgcalls()

audio_description(input, media_source = MediaSource$FILE,
                  sample_rate = 48000L, channel_count = 2L,
                  keep_open = FALSE)

video_description(input, media_source = MediaSource$FILE,
                  width = 1280L, height = 720L, fps = 30L,
                  keep_open = FALSE)

media_description(microphone = NULL, speaker = NULL,
                  camera = NULL, screen = NULL)

rtc_server(id, ipv4, ipv6, port, username = NULL, password = NULL,
           turn = FALSE, stun = FALSE, tcp = FALSE, peer_tag = NULL)

dh_config(g, p, random)

ssrc_group(semantics, ssrcs)

ssrc_mapping(user_id, ssrc)

frame_data(absolute_capture_timestamp_ms = 0,
           rotation = VideoRotation$ROTATION_0,
           width = 0L, height = 0L)

frame(ssrc, data, frame_data = frame_data())

call_info(playback = StreamStatus$IDLING, capture = StreamStatus$IDLING)

media_state(muted = FALSE, video_paused = FALSE, video_stopped = TRUE,
            presentation_paused = FALSE, presentation_stopped = TRUE)

connection_info(state = ConnectionState$CONNECTING,
                kind = ConnectionKind$NORMAL)

remote_source(ssrc = 0L, state = StreamStatus$IDLING,
              device = StreamDevice$MICROPHONE)

protocol(min_layer, max_layer, udp_p2p, udp_reflector, library_versions)

segment_part_request(segment_id, part_id, limit, timestamp,
                     quality_update = FALSE, channel_id = 0L,
                     quality = MediaSegmentQuality$NONE)

subchain_request(subchain, height, limit)
}
\arguments{
\item{input}{Path to media file or stream URI.}
\item{media_source}{Source type enum value.}
\item{sample_rate}{Audio sample rate (default 48000).}
\item{channel_count}{Audio channel count (default 2).}
\item{keep_open}{Logical indicating whether to keep source open after EOF.}
\item{width}{Video width.}
\item{height}{Video height.}
\item{fps}{Video frames per second.}
\item{microphone}{Audio description for microphone.}
\item{speaker}{Audio description for speaker.}
\item{camera}{Video description for camera.}
\item{screen}{Video description for screen share.}
\item{id}{RTC server ID.}
\item{ipv4}{IPv4 address.}
\item{ipv6}{IPv6 address.}
\item{port}{Port number.}
\item{username}{Optional username.}
\item{password}{Optional password.}
\item{turn}{Logical flag for TURN support.}
\item{stun}{Logical flag for STUN support.}
\item{tcp}{Logical flag for TCP support.}
\item{peer_tag}{Optional peer tag bytes.}
\item{g}{Diffie-Hellman generator.}
\item{p}{Diffie-Hellman prime bytes.}
\item{random}{Diffie-Hellman random bytes.}
\item{semantics}{SSRC group semantics string.}
\item{ssrcs}{Vector of SSRC integers.}
\item{user_id}{User ID.}
\item{ssrc}{SSRC integer.}
\item{absolute_capture_timestamp_ms}{Timestamp in milliseconds.}
\item{rotation}{Video rotation in degrees.}
\item{data}{Raw vector of frame data or payload.}
\item{frame_data}{Frame data metadata object.}
\item{playback}{Playback stream status.}
\item{capture}{Capture stream status.}
\item{muted}{Logical muted flag.}
\item{video_paused}{Logical video paused flag.}
\item{video_stopped}{Logical video stopped flag.}
\item{presentation_paused}{Logical presentation paused flag.}
\item{presentation_stopped}{Logical presentation stopped flag.}
\item{state}{Connection or stream state.}
\item{kind}{Connection kind.}
\item{device}{Stream device enum.}
\item{min_layer}{Minimum protocol layer.}
\item{max_layer}{Maximum protocol layer.}
\item{udp_p2p}{Logical UDP P2P flag.}
\item{udp_reflector}{Logical UDP reflector flag.}
\item{library_versions}{Character vector of supported library versions.}
\item{segment_id}{Broadcast segment ID.}
\item{part_id}{Broadcast part ID.}
\item{limit}{Broadcast limit.}
\item{timestamp}{Broadcast timestamp.}
\item{quality_update}{Logical quality update flag.}
\item{channel_id}{Broadcast channel ID.}
\item{quality}{Broadcast quality enum.}
\item{subchain}{Subchain ID.}
}
\value{
\code{ntgcalls()} returns an instance of \code{NTgCallsClient}.
}
\examples{
\dontrun{
library(ntgcalls)
client <- ntgcalls()
client$ping()
client$destroy()
}
}
\keyword{package}
