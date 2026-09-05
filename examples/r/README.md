# NTgCalls R Examples

This directory contains executable examples demonstrating how to use the `ntgcalls` R package for Telegram voice and video calls, WebRTC media streaming, Diffie-Hellman encryption key exchanges, and thread-safe event polling.

## Requirements

Install `ntgcalls` from CRAN or GitHub:

```R
# Install from CRAN (when available):
install.packages("ntgcalls")

# Or install from GitHub directly:
remotes::install_github("miscivetprojects-creator/ntgcalls_r", subdir = "r")
```

## Available Examples

### 1. [basic_client.R](basic_client.R)
Demonstrates client initialization, pinging the native core, inspecting WebRTC protocol limits, querying available media devices (microphones, speakers, cameras, screen sharing), and safe object destruction.

```powershell
Rscript examples/r/basic_client.R
```

### 2. [group_call_stream.R](group_call_stream.R)
Shows how to configure audio and video descriptions (`audio_description`, `video_description`, `media_description`), connect to group voice/video calls, handle stream states, pause/resume, and register stream lifecycle event listeners.

```powershell
Rscript examples/r/group_call_stream.R
```

### 3. [p2p_call_exchange.R](p2p_call_exchange.R)
Demonstrates end-to-end encrypted 1-on-1 private calls, generating Diffie-Hellman parameters (`dh_config`), exchanging authentication keys, and configuring TURN/STUN RTC servers (`rtc_server`).

```powershell
Rscript examples/r/p2p_call_exchange.R
```

### 4. [event_listener.R](event_listener.R)
Demonstrates R's thread-safe event listener architecture. Native WebRTC worker threads push events to an internal mutex-guarded queue, which is safely dispatched on the R main thread via `$poll_events()` and `$process_events()`.

```powershell
Rscript examples/r/event_listener.R
```

### 5. [telegram_call_flow.R](telegram_call_flow.R)
End-to-end workflow demonstrating realistic Telegram call update handling: generating raw PCM 48kHz audio streams, creating the MTProto `phone.joinGroupCall` SDP/WebRTC payload (`$create_call()`), streaming media, live volume/mute control, state tracking, and graceful teardown.

```powershell
Rscript examples/r/telegram_call_flow.R
```

### 6. [live_telegram_call.R](live_telegram_call.R)
Interactive and environment-configurable live Telegram call session:
- Generates or streams custom audio (`$env:TG_AUDIO_FILE`).
- Exports outgoing SDP join parameters for your group chat (`$env:TG_CHAT_ID`).
- Directly consumes live Telegram MTProto signaling responses (`$env:TG_SIGNALING_JSON` or `$env:TG_SIGNALING_FILE`).
- Streams live WebRTC audio and monitors real-time upgrade/state events.

### 7. [pyrogram_stream_player.py](../pyrogram_stream_player.py)
Automated end-to-end Pyrogram String Session music & video player for Telegram group voice chats:
- Authenticates via Telegram Pyrogram `STRING_SESSION`.
- Extracts live audio & video from YouTube (`yt-dlp`).
- Automatically creates or joins the group voice chat (`phone.JoinGroupCall`).
- Connects `NTgCalls` WebRTC engine to stream **720p Video + 48kHz Stereo Audio**.
- Sends announcement message to the group chat upon starting.

```powershell
$env:API_ID="123456"
$env:API_HASH="your_api_hash"
$env:STRING_SESSION="your_pyrogram_string_session"
$env:TG_CHAT_ID="-1004485855305"
$env:PLAY_URL="https://youtu.be/Bc1A16p_Fk0?si=0rlo6_DNG-uZZATn"

python examples/pyrogram_stream_player.py
```



