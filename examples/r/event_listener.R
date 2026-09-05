library(ntgcalls)

run_event_listener_example <- function() {
  cat("=== NTgCalls Thread-Safe Event Polling Example ===\n\n")

  reg <- ntgcalls:::EventRegistry$new()

  reg$add_listener("connection_change", function(evt) {
    cat(sprintf("[Event Dispatch] Chat %s connection state: %d\n", evt$chat_id, evt$state$state))
  })

  reg$add_listener("signaling_data", function(evt) {
    cat(sprintf("[Event Dispatch] Received %d bytes signaling data for chat %s\n", length(evt$data), evt$chat_id))
  })

  cat("Testing event dispatching queue:\n")
  reg$dispatch(list(event = "connection_change", chat_id = 12345, state = list(state = ConnectionState$CONNECTED, kind = ConnectionKind$NORMAL)))
  reg$dispatch(list(event = "signaling_data", chat_id = 12345, data = charToRaw("hello_signaling")))

  cat("Event listener example finished successfully.\n")
}

run_event_listener_example()
