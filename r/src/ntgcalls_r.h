#ifndef NTGCALLS_R_H
#define NTGCALLS_R_H

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <R_ext/Visibility.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#include "ntgcalls.h"

#ifdef _WIN32
#include <windows.h>
typedef CRITICAL_SECTION ntg_mutex_t;
#define ntg_mutex_init(m) InitializeCriticalSection(m)
#define ntg_mutex_lock(m) EnterCriticalSection(m)
#define ntg_mutex_unlock(m) LeaveCriticalSection(m)
#define ntg_mutex_destroy(m) DeleteCriticalSection(m)
#else
#include <pthread.h>
typedef pthread_mutex_t ntg_mutex_t;
#define ntg_mutex_init(m) pthread_mutex_init(m, NULL)
#define ntg_mutex_lock(m) pthread_mutex_lock(m)
#define ntg_mutex_unlock(m) pthread_mutex_unlock(m)
#define ntg_mutex_destroy(m) pthread_mutex_destroy(m)
#endif

typedef enum {
    NTG_EVT_UPGRADE = 1,
    NTG_EVT_STREAM_END = 2,
    NTG_EVT_CONNECTION_CHANGE = 3,
    NTG_EVT_FRAMES = 4,
    NTG_EVT_SIGNALING_DATA = 5,
    NTG_EVT_REMOTE_SOURCE_CHANGE = 6,
    NTG_EVT_REQUEST_BROADCAST_PART = 7,
    NTG_EVT_REQUEST_BROADCAST_TIMESTAMP = 8,
    NTG_EVT_REQUEST_PARTICIPANTS = 9,
    NTG_EVT_OUTBOUND_BLOCK = 10,
    NTG_EVT_SUBCHAIN_REQUEST = 11,
    NTG_EVT_UPDATE_EMOJIS = 12,
    NTG_EVT_LOG = 13
} ntg_event_type;

typedef struct ntg_event_node {
    ntg_event_type type;
    int64_t chat_id;
    union {
        ntg_media_state upgrade_state;
        struct {
            ntg_stream_type type;
            ntg_stream_device device;
        } stream_end;
        ntg_connection_info connection_info;
        struct {
            uint8_t* data;
            size_t data_len;
        } raw_data;
        ntg_remote_source remote_source;
        ntg_segment_part_request broadcast_part_request;
        ntg_subchain_request subchain_request;
        char* emojis;
        struct {
            ntg_log_level level;
            ntg_log_source source;
            char* file;
            uint32_t line;
            char* message;
        } log_msg;
    } data;
    struct ntg_event_node* next;
} ntg_event_node;

typedef struct ntg_event_queue {
    ntg_event_node* head;
    ntg_event_node* tail;
    size_t count;
    ntg_mutex_t lock;
} ntg_event_queue;

typedef struct ntg_client_holder {
    ntg_instance* instance;
    ntg_event_queue queue;
    bool active;
} ntg_client_holder;

SEXP r_ntg_instance_create(void);
SEXP r_ntg_instance_destroy(SEXP s_handle);
SEXP r_ntg_get_version(void);
SEXP r_ntg_last_error(void);
SEXP r_ntg_ping(void);
SEXP r_ntg_cpu_usage(SEXP s_handle);
SEXP r_ntg_enable_glib_loop(SEXP s_enable);
SEXP r_ntg_get_protocol(void);
SEXP r_ntg_get_media_devices(void);

SEXP r_ntg_create_p2p_call(SEXP s_handle, SEXP s_user_id);
SEXP r_ntg_init_exchange(SEXP s_handle, SEXP s_user_id, SEXP s_dh_config, SEXP s_ga_hash);
SEXP r_ntg_exchange_keys(SEXP s_handle, SEXP s_user_id, SEXP s_g_a_or_b, SEXP s_fingerprint);
SEXP r_ntg_skip_exchange(SEXP s_handle, SEXP s_user_id, SEXP s_key, SEXP s_outgoing);
SEXP r_ntg_connect_p2p(SEXP s_handle, SEXP s_user_id, SEXP s_servers, SEXP s_versions, SEXP s_p2p_allowed, SEXP s_custom_params);

SEXP r_ntg_create_call(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_init_presentation(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_init_conference(SEXP s_handle, SEXP s_chat_id, SEXP s_user_id, SEXP s_last_block);
SEXP r_ntg_connect(SEXP s_handle, SEXP s_chat_id, SEXP s_params, SEXP s_presentation);

SEXP r_ntg_add_incoming_video(SEXP s_handle, SEXP s_chat_id, SEXP s_user_id, SEXP s_endpoint, SEXP s_ssrc_groups);
SEXP r_ntg_remove_incoming_video(SEXP s_handle, SEXP s_chat_id, SEXP s_endpoint);
SEXP r_ntg_set_stream_sources(SEXP s_handle, SEXP s_chat_id, SEXP s_mode, SEXP s_media);
SEXP r_ntg_pause(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_resume(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_mute(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_unmute(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_stop(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_stop_presentation(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_get_emojis_fingerprint(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_time(SEXP s_handle, SEXP s_chat_id, SEXP s_mode);
SEXP r_ntg_get_state(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_get_call_type(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_get_connection_mode(SEXP s_handle, SEXP s_chat_id);
SEXP r_ntg_calls(SEXP s_handle);

SEXP r_ntg_send_broadcast_timestamp(SEXP s_handle, SEXP s_chat_id, SEXP s_timestamp);
SEXP r_ntg_send_broadcast_part(SEXP s_handle, SEXP s_chat_id, SEXP s_segment_id, SEXP s_part_id, SEXP s_status, SEXP s_quality_update, SEXP s_data);
SEXP r_ntg_send_signaling_data(SEXP s_handle, SEXP s_chat_id, SEXP s_data);
SEXP r_ntg_send_external_frame(SEXP s_handle, SEXP s_chat_id, SEXP s_device, SEXP s_data, SEXP s_frame_data);
SEXP r_ntg_update_audio_ssrc_mappings(SEXP s_handle, SEXP s_chat_id, SEXP s_mappings);
SEXP r_ntg_apply_blocks(SEXP s_handle, SEXP s_chat_id, SEXP s_subchain, SEXP s_next_offset, SEXP s_blocks, SEXP s_short_poll);
SEXP r_ntg_finish_subchain_request(SEXP s_handle, SEXP s_chat_id, SEXP s_subchain);

SEXP r_ntg_setup_callbacks(SEXP s_handle);
SEXP r_ntg_poll_events(SEXP s_handle, SEXP s_max_events);

#endif
