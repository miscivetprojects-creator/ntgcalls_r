@config banner = // @generated from schema/ntgcalls.ntl -- DO NOT EDIT
@out @{config.self_dir}/init.c
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern SEXP r_ntg_create(void);
extern SEXP r_ntg_free(SEXP);
extern SEXP r_ntg_poll_events(SEXP, SEXP);

@for c in classes
@for m in c.methods
@if m.iscb
@else
extern SEXP r_ntg_@{m.name|snake}(
@if m.static
@for a in m.args
    SEXP@{a.sep}
@end
@else
    SEXP
@for a in m.args
    , SEXP
@end
@end
);
@end
@end
@end

static const R_CallMethodDef CallEntries[] = {
    {"r_ntg_create", (DL_FUNC) &r_ntg_create, 0},
    {"r_ntg_free", (DL_FUNC) &r_ntg_free, 1},
    {"r_ntg_poll_events", (DL_FUNC) &r_ntg_poll_events, 2},
@for c in classes
@for m in c.methods
@if m.iscb
@else
@if m.static
    {"r_ntg_@{m.name|snake}", (DL_FUNC) &r_ntg_@{m.name|snake}, -1},
@else
    {"r_ntg_@{m.name|snake}", (DL_FUNC) &r_ntg_@{m.name|snake}, -1},
@end
@end
@end
@end
    {NULL, NULL, 0}
};

void R_init_ntgcalls(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
