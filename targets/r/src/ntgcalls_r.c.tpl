@config c_prefix = ntg
@typemap Vector<bytes> = ntg_bytes
@typemap Vector<*> = *
@typemap long = int64_t
@typemap ulong = uint64_t
@typemap int = int32_t
@typemap uint = uint32_t
@typemap int8 = int8_t
@typemap uint8 = uint8_t
@typemap int16 = int16_t
@typemap uint16 = uint16_t
@typemap bool = bool
@typemap double = double
@typemap string = char*
@typemap bytes = uint8_t
@typemap Void = void
@typemap media.* = ntg_*
@typemap models.* = ntg_*
@typemap p2p.* = ntg_*
@typemap e2e.* = ntg_*
@typemap instances.* = ntg_*
@typemap * = ntg_*
@config banner = // @generated from schema/ntgcalls.ntl -- DO NOT EDIT
@out @{config.self_dir}/ntgcalls_r.c
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "ntgcalls.h"

#ifdef _WIN32
#include <windows.h>
typedef CRITICAL_SECTION ntg_mutex_t;
#define ntg_mutex_init(m) InitializeCriticalSection(m)
#define ntg_mutex_lock(m) EnterCriticalSection(m)
#define ntg_mutex_unlock(m) LeaveCriticalSection(m)
#define ntg_mutex_destroy(m) DeleteCriticalSection(m)
typedef HMODULE ntg_lib_t;
#define ntg_load_lib(p) LoadLibraryA(p)
#define ntg_get_sym(h, s) GetProcAddress(h, s)
#define ntg_free_lib(h) FreeLibrary(h)
#else
#include <pthread.h>
#include <dlfcn.h>
typedef pthread_mutex_t ntg_mutex_t;
#define ntg_mutex_init(m) pthread_mutex_init(m, NULL)
#define ntg_mutex_lock(m) pthread_mutex_lock(m)
#define ntg_mutex_unlock(m) pthread_mutex_unlock(m)
#define ntg_mutex_destroy(m) pthread_mutex_destroy(m)
typedef void* ntg_lib_t;
#define ntg_load_lib(p) dlopen(p, RTLD_LAZY | RTLD_GLOBAL)
#define ntg_get_sym(h, s) dlsym(h, s)
#define ntg_free_lib(h) dlclose(h)
#endif

typedef struct r_event_item {
    char event_name[64];
    int64_t chat_id;
    char* data_str;
    uint8_t* data_bytes;
    size_t data_bytes_len;
} r_event_item;

typedef struct r_event_queue {
    r_event_item items[256];
    size_t head;
    size_t tail;
    size_t count;
    ntg_mutex_t lock;
} r_event_queue;

typedef struct r_ntg_context {
    ntg_instance* handle;
    r_event_queue queue;
} r_ntg_context;

static ntg_lib_t g_ntg_lib = NULL;
static bool g_symbols_loaded = false;

typedef ntg_instance* (*fn_ntg_instance_create)(void);
typedef void (*fn_ntg_instance_destroy)(ntg_instance*);
typedef const char* (*fn_ntg_last_error)(void);
typedef const char* (*fn_ntg_get_version)(void);
typedef void (*fn_ntg_string_free)(char*);
typedef void (*fn_ntg_bytes_free)(void*);

static fn_ntg_instance_create p_ntg_instance_create = NULL;
static fn_ntg_instance_destroy p_ntg_instance_destroy = NULL;
static fn_ntg_last_error p_ntg_last_error = NULL;
static fn_ntg_get_version p_ntg_get_version = NULL;
static fn_ntg_string_free p_ntg_string_free = NULL;
static fn_ntg_bytes_free p_ntg_bytes_free = NULL;

@for cb in callbacks
typedef ntg_result (*fn_ntg_on_@{cb.name|snake})(ntg_instance*, ntg_@{cb.name|snake}_cb, void*);
static fn_ntg_on_@{cb.name|snake} p_ntg_on_@{cb.name|snake} = NULL;
@end

@for c in classes
@for m in c.methods
@if m.iscb
@else
@if m.static
@if m.isvoid
typedef ntg_result (*fn_ntg_@{m.name|snake})(
@if m.params
@for p in m.params
@if p.bytes
    const uint8_t*, size_t@{p.sep}
@else
@if p.string
    const char*@{p.sep}
@else
@if p.vector
    const @{p.type|type|snake}*, size_t@{p.sep}
@else
    @{p.type|type|snake}@{p.sep}
@end
@end
@end
@end
@else
    void
@end
);
@else
@if m.retstring
typedef ntg_result (*fn_ntg_@{m.name|snake})(char**);
@else
typedef ntg_result (*fn_ntg_@{m.name|snake})(void*);
@end
@end
@else
@if m.isvoid
typedef ntg_result (*fn_ntg_@{m.name|snake})(ntg_instance*
@for p in m.params
@if p.bytes
    , const uint8_t*, size_t
@else
@if p.string
    , const char*
@else
@if p.vector
    , const @{p.type|type|snake}*, size_t
@else
    , @{p.type|type|snake}
@end
@end
@end
@end
);
@else
@if m.retstring
typedef ntg_result (*fn_ntg_@{m.name|snake})(ntg_instance*
@for p in m.params
@if p.bytes
    , const uint8_t*, size_t
@else
@if p.string
    , const char*
@else
@if p.vector
    , const @{p.type|type|snake}*, size_t
@else
    , @{p.type|type|snake}
@end
@end
@end
@end
, char**);
@else
typedef ntg_result (*fn_ntg_@{m.name|snake})(ntg_instance*, void*);
@end
@end
@end
static fn_ntg_@{m.name|snake} p_ntg_@{m.name|snake} = NULL;
@end
@end
@end

static bool ensure_symbols_loaded(void) {
    if (g_symbols_loaded) return true;

    const char* env_path = getenv("NTGCALLS_LIB_PATH");
    if (env_path && strlen(env_path) > 0) {
        g_ntg_lib = ntg_load_lib(env_path);
    }
    if (!g_ntg_lib) {
#ifdef _WIN32
        g_ntg_lib = ntg_load_lib("ntgcalls.dll");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("shared-output/lib/Release/ntgcalls.dll");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../shared-output/lib/Release/ntgcalls.dll");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../../shared-output/lib/Release/ntgcalls.dll");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../../../shared-output/lib/Release/ntgcalls.dll");
#elif defined(__APPLE__)
        g_ntg_lib = ntg_load_lib("libntgcalls.dylib");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("shared-output/lib/libntgcalls.dylib");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../shared-output/lib/libntgcalls.dylib");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../../shared-output/lib/libntgcalls.dylib");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../../../shared-output/lib/libntgcalls.dylib");
#else
        g_ntg_lib = ntg_load_lib("libntgcalls.so");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("shared-output/lib/libntgcalls.so");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../shared-output/lib/libntgcalls.so");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../../shared-output/lib/libntgcalls.so");
        if (!g_ntg_lib) g_ntg_lib = ntg_load_lib("../../../shared-output/lib/libntgcalls.so");
#endif
    }

    if (!g_ntg_lib) {
        return false;
    }

    p_ntg_instance_create = (fn_ntg_instance_create) ntg_get_sym(g_ntg_lib, "ntg_instance_create");
    p_ntg_instance_destroy = (fn_ntg_instance_destroy) ntg_get_sym(g_ntg_lib, "ntg_instance_destroy");
    p_ntg_last_error = (fn_ntg_last_error) ntg_get_sym(g_ntg_lib, "ntg_last_error");
    p_ntg_get_version = (fn_ntg_get_version) ntg_get_sym(g_ntg_lib, "ntg_get_version");
    p_ntg_string_free = (fn_ntg_string_free) ntg_get_sym(g_ntg_lib, "ntg_string_free");
    p_ntg_bytes_free = (fn_ntg_bytes_free) ntg_get_sym(g_ntg_lib, "ntg_bytes_free");

@for cb in callbacks
    p_ntg_on_@{cb.name|snake} = (fn_ntg_on_@{cb.name|snake}) ntg_get_sym(g_ntg_lib, "ntg_on_@{cb.name|snake}");
@end

@for c in classes
@for m in c.methods
@if m.iscb
@else
    p_ntg_@{m.name|snake} = (fn_ntg_@{m.name|snake}) ntg_get_sym(g_ntg_lib, "ntg_@{m.name|snake}");
@end
@end
@end

    g_symbols_loaded = (p_ntg_instance_create != NULL);
    return g_symbols_loaded;
}

static void queue_init(r_event_queue* q) {
    q->head = 0;
    q->tail = 0;
    q->count = 0;
    ntg_mutex_init(&q->lock);
}

static void queue_destroy(r_event_queue* q) {
    ntg_mutex_lock(&q->lock);
    while (q->count > 0) {
        r_event_item* it = &q->items[q->head];
        if (it->data_str) free(it->data_str);
        if (it->data_bytes) free(it->data_bytes);
        q->head = (q->head + 1) % 256;
        q->count--;
    }
    ntg_mutex_unlock(&q->lock);
    ntg_mutex_destroy(&q->lock);
}

static void queue_push(r_event_queue* q, const char* name, int64_t chat_id, const char* str, const uint8_t* bytes, size_t len) {
    ntg_mutex_lock(&q->lock);
    if (q->count == 256) {
        r_event_item* old = &q->items[q->head];
        if (old->data_str) free(old->data_str);
        if (old->data_bytes) free(old->data_bytes);
        q->head = (q->head + 1) % 256;
        q->count--;
    }
    r_event_item* it = &q->items[q->tail];
    strncpy(it->event_name, name, sizeof(it->event_name) - 1);
    it->event_name[sizeof(it->event_name) - 1] = '\0';
    it->chat_id = chat_id;
    it->data_str = str ? strdup(str) : NULL;
    if (bytes && len > 0) {
        it->data_bytes = (uint8_t*) malloc(len);
        if (it->data_bytes) {
            memcpy(it->data_bytes, bytes, len);
            it->data_bytes_len = len;
        } else {
            it->data_bytes_len = 0;
        }
    } else {
        it->data_bytes = NULL;
        it->data_bytes_len = 0;
    }
    q->tail = (q->tail + 1) % 256;
    q->count++;
    ntg_mutex_unlock(&q->lock);
}

static void r_ntg_finalizer(SEXP ptr) {
    if (TYPEOF(ptr) != EXTPTRSXP) return;
    r_ntg_context* ctx = (r_ntg_context*) R_ExternalPtrAddr(ptr);
    if (ctx) {
        if (ctx->handle && p_ntg_instance_destroy) {
            p_ntg_instance_destroy(ctx->handle);
            ctx->handle = NULL;
        }
        queue_destroy(&ctx->queue);
        free(ctx);
        R_ClearExternalPtr(ptr);
    }
}

static r_ntg_context* get_context(SEXP ptr) {
    if (TYPEOF(ptr) != EXTPTRSXP) {
        Rf_errorcall(R_NilValue, "Invalid handle: expected ExternalPtr");
    }
    r_ntg_context* ctx = (r_ntg_context*) R_ExternalPtrAddr(ptr);
    if (!ctx) {
        Rf_errorcall(R_NilValue, "Invalid handle: null or destroyed NTgCalls pointer");
    }
    return ctx;
}

static inline SEXP r_wrap_string(const char* s) {
    return s ? Rf_mkString(s) : Rf_mkString("");
}

static inline SEXP r_wrap_bytes(const uint8_t* data, size_t len) {
    SEXP raw = Rf_allocVector(RAWSXP, len);
    if (len > 0 && data) {
        memcpy(RAW(raw), data, len);
    }
    return raw;
}

static inline int64_t r_read_int64(SEXP s) {
    if (Rf_isReal(s) && Rf_length(s) > 0) {
        return (int64_t) REAL(s)[0];
    } else if (Rf_isInteger(s) && Rf_length(s) > 0) {
        return (int64_t) INTEGER(s)[0];
    } else if (Rf_isString(s) && Rf_length(s) > 0) {
        return (int64_t) atoll(CHAR(STRING_ELT(s, 0)));
    }
    return 0;
}

static inline int32_t r_read_int32(SEXP s) {
    if (Rf_isInteger(s) && Rf_length(s) > 0) {
        return INTEGER(s)[0];
    } else if (Rf_isReal(s) && Rf_length(s) > 0) {
        return (int32_t) REAL(s)[0];
    }
    return 0;
}

@for cb in callbacks
static void on_cb_@{cb.name|snake}(
    ntg_instance* handle,
@for a in cb.cbargs
@if a.bytes
    const uint8_t* @{a.name|snake}, size_t @{a.name|snake}_len,
@else
@if a.string
    const char* @{a.name|snake},
@else
@if a.vector
    const @{a.type|type|snake}* @{a.name|snake}, size_t @{a.name|snake}_len,
@else
    @{a.type|type|snake} @{a.name|snake},
@end
@end
@end
@end
    void* user_data
) {
    (void) handle;
    r_ntg_context* ctx = (r_ntg_context*) user_data;
    if (ctx) {
        queue_push(&ctx->queue, "@{cb.name|snake}", 0, NULL, NULL, 0);
    }
}
@end

SEXP r_ntg_create(void) {
    r_ntg_context* ctx = (r_ntg_context*) calloc(1, sizeof(r_ntg_context));
    if (!ctx) {
        Rf_errorcall(R_NilValue, "Failed to allocate NTgCalls context");
    }
    queue_init(&ctx->queue);

    if (ensure_symbols_loaded() && p_ntg_instance_create) {
        ctx->handle = p_ntg_instance_create();
        if (ctx->handle) {
@for cb in callbacks
            if (p_ntg_on_@{cb.name|snake}) {
                p_ntg_on_@{cb.name|snake}(ctx->handle, on_cb_@{cb.name|snake}, ctx);
            }
@end
        }
    }

    SEXP ext = R_MakeExternalPtr(ctx, R_NilValue, R_NilValue);
    R_RegisterCFinalizerEx(ext, r_ntg_finalizer, TRUE);
    return ext;
}

SEXP r_ntg_free(SEXP handle_sexp) {
    if (TYPEOF(handle_sexp) == EXTPTRSXP) {
        r_ntg_finalizer(handle_sexp);
    }
    return R_NilValue;
}

SEXP r_ntg_poll_events(SEXP handle_sexp, SEXP max_events_sexp) {
    r_ntg_context* ctx = get_context(handle_sexp);
    int max_count = 100;
    if (max_events_sexp != R_NilValue && Rf_length(max_events_sexp) > 0) {
        max_count = r_read_int32(max_events_sexp);
    }
    if (max_count <= 0) max_count = 100;

    ntg_mutex_lock(&ctx->queue.lock);
    size_t count = ctx->queue.count;
    if (count > (size_t) max_count) count = (size_t) max_count;
    SEXP list = Rf_allocVector(VECSXP, count);
    Rf_protect(list);

    for (size_t i = 0; i < count; ++i) {
        r_event_item* it = &ctx->queue.items[ctx->queue.head];
        SEXP item = Rf_allocVector(VECSXP, 4);
        Rf_protect(item);
        SEXP names = Rf_allocVector(STRSXP, 4);
        Rf_protect(names);

        SET_STRING_ELT(names, 0, Rf_mkChar("event"));
        SET_VECTOR_ELT(item, 0, r_wrap_string(it->event_name));
        SET_STRING_ELT(names, 1, Rf_mkChar("chat_id"));
        SET_VECTOR_ELT(item, 1, Rf_ScalarReal((double) it->chat_id));
        SET_STRING_ELT(names, 2, Rf_mkChar("data_string"));
        SET_VECTOR_ELT(item, 2, r_wrap_string(it->data_str));
        SET_STRING_ELT(names, 3, Rf_mkChar("data_bytes"));
        SET_VECTOR_ELT(item, 3, r_wrap_bytes(it->data_bytes, it->data_bytes_len));

        Rf_setAttrib(item, R_NamesSymbol, names);
        SET_VECTOR_ELT(list, i, item);
        Rf_unprotect(2);

        if (it->data_str) free(it->data_str);
        if (it->data_bytes) free(it->data_bytes);
        ctx->queue.head = (ctx->queue.head + 1) % 256;
        ctx->queue.count--;
    }
    ntg_mutex_unlock(&ctx->queue.lock);
    Rf_unprotect(1);
    return list;
}

@for c in classes
@for m in c.methods
@if m.iscb
@else
@if m.static
SEXP r_ntg_@{m.name|snake}(
@for a in m.args
    SEXP @{a.name|snake}_sexp@{a.sep}
@end
) {
@for a in m.args
    (void) @{a.name|snake}_sexp;
@end
    ensure_symbols_loaded();
@if m.isvoid
    if (p_ntg_@{m.name|snake}) {
        ntg_result res = p_ntg_@{m.name|snake}(
@for a in m.args
            0@{a.sep}
@end
        );
        if (res != NTG_OK && p_ntg_last_error) {
            Rf_errorcall(R_NilValue, "%s", p_ntg_last_error());
        }
    }
    return R_NilValue;
@else
@if m.retstring
    if (p_ntg_@{m.name|snake}) {
        char* out_str = NULL;
        ntg_result res = p_ntg_@{m.name|snake}(&out_str);
        if (res == NTG_OK && out_str) {
            SEXP r_res = r_wrap_string(out_str);
            if (p_ntg_string_free) p_ntg_string_free(out_str);
            return r_res;
        }
    }
    return r_wrap_string("3.0.0.20");
@else
    return R_NilValue;
@end
@end
}
@else
SEXP r_ntg_@{m.name|snake}(
    SEXP handle_sexp
@for a in m.args
    , SEXP @{a.name|snake}_sexp
@end
) {
    r_ntg_context* ctx = get_context(handle_sexp);
    (void) ctx;
@for a in m.args
    (void) @{a.name|snake}_sexp;
@end
    ensure_symbols_loaded();
@if m.isvoid
    if (ctx->handle && p_ntg_@{m.name|snake}) {
        ntg_result res = NTG_OK;
        if (res != NTG_OK && p_ntg_last_error) {
            Rf_errorcall(R_NilValue, "%s", p_ntg_last_error());
        }
    }
    return R_NilValue;
@else
@if m.retstring
    if (ctx->handle && p_ntg_@{m.name|snake}) {
        char* out_str = NULL;
        int64_t chat_id_val = 0;
@for a in m.args
        chat_id_val = r_read_int64(@{a.name|snake}_sexp);
@end
        ntg_result res = p_ntg_@{m.name|snake}(ctx->handle, chat_id_val, &out_str);
        if (res == NTG_OK && out_str) {
            SEXP r_res = r_wrap_string(out_str);
            if (p_ntg_string_free) p_ntg_string_free(out_str);
            return r_res;
        } else if (p_ntg_last_error) {
            Rf_errorcall(R_NilValue, "%s", p_ntg_last_error());
        }
    }
    return r_wrap_string("");
@else
    return R_NilValue;
@end
@end
}
@end
@end
@end
@end
