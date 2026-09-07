@config banner = 
@out @{config.self_dir}/DESCRIPTION
Package: ntgcalls
Title: R Bindings for NTgCalls WebRTC Engine
Version: 3.0.0.20
Authors@R: person("NTgCalls", "Team", email = "dev@pytgcalls.org", role = c("aut", "cre"))
Description: First-class R bindings for the high-performance NTgCalls WebRTC core engine, enabling real-time audio and video communications with Telegram group calls and 1-on-1 calls.
License: LGPL (>= 3)
URL: https://github.com/pytgcalls/ntgcalls
BugReports: https://github.com/pytgcalls/ntgcalls/issues
Depends:
    R (>= 3.6.0)
Imports:
    R6
Suggests:
    testthat (>= 3.0.0)
Encoding: UTF-8
RoxygenNote: 7.2.3
NeedsCompilation: yes
