library(ntgcalls)

run_basic_example <- function() {
  cat("=== NTgCalls Basic Client Example ===\n\n")

  tryCatch(
    {
      client <- ntgcalls()
      cat("NTgCalls Version:", client$get_version(), "\n")
      cat("Ping response:", client$ping(), "\n\n")

      proto <- client$get_protocol()
      cat("Protocol Min Layer:", proto$min_layer, "\n")
      cat("Protocol Max Layer:", proto$max_layer, "\n")
      cat("UDP P2P Supported:", proto$udp_p2p, "\n")
      cat("UDP Reflector Supported:", proto$udp_reflector, "\n\n")

      cpu <- client$cpu_usage()
      cat("Client CPU Usage:", cpu, "%\n")

      client$destroy()
      cat("Client closed successfully.\n")
    },
    error = function(e) {
      cat("[Notice] Standalone example mode:\n")
      cat("  ", conditionMessage(e), "\n")
      cat("  To link with native WebRTC core, set NTGCALLS_LIB_PATH environment variable to libntgcalls.\n")
    }
  )
}

run_basic_example()

