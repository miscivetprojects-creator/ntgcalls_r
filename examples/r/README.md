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
