library(ntgcalls)

run_p2p_exchange_example <- function() {
  cat("=== NTgCalls P2P Key Exchange Example ===\n\n")

  g_val <- 3L
  p_bytes <- as.raw(c(0x01, 0x02, 0x03, 0x04))
  random_bytes <- as.raw(c(0xAA, 0xBB, 0xCC, 0xDD))

  dh <- dh_config(g = g_val, p = p_bytes, random = random_bytes)
  cat("Created Diffie-Hellman configuration:\n")
  cat("  g =", dh$g, "\n")
  cat("  p length =", length(dh$p), "bytes\n")
  cat("  random length =", length(dh$random), "bytes\n\n")

  server_1 <- rtc_server(
    id = 1,
    ipv4 = "192.168.1.100",
    ipv6 = "::1",
    port = 3478L,
    turn = TRUE,
    stun = TRUE
  )

  cat("Configured RTC Turn/Stun server:", server_1$ipv4, ":", server_1$port, "\n\n")

  tryCatch(
    {
      client <- ntgcalls()
      user_id <- 987654321
      cat("Initiating exchange for user:", user_id, "...\n")
      client$destroy()
    },
    error = function(e) {
      cat("[Notice] Standalone example mode:\n")
      cat("  ", conditionMessage(e), "\n")
      cat("  To link with native WebRTC core, set NTGCALLS_LIB_PATH environment variable to libntgcalls.\n")
    }
  )
}

run_p2p_exchange_example()
