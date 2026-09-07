@config banner = # @generated from schema/ntgcalls.ntl -- DO NOT EDIT
@out @{config.self_dir}/ntgcalls.R

@for e in enums
@if e.emit
@{e.name} <- list()
@for mem in e.members
@{e.name}$@{mem.disp} <- @{mem.ord}L
@end

@end
@end
@for s in structs
@{s.name|snake} <- function(
@for f in s.fields
  @{f.name|snake} = NULL@{f.sep}
@end
) {
  out <- list(
@for f in s.fields
    @{f.name|snake} = @{f.name|snake}@{f.sep}
@end
  )
  class(out) <- c("ntg_@{s.name|snake}", "list")
  out
}

@end
@for e in excs
raise_@{e.name|snake} <- function(msg = "") {
  cond <- structure(
    list(message = msg),
    class = c("ntg_@{e.name|snake}", "ntg_error", "error", "condition")
  )
  stop(cond)
}

@end
EventRegistry <- R6::R6Class(
  "EventRegistry",
  public = list(
    on = function(event_name, callback) {
      if (!is.function(callback)) stop("Callback must be a function")
      private$listeners[[event_name]] <- callback
      invisible(self)
    },
    off = function(event_name) {
      private$listeners[[event_name]] <- NULL
      invisible(self)
    },
    emit = function(event_name, ...) {
      cb <- private$listeners[[event_name]]
      if (!is.null(cb) && is.function(cb)) {
        cb(...)
      }
    }
  ),
  private = list(
    listeners = list()
  )
)

NTgCallsClient <- R6::R6Class(
  "NTgCallsClient",
  public = list(
    initialize = function() {
      private$handle <- .Call("r_ntg_create", PACKAGE = "ntgcalls")
      private$events <- EventRegistry$new()
    },
    destroy = function() {
      if (!is.null(private$handle)) {
        .Call("r_ntg_free", private$handle, PACKAGE = "ntgcalls")
        private$handle <- NULL
      }
    },
@for c in classes
@for m in c.methods
@if m.iscb
@else
@if m.static
    @{m.name|snake} = function(
@for a in m.args
      @{a.name|snake} = NULL@{a.sep}
@end
    ) {
      .Call("r_ntg_@{m.name|snake}"
@for a in m.args
        , @{a.name|snake}
@end
        , PACKAGE = "ntgcalls"
      )
    },
@else
    @{m.name|snake} = function(
@for a in m.args
      @{a.name|snake} = NULL@{a.sep}
@end
    ) {
      if (is.null(private$handle)) {
        stop("Client has been destroyed.")
      }
      .Call("r_ntg_@{m.name|snake}", private$handle
@for a in m.args
        , @{a.name|snake}
@end
        , PACKAGE = "ntgcalls"
      )
    },
@end
@end
@end
@end
    on = function(event_name, callback) {
      private$events$on(event_name, callback)
      invisible(self)
    },
    off = function(event_name) {
      private$events$off(event_name)
      invisible(self)
    },
    emit = function(event_name, ...) {
      private$events$emit(event_name, ...)
      invisible(self)
    },
    poll_events = function(max_events = 100L) {
      if (is.null(private$handle)) return(invisible(NULL))
      evs <- .Call("r_ntg_poll_events", private$handle, as.integer(max_events), PACKAGE = "ntgcalls")
      if (!is.null(evs) && length(evs) > 0) {
        for (ev in evs) {
          if (!is.null(ev$event)) {
            private$events$emit(ev$event, ev)
          }
        }
      }
      invisible(evs)
    }
  ),
  private = list(
    handle = NULL,
    events = NULL
  )
)

ntgcalls <- function() {
  NTgCallsClient$new()
}
