EventRegistry <- R6::R6Class(
  "EventRegistry",
  public = list(
    listeners = list(),
    initialize = function() {
      self$listeners <- list(
        upgrade = list(),
        stream_end = list(),
        connection_change = list(),
        signaling_data = list(),
        remote_source_change = list(),
        request_broadcast_part = list(),
        request_broadcast_timestamp = list(),
        request_participants = list(),
        outbound_block = list(),
        subchain_request = list(),
        update_emojis = list()
      )
    },
    add_listener = function(event_name, callback) {
      if (!is.function(callback)) {
        stop("Callback must be a function")
      }
      evt_key <- tolower(event_name)
      if (is.null(self$listeners[[evt_key]])) {
        self$listeners[[evt_key]] <- list()
      }
      self$listeners[[evt_key]] <- append(self$listeners[[evt_key]], list(callback))
      invisible(self)
    },
    remove_listener = function(event_name, callback = NULL) {
      evt_key <- tolower(event_name)
      if (is.null(self$listeners[[evt_key]])) {
        return(invisible(self))
      }
      if (is.null(callback)) {
        self$listeners[[evt_key]] <- list()
      } else {
        self$listeners[[evt_key]] <- Filter(function(cb) !identical(cb, callback), self$listeners[[evt_key]])
      }
      invisible(self)
    },
    dispatch = function(event_item) {
      if (!is.list(event_item) || is.null(event_item$event)) {
        return(invisible(NULL))
      }
      evt_key <- tolower(event_item$event)
      handlers <- self$listeners[[evt_key]]
      if (is.null(handlers) || length(handlers) == 0) {
        return(invisible(NULL))
      }
      for (handler in handlers) {
        tryCatch(
          {
            handler(event_item)
          },
          error = function(err) {
            warning(sprintf("Error in event handler for '%s': %s", evt_key, conditionMessage(err)))
          }
        )
      }
      invisible(NULL)
    }
  )
)
