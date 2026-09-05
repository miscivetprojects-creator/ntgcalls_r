#include "ntgcalls_r.h"
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
static HMODULE ntg_lib_handle = NULL;
#else
#include <dlfcn.h>
static void* ntg_lib_handle = NULL;
#endif

typedef ntg_instance* (*fn_ntg_instance_create)(void);
typedef void (*fn_ntg_instance_destroy)(ntg_instance*);
typedef const char* (*fn_ntg_get_version)(void);
typedef const char* (*fn_ntg_last_error)(void);
typedef void (*fn_ntg_set_log_callback)(ntg_log_cb, void*);
typedef void (*fn_ntg_string_free)(char*);
typedef void (*fn_ntg_bytes_free)(void*);

typedef void (*fn_ntg_connection_info_free)(ntg_connection_info*);
typedef void (*fn_ntg_remote_source_free)(ntg_remote_source*);
typedef void (*fn_ntg_subchain_request_free)(ntg_subchain_request*);
typedef void (*fn_ntg_audio_description_free)(ntg_audio_description*);
typedef void (*fn_ntg_call_info_free)(ntg_call_info*);
typedef void (*fn_ntg_device_info_free)(ntg_device_info*);
typedef void (*fn_ntg_media_devices_free)(ntg_media_devices*);
typedef void (*fn_ntg_media_state_free)(ntg_media_state*);
typedef void (*fn_ntg_video_description_free)(ntg_video_description*);
typedef void (*fn_ntg_media_description_free)(ntg_media_description*);
typedef void (*fn_ntg_frame_data_free)(ntg_frame_data*);
typedef void (*fn_ntg_ssrc_group_free)(ntg_ssrc_group*);
typedef void (*fn_ntg_frame_free)(ntg_frame*);
typedef void (*fn_ntg_segment_part_request_free)(ntg_segment_part_request*);
typedef void (*fn_ntg_ssrc_mapping_free)(ntg_ssrc_mapping*);
typedef void (*fn_ntg_auth_params_free)(ntg_auth_params*);
typedef void (*fn_ntg_conference_join_params_free)(ntg_conference_join_params*);
typedef void (*fn_ntg_dh_config_free)(ntg_dh_config*);
typedef void (*fn_ntg_protocol_free)(ntg_protocol*);
typedef void (*fn_ntg_rtc_server_free)(ntg_rtc_server*);
typedef void (*fn_ntg_call_info_entry_free)(ntg_call_info_entry*, size_t);

typedef ntg_result (*fn_ntg_create_p2p_call)(ntg_instance*, int64_t);
typedef ntg_result (*fn_ntg_init_exchange)(ntg_instance*, int64_t, ntg_dh_config, const uint8_t*, size_t, uint8_t**, size_t*);
typedef ntg_result (*fn_ntg_exchange_keys)(ntg_instance*, int64_t, const uint8_t*, size_t, int64_t, ntg_auth_params*);
typedef ntg_result (*fn_ntg_skip_exchange)(ntg_instance*, int64_t, const uint8_t*, size_t, bool);
typedef ntg_result (*fn_ntg_connect_p2p)(ntg_instance*, int64_t, const ntg_rtc_server*, size_t, const char**, size_t, bool, const char*);
typedef ntg_result (*fn_ntg_create_call)(ntg_instance*, int64_t, char**);
typedef ntg_result (*fn_ntg_init_presentation)(ntg_instance*, int64_t, char**);
typedef ntg_result (*fn_ntg_init_conference)(ntg_instance*, int64_t, int64_t, const uint8_t*, size_t, ntg_conference_join_params*);
typedef ntg_result (*fn_ntg_connect)(ntg_instance*, int64_t, const char*, bool);
typedef ntg_result (*fn_ntg_add_incoming_video)(ntg_instance*, int64_t, int64_t, const char*, const ntg_ssrc_group*, size_t, uint32_t*);
typedef ntg_result (*fn_ntg_remove_incoming_video)(ntg_instance*, int64_t, const char*, bool*);
typedef ntg_result (*fn_ntg_set_stream_sources)(ntg_instance*, int64_t, ntg_stream_mode, ntg_media_description);
typedef ntg_result (*fn_ntg_pause)(ntg_instance*, int64_t, bool*);
typedef ntg_result (*fn_ntg_resume)(ntg_instance*, int64_t, bool*);
typedef ntg_result (*fn_ntg_mute)(ntg_instance*, int64_t, bool*);
typedef ntg_result (*fn_ntg_unmute)(ntg_instance*, int64_t, bool*);
typedef ntg_result (*fn_ntg_stop)(ntg_instance*, int64_t);
typedef ntg_result (*fn_ntg_stop_presentation)(ntg_instance*, int64_t);
typedef ntg_result (*fn_ntg_get_emojis_fingerprint)(ntg_instance*, int64_t, char**);
typedef ntg_result (*fn_ntg_time)(ntg_instance*, int64_t, ntg_stream_mode, uint64_t*);
typedef ntg_result (*fn_ntg_get_state)(ntg_instance*, int64_t, ntg_media_state*);
typedef ntg_result (*fn_ntg_get_call_type)(ntg_instance*, int64_t, ntg_call_type*);
typedef ntg_result (*fn_ntg_get_connection_mode)(ntg_instance*, int64_t, ntg_connection_mode*);
typedef ntg_result (*fn_ntg_cpu_usage)(ntg_instance*, double*);
typedef ntg_result (*fn_ntg_ping)(char**);
typedef ntg_result (*fn_ntg_get_media_devices)(ntg_media_devices*);
typedef ntg_result (*fn_ntg_get_protocol)(ntg_protocol*);
typedef ntg_result (*fn_ntg_enable_glib_loop)(bool);
typedef ntg_result (*fn_ntg_send_broadcast_timestamp)(ntg_instance*, int64_t, int64_t);
typedef ntg_result (*fn_ntg_send_broadcast_part)(ntg_instance*, int64_t, int64_t, int32_t, ntg_media_segment_part_status, bool, const uint8_t*, size_t);
typedef ntg_result (*fn_ntg_send_signaling_data)(ntg_instance*, int64_t, const uint8_t*, size_t);
typedef ntg_result (*fn_ntg_send_external_frame)(ntg_instance*, int64_t, ntg_stream_device, const uint8_t*, size_t, ntg_frame_data);
typedef ntg_result (*fn_ntg_update_audio_ssrc_mappings)(ntg_instance*, int64_t, const ntg_ssrc_mapping*, size_t);
typedef ntg_result (*fn_ntg_apply_blocks)(ntg_instance*, int64_t, int32_t, int32_t, const ntg_bytes*, size_t, bool);
typedef ntg_result (*fn_ntg_finish_subchain_request)(ntg_instance*, int64_t, int32_t);
typedef ntg_result (*fn_ntg_calls)(ntg_instance*, ntg_call_info_entry**, size_t*);

typedef ntg_result (*fn_ntg_on_upgrade_callback)(ntg_instance*, ntg_upgrade_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_stream_end_callback)(ntg_instance*, ntg_stream_end_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_connection_change_callback)(ntg_instance*, ntg_connection_change_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_frames_callback)(ntg_instance*, ntg_frames_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_signaling_data_callback)(ntg_instance*, ntg_signaling_data_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_remote_source_change_callback)(ntg_instance*, ntg_remote_source_change_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_request_broadcast_part_callback)(ntg_instance*, ntg_request_broadcast_part_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_request_broadcast_timestamp_callback)(ntg_instance*, ntg_request_broadcast_timestamp_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_request_participants_callback)(ntg_instance*, ntg_request_participants_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_outbound_block_callback)(ntg_instance*, ntg_outbound_block_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_subchain_request_callback)(ntg_instance*, ntg_subchain_request_callback_cb, void*);
typedef ntg_result (*fn_ntg_on_update_emojis_callback)(ntg_instance*, ntg_update_emojis_callback_cb, void*);

static fn_ntg_instance_create p_ntg_instance_create = NULL;
static fn_ntg_instance_destroy p_ntg_instance_destroy = NULL;
static fn_ntg_get_version p_ntg_get_version = NULL;
static fn_ntg_last_error p_ntg_last_error = NULL;
static fn_ntg_set_log_callback p_ntg_set_log_callback = NULL;
static fn_ntg_string_free p_ntg_string_free = NULL;
static fn_ntg_bytes_free p_ntg_bytes_free = NULL;

static fn_ntg_connection_info_free p_ntg_connection_info_free = NULL;
static fn_ntg_remote_source_free p_ntg_remote_source_free = NULL;
static fn_ntg_subchain_request_free p_ntg_subchain_request_free = NULL;
static fn_ntg_audio_description_free p_ntg_audio_description_free = NULL;
static fn_ntg_call_info_free p_ntg_call_info_free = NULL;
static fn_ntg_device_info_free p_ntg_device_info_free = NULL;
static fn_ntg_media_devices_free p_ntg_media_devices_free = NULL;
static fn_ntg_media_state_free p_ntg_media_state_free = NULL;
static fn_ntg_video_description_free p_ntg_video_description_free = NULL;
static fn_ntg_media_description_free p_ntg_media_description_free = NULL;
static fn_ntg_frame_data_free p_ntg_frame_data_free = NULL;
static fn_ntg_ssrc_group_free p_ntg_ssrc_group_free = NULL;
static fn_ntg_frame_free p_ntg_frame_free = NULL;
static fn_ntg_segment_part_request_free p_ntg_segment_part_request_free = NULL;
static fn_ntg_ssrc_mapping_free p_ntg_ssrc_mapping_free = NULL;
static fn_ntg_auth_params_free p_ntg_auth_params_free = NULL;
static fn_ntg_conference_join_params_free p_ntg_conference_join_params_free = NULL;
static fn_ntg_dh_config_free p_ntg_dh_config_free = NULL;
static fn_ntg_protocol_free p_ntg_protocol_free = NULL;
static fn_ntg_rtc_server_free p_ntg_rtc_server_free = NULL;
static fn_ntg_call_info_entry_free p_ntg_call_info_entry_free = NULL;

static fn_ntg_create_p2p_call p_ntg_create_p2p_call = NULL;
static fn_ntg_init_exchange p_ntg_init_exchange = NULL;
static fn_ntg_exchange_keys p_ntg_exchange_keys = NULL;
static fn_ntg_skip_exchange p_ntg_skip_exchange = NULL;
static fn_ntg_connect_p2p p_ntg_connect_p2p = NULL;
static fn_ntg_create_call p_ntg_create_call = NULL;
static fn_ntg_init_presentation p_ntg_init_presentation = NULL;
static fn_ntg_init_conference p_ntg_init_conference = NULL;
static fn_ntg_connect p_ntg_connect = NULL;
static fn_ntg_add_incoming_video p_ntg_add_incoming_video = NULL;
static fn_ntg_remove_incoming_video p_ntg_remove_incoming_video = NULL;
static fn_ntg_set_stream_sources p_ntg_set_stream_sources = NULL;
static fn_ntg_pause p_ntg_pause = NULL;
static fn_ntg_resume p_ntg_resume = NULL;
static fn_ntg_mute p_ntg_mute = NULL;
static fn_ntg_unmute p_ntg_unmute = NULL;
static fn_ntg_stop p_ntg_stop = NULL;
static fn_ntg_stop_presentation p_ntg_stop_presentation = NULL;
static fn_ntg_get_emojis_fingerprint p_ntg_get_emojis_fingerprint = NULL;
static fn_ntg_time p_ntg_time = NULL;
static fn_ntg_get_state p_ntg_get_state = NULL;
static fn_ntg_get_call_type p_ntg_get_call_type = NULL;
static fn_ntg_get_connection_mode p_ntg_get_connection_mode = NULL;
static fn_ntg_cpu_usage p_ntg_cpu_usage = NULL;
static fn_ntg_ping p_ntg_ping = NULL;
static fn_ntg_get_media_devices p_ntg_get_media_devices = NULL;
static fn_ntg_get_protocol p_ntg_get_protocol = NULL;
static fn_ntg_enable_glib_loop p_ntg_enable_glib_loop = NULL;
static fn_ntg_send_broadcast_timestamp p_ntg_send_broadcast_timestamp = NULL;
static fn_ntg_send_broadcast_part p_ntg_send_broadcast_part = NULL;
static fn_ntg_send_signaling_data p_ntg_send_signaling_data = NULL;
static fn_ntg_send_external_frame p_ntg_send_external_frame = NULL;
static fn_ntg_update_audio_ssrc_mappings p_ntg_update_audio_ssrc_mappings = NULL;
static fn_ntg_apply_blocks p_ntg_apply_blocks = NULL;
static fn_ntg_finish_subchain_request p_ntg_finish_subchain_request = NULL;
static fn_ntg_calls p_ntg_calls = NULL;

static fn_ntg_on_upgrade_callback p_ntg_on_upgrade_callback = NULL;
static fn_ntg_on_stream_end_callback p_ntg_on_stream_end_callback = NULL;
static fn_ntg_on_connection_change_callback p_ntg_on_connection_change_callback = NULL;
static fn_ntg_on_frames_callback p_ntg_on_frames_callback = NULL;
static fn_ntg_on_signaling_data_callback p_ntg_on_signaling_data_callback = NULL;
static fn_ntg_on_remote_source_change_callback p_ntg_on_remote_source_change_callback = NULL;
static fn_ntg_on_request_broadcast_part_callback p_ntg_on_request_broadcast_part_callback = NULL;
static fn_ntg_on_request_broadcast_timestamp_callback p_ntg_on_request_broadcast_timestamp_callback = NULL;
static fn_ntg_on_request_participants_callback p_ntg_on_request_participants_callback = NULL;
static fn_ntg_on_outbound_block_callback p_ntg_on_outbound_block_callback = NULL;
static fn_ntg_on_subchain_request_callback p_ntg_on_subchain_request_callback = NULL;
static fn_ntg_on_update_emojis_callback p_ntg_on_update_emojis_callback = NULL;

static void* resolve_symbol(const char* name) {
#ifdef _WIN32
    if (ntg_lib_handle) {
        void* ptr = (void*)GetProcAddress(ntg_lib_handle, name);
        if (ptr) return ptr;
    }
    HMODULE current = GetModuleHandle(NULL);
    if (current) {
        void* ptr = (void*)GetProcAddress(current, name);
        if (ptr) return ptr;
    }
#else
    if (ntg_lib_handle) {
        void* ptr = dlsym(ntg_lib_handle, name);
        if (ptr) return ptr;
    }
    void* ptr = dlsym(RTLD_DEFAULT, name);
    if (ptr) return ptr;
#endif
    return NULL;
}

static void ensure_symbols_loaded(void) {
    if (p_ntg_instance_create != NULL) {
        return;
    }
#ifdef _WIN32
    if (!ntg_lib_handle) {
        const char* custom_path = getenv("NTGCALLS_LIB_PATH");
        if (custom_path) {
            ntg_lib_handle = LoadLibraryA(custom_path);
        }
        if (!ntg_lib_handle) ntg_lib_handle = LoadLibraryA("ntgcalls.dll");
        if (!ntg_lib_handle) ntg_lib_handle = LoadLibraryA("libntgcalls.dll");
        if (!ntg_lib_handle) ntg_lib_handle = LoadLibraryA("ntgcalls-native.dll");
    }
#else
    if (!ntg_lib_handle) {
        const char* custom_path = getenv("NTGCALLS_LIB_PATH");
        if (custom_path) {
            ntg_lib_handle = dlopen(custom_path, RTLD_LAZY | RTLD_GLOBAL);
        }
        if (!ntg_lib_handle) ntg_lib_handle = dlopen("libntgcalls.so", RTLD_LAZY | RTLD_GLOBAL);
        if (!ntg_lib_handle) ntg_lib_handle = dlopen("libntgcalls.dylib", RTLD_LAZY | RTLD_GLOBAL);
        if (!ntg_lib_handle) ntg_lib_handle = dlopen("libntgcalls-native.so", RTLD_LAZY | RTLD_GLOBAL);
    }
#endif

#define BIND_SYM(name) p_##name = (fn_##name)resolve_symbol(#name)
    BIND_SYM(ntg_instance_create);
    BIND_SYM(ntg_instance_destroy);
    BIND_SYM(ntg_get_version);
    BIND_SYM(ntg_last_error);
    BIND_SYM(ntg_set_log_callback);
    BIND_SYM(ntg_string_free);
    BIND_SYM(ntg_bytes_free);

    BIND_SYM(ntg_connection_info_free);
    BIND_SYM(ntg_remote_source_free);
    BIND_SYM(ntg_subchain_request_free);
    BIND_SYM(ntg_audio_description_free);
    BIND_SYM(ntg_call_info_free);
    BIND_SYM(ntg_device_info_free);
    BIND_SYM(ntg_media_devices_free);
    BIND_SYM(ntg_media_state_free);
    BIND_SYM(ntg_video_description_free);
    BIND_SYM(ntg_media_description_free);
    BIND_SYM(ntg_frame_data_free);
    BIND_SYM(ntg_ssrc_group_free);
    BIND_SYM(ntg_frame_free);
    BIND_SYM(ntg_segment_part_request_free);
    BIND_SYM(ntg_ssrc_mapping_free);
    BIND_SYM(ntg_auth_params_free);
    BIND_SYM(ntg_conference_join_params_free);
    BIND_SYM(ntg_dh_config_free);
    BIND_SYM(ntg_protocol_free);
    BIND_SYM(ntg_rtc_server_free);
    BIND_SYM(ntg_call_info_entry_free);

    BIND_SYM(ntg_create_p2p_call);
    BIND_SYM(ntg_init_exchange);
    BIND_SYM(ntg_exchange_keys);
    BIND_SYM(ntg_skip_exchange);
    BIND_SYM(ntg_connect_p2p);
    BIND_SYM(ntg_create_call);
    BIND_SYM(ntg_init_presentation);
    BIND_SYM(ntg_init_conference);
    BIND_SYM(ntg_connect);
    BIND_SYM(ntg_add_incoming_video);
    BIND_SYM(ntg_remove_incoming_video);
    BIND_SYM(ntg_set_stream_sources);
    BIND_SYM(ntg_pause);
    BIND_SYM(ntg_resume);
    BIND_SYM(ntg_mute);
    BIND_SYM(ntg_unmute);
    BIND_SYM(ntg_stop);
    BIND_SYM(ntg_stop_presentation);
    BIND_SYM(ntg_get_emojis_fingerprint);
    BIND_SYM(ntg_time);
    BIND_SYM(ntg_get_state);
    BIND_SYM(ntg_get_call_type);
    BIND_SYM(ntg_get_connection_mode);
    BIND_SYM(ntg_cpu_usage);
    BIND_SYM(ntg_ping);
    BIND_SYM(ntg_get_media_devices);
    BIND_SYM(ntg_get_protocol);
    BIND_SYM(ntg_enable_glib_loop);
    BIND_SYM(ntg_send_broadcast_timestamp);
    BIND_SYM(ntg_send_broadcast_part);
    BIND_SYM(ntg_send_signaling_data);
    BIND_SYM(ntg_send_external_frame);
    BIND_SYM(ntg_update_audio_ssrc_mappings);
    BIND_SYM(ntg_apply_blocks);
    BIND_SYM(ntg_finish_subchain_request);
    BIND_SYM(ntg_calls);

    BIND_SYM(ntg_on_upgrade_callback);
    BIND_SYM(ntg_on_stream_end_callback);
    BIND_SYM(ntg_on_connection_change_callback);
    BIND_SYM(ntg_on_frames_callback);
    BIND_SYM(ntg_on_signaling_data_callback);
    BIND_SYM(ntg_on_remote_source_change_callback);
    BIND_SYM(ntg_on_request_broadcast_part_callback);
    BIND_SYM(ntg_on_request_broadcast_timestamp_callback);
    BIND_SYM(ntg_on_request_participants_callback);
    BIND_SYM(ntg_on_outbound_block_callback);
    BIND_SYM(ntg_on_subchain_request_callback);
    BIND_SYM(ntg_on_update_emojis_callback);
#undef BIND_SYM
}

static void check_symbols_available(void) {
    ensure_symbols_loaded();
    if (!p_ntg_instance_create || !p_ntg_instance_destroy) {
        Rf_error("Native NTgCalls library symbols not loaded. Set NTGCALLS_LIB_PATH to libntgcalls shared library.");
    }
}

static void queue_push(ntg_event_queue* queue, ntg_event_node* node) {
    if (!queue || !node) return;
    ntg_mutex_lock(&queue->lock);
    node->next = NULL;
    if (queue->tail) {
        queue->tail->next = node;
        queue->tail = node;
    } else {
        queue->head = node;
        queue->tail = node;
    }
    queue->count++;
    ntg_mutex_unlock(&queue->lock);
}

static void free_event_node(ntg_event_node* node) {
    if (!node) return;
    switch (node->type) {
        case NTG_EVT_SIGNALING_DATA:
        case NTG_EVT_OUTBOUND_BLOCK:
            if (node->data.raw_data.data) {
                free(node->data.raw_data.data);
            }
            break;
        case NTG_EVT_UPDATE_EMOJIS:
            if (node->data.emojis) {
                free(node->data.emojis);
            }
            break;
        case NTG_EVT_LOG:
            if (node->data.log_msg.file) free(node->data.log_msg.file);
            if (node->data.log_msg.message) free(node->data.log_msg.message);
            break;
        default:
            break;
    }
    free(node);
}

static void queue_clear(ntg_event_queue* queue) {
    if (!queue) return;
    ntg_mutex_lock(&queue->lock);
    ntg_event_node* curr = queue->head;
    while (curr) {
        ntg_event_node* next = curr->next;
        free_event_node(curr);
        curr = next;
    }
    queue->head = NULL;
    queue->tail = NULL;
    queue->count = 0;
    ntg_mutex_unlock(&queue->lock);
}

static void cb_trampoline_upgrade(ntg_instance* handle, int64_t chat_id, ntg_media_state state, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_UPGRADE;
    node->chat_id = chat_id;
    node->data.upgrade_state = state;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_stream_end(ntg_instance* handle, int64_t chat_id, ntg_stream_type type, ntg_stream_device device, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_STREAM_END;
    node->chat_id = chat_id;
    node->data.stream_end.type = type;
    node->data.stream_end.device = device;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_connection_change(ntg_instance* handle, int64_t chat_id, ntg_connection_info state, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_CONNECTION_CHANGE;
    node->chat_id = chat_id;
    node->data.connection_info = state;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_signaling_data(ntg_instance* handle, int64_t chat_id, const uint8_t* data, size_t data_len, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_SIGNALING_DATA;
    node->chat_id = chat_id;
    if (data && data_len > 0) {
        node->data.raw_data.data = (uint8_t*)malloc(data_len);
        if (node->data.raw_data.data) {
            memcpy(node->data.raw_data.data, data, data_len);
            node->data.raw_data.data_len = data_len;
        }
    }
    queue_push(&holder->queue, node);
}

static void cb_trampoline_remote_source_change(ntg_instance* handle, int64_t chat_id, ntg_remote_source state, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_REMOTE_SOURCE_CHANGE;
    node->chat_id = chat_id;
    node->data.remote_source = state;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_request_broadcast_part(ntg_instance* handle, int64_t chat_id, ntg_segment_part_request request, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_REQUEST_BROADCAST_PART;
    node->chat_id = chat_id;
    node->data.broadcast_part_request = request;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_request_broadcast_timestamp(ntg_instance* handle, int64_t chat_id, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_REQUEST_BROADCAST_TIMESTAMP;
    node->chat_id = chat_id;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_request_participants(ntg_instance* handle, int64_t chat_id, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_REQUEST_PARTICIPANTS;
    node->chat_id = chat_id;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_outbound_block(ntg_instance* handle, int64_t chat_id, const uint8_t* block, size_t block_len, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_OUTBOUND_BLOCK;
    node->chat_id = chat_id;
    if (block && block_len > 0) {
        node->data.raw_data.data = (uint8_t*)malloc(block_len);
        if (node->data.raw_data.data) {
            memcpy(node->data.raw_data.data, block, block_len);
            node->data.raw_data.data_len = block_len;
        }
    }
    queue_push(&holder->queue, node);
}

static void cb_trampoline_subchain_request(ntg_instance* handle, int64_t chat_id, ntg_subchain_request subchain_request, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_SUBCHAIN_REQUEST;
    node->chat_id = chat_id;
    node->data.subchain_request = subchain_request;
    queue_push(&holder->queue, node);
}

static void cb_trampoline_update_emojis(ntg_instance* handle, int64_t chat_id, const char* emojis, void* user_data) {
    ntg_client_holder* holder = (ntg_client_holder*)user_data;
    if (!holder || !holder->active) return;
    ntg_event_node* node = (ntg_event_node*)calloc(1, sizeof(ntg_event_node));
    if (!node) return;
    node->type = NTG_EVT_UPDATE_EMOJIS;
    node->chat_id = chat_id;
    if (emojis) {
        node->data.emojis = strdup(emojis);
    }
    queue_push(&holder->queue, node);
}

static void client_holder_finalizer(SEXP ext_ptr) {
    if (TYPEOF(ext_ptr) != EXTPTRSXP) return;
    ntg_client_holder* holder = (ntg_client_holder*)R_ExternalPtrAddr(ext_ptr);
    if (!holder) return;
    holder->active = false;
    if (holder->instance && p_ntg_instance_destroy) {
        p_ntg_instance_destroy(holder->instance);
        holder->instance = NULL;
    }
    queue_clear(&holder->queue);
    ntg_mutex_destroy(&holder->queue.lock);
    free(holder);
    R_ClearExternalPtr(ext_ptr);
}

static ntg_client_holder* get_client_holder(SEXP s_handle) {
    if (TYPEOF(s_handle) != EXTPTRSXP) {
        Rf_error("Invalid handle: expected external pointer");
    }
    ntg_client_holder* holder = (ntg_client_holder*)R_ExternalPtrAddr(s_handle);
    if (!holder || !holder->active || !holder->instance) {
        Rf_error("NTgCalls instance is closed or null");
    }
    return holder;
}

static void check_call_result(ntg_result res) {
    if (res == NTG_OK) return;
    const char* err = p_ntg_last_error ? p_ntg_last_error() : NULL;
    if (err && strlen(err) > 0) {
        Rf_error("NTgCalls error (%d): %s", res, err);
    } else {
        Rf_error("NTgCalls error code: %d", res);
    }
}

static int64_t sexp_to_int64(SEXP s) {
    if (TYPEOF(s) == REALSXP) {
        return (int64_t)REAL(s)[0];
    } else if (TYPEOF(s) == INTSXP) {
        return (int64_t)INTEGER(s)[0];
    } else if (TYPEOF(s) == STRSXP) {
        const char* str = CHAR(STRING_ELT(s, 0));
        return (int64_t)atoll(str);
    }
    Rf_error("Expected numeric or string for 64-bit integer");
    return 0;
}

static const char* sexp_to_cstring_opt(SEXP s) {
    if (s == R_NilValue || (TYPEOF(s) == STRSXP && LENGTH(s) == 0)) return NULL;
    if (TYPEOF(s) != STRSXP) Rf_error("Expected character string");
    return CHAR(STRING_ELT(s, 0));
}

static const char* sexp_to_cstring(SEXP s) {
    const char* str = sexp_to_cstring_opt(s);
    if (!str) Rf_error("Expected non-null character string");
    return str;
}

SEXP r_ntg_instance_create(void) {
    check_symbols_available();
    ntg_instance* instance = p_ntg_instance_create();
    if (!instance) {
        Rf_error("Failed to create native NTgCalls instance");
    }
    ntg_client_holder* holder = (ntg_client_holder*)calloc(1, sizeof(ntg_client_holder));
    if (!holder) {
        p_ntg_instance_destroy(instance);
        Rf_error("Out of memory allocating client holder");
    }
    holder->instance = instance;
    holder->active = true;
    ntg_mutex_init(&holder->queue.lock);

    SEXP ptr = PROTECT(R_MakeExternalPtr(holder, install("ntgcalls_handle"), R_NilValue));
    R_RegisterCFinalizerEx(ptr, client_holder_finalizer, TRUE);
    UNPROTECT(1);
    return ptr;
}

SEXP r_ntg_instance_destroy(SEXP s_handle) {
    if (TYPEOF(s_handle) != EXTPTRSXP) return ScalarLogical(FALSE);
    ntg_client_holder* holder = (ntg_client_holder*)R_ExternalPtrAddr(s_handle);
    if (!holder) return ScalarLogical(TRUE);
    holder->active = false;
    if (holder->instance && p_ntg_instance_destroy) {
        p_ntg_instance_destroy(holder->instance);
        holder->instance = NULL;
    }
    queue_clear(&holder->queue);
    ntg_mutex_destroy(&holder->queue.lock);
    free(holder);
    R_ClearExternalPtr(s_handle);
    return ScalarLogical(TRUE);
}

SEXP r_ntg_get_version(void) {
    check_symbols_available();
    const char* ver = p_ntg_get_version ? p_ntg_get_version() : "3.0.0.20";
    return mkString(ver ? ver : "");
}

SEXP r_ntg_last_error(void) {
    check_symbols_available();
    const char* err = p_ntg_last_error ? p_ntg_last_error() : "";
    return mkString(err ? err : "");
}

SEXP r_ntg_ping(void) {
    check_symbols_available();
    char* out = NULL;
    ntg_result res = p_ntg_ping(&out);
    check_call_result(res);
    SEXP ret = PROTECT(mkString(out ? out : "pong"));
    if (out && p_ntg_string_free) p_ntg_string_free(out);
    UNPROTECT(1);
    return ret;
}

SEXP r_ntg_cpu_usage(SEXP s_handle) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    double out = 0.0;
    ntg_result res = p_ntg_cpu_usage(holder->instance, &out);
    check_call_result(res);
    return ScalarReal(out);
}

SEXP r_ntg_enable_glib_loop(SEXP s_enable) {
    check_symbols_available();
    bool enable = asLogical(s_enable);
    if (p_ntg_enable_glib_loop) {
        ntg_result res = p_ntg_enable_glib_loop(enable);
        check_call_result(res);
    }
    return R_NilValue;
}

SEXP r_ntg_get_protocol(void) {
    check_symbols_available();
    ntg_protocol out;
    memset(&out, 0, sizeof(out));
    ntg_result res = p_ntg_get_protocol(&out);
    check_call_result(res);

    SEXP names = PROTECT(allocVector(STRSXP, 5));
    SET_STRING_ELT(names, 0, mkChar("min_layer"));
    SET_STRING_ELT(names, 1, mkChar("max_layer"));
    SET_STRING_ELT(names, 2, mkChar("udp_p2p"));
    SET_STRING_ELT(names, 3, mkChar("udp_reflector"));
    SET_STRING_ELT(names, 4, mkChar("library_versions"));

    SEXP r_versions = PROTECT(allocVector(STRSXP, out.library_versions_len));
    for (size_t i = 0; i < out.library_versions_len; ++i) {
        SET_STRING_ELT(r_versions, i, mkChar(out.library_versions[i]));
    }

    SEXP ret = PROTECT(allocVector(VECSXP, 5));
    SET_VECTOR_ELT(ret, 0, ScalarInteger(out.min_layer));
    SET_VECTOR_ELT(ret, 1, ScalarInteger(out.max_layer));
    SET_VECTOR_ELT(ret, 2, ScalarLogical(out.udp_p2p));
    SET_VECTOR_ELT(ret, 3, ScalarLogical(out.udp_reflector));
    SET_VECTOR_ELT(ret, 4, r_versions);
    setAttrib(ret, R_NamesSymbol, names);

    if (p_ntg_protocol_free) p_ntg_protocol_free(&out);
    UNPROTECT(3);
    return ret;
}

static SEXP convert_devices(ntg_device_info* devs, size_t len) {
    SEXP list = PROTECT(allocVector(VECSXP, len));
    if (len > 0 && devs) {
        for (size_t i = 0; i < len; ++i) {
            SEXP item = PROTECT(allocVector(VECSXP, 2));
            SEXP dev_names = PROTECT(allocVector(STRSXP, 2));
            SET_STRING_ELT(dev_names, 0, mkChar("name"));
            SET_STRING_ELT(dev_names, 1, mkChar("metadata"));
            SET_VECTOR_ELT(item, 0, mkString(devs[i].name ? devs[i].name : ""));
            SET_VECTOR_ELT(item, 1, mkString(devs[i].metadata ? devs[i].metadata : ""));
            setAttrib(item, R_NamesSymbol, dev_names);
            SET_VECTOR_ELT(list, i, item);
            UNPROTECT(2);
        }
    }
    UNPROTECT(1);
    return list;
}

SEXP r_ntg_get_media_devices(void) {
    check_symbols_available();
    ntg_media_devices out;
    memset(&out, 0, sizeof(out));
#ifdef _WIN32
    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
#endif
    ntg_result res = p_ntg_get_media_devices(&out);
#ifdef _WIN32
    if (SUCCEEDED(hr)) CoUninitialize();
#endif
    check_call_result(res);

    SEXP names = PROTECT(allocVector(STRSXP, 4));
    SET_STRING_ELT(names, 0, mkChar("microphone"));
    SET_STRING_ELT(names, 1, mkChar("speaker"));
    SET_STRING_ELT(names, 2, mkChar("camera"));
    SET_STRING_ELT(names, 3, mkChar("screen"));

    SEXP ret = PROTECT(allocVector(VECSXP, 4));
    SEXP d_mic = PROTECT(convert_devices(out.microphone, out.microphone_len));
    SET_VECTOR_ELT(ret, 0, d_mic);
    SEXP d_spk = PROTECT(convert_devices(out.speaker, out.speaker_len));
    SET_VECTOR_ELT(ret, 1, d_spk);
    SEXP d_cam = PROTECT(convert_devices(out.camera, out.camera_len));
    SET_VECTOR_ELT(ret, 2, d_cam);
    SEXP d_scr = PROTECT(convert_devices(out.screen, out.screen_len));
    SET_VECTOR_ELT(ret, 3, d_scr);
    setAttrib(ret, R_NamesSymbol, names);

    if (p_ntg_media_devices_free) p_ntg_media_devices_free(&out);
    UNPROTECT(6);
    return ret;
}





SEXP r_ntg_create_p2p_call(SEXP s_handle, SEXP s_user_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t user_id = sexp_to_int64(s_user_id);
    ntg_result res = p_ntg_create_p2p_call(holder->instance, user_id);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_init_exchange(SEXP s_handle, SEXP s_user_id, SEXP s_dh_config, SEXP s_ga_hash) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t user_id = sexp_to_int64(s_user_id);

    ntg_dh_config dh;
    memset(&dh, 0, sizeof(dh));
    dh.g = asInteger(VECTOR_ELT(s_dh_config, 0));
    SEXP s_p = VECTOR_ELT(s_dh_config, 1);
    dh.p = (uint8_t*)RAW(s_p);
    dh.p_len = LENGTH(s_p);
    SEXP s_random = VECTOR_ELT(s_dh_config, 2);
    dh.random = (uint8_t*)RAW(s_random);
    dh.random_len = LENGTH(s_random);

    const uint8_t* ga_hash_ptr = NULL;
    size_t ga_hash_len = 0;
    if (s_ga_hash != R_NilValue && TYPEOF(s_ga_hash) == RAWSXP) {
        ga_hash_ptr = (const uint8_t*)RAW(s_ga_hash);
        ga_hash_len = LENGTH(s_ga_hash);
    }

    uint8_t* out = NULL;
    size_t out_len = 0;
    ntg_result res = p_ntg_init_exchange(holder->instance, user_id, dh, ga_hash_ptr, ga_hash_len, &out, &out_len);
    check_call_result(res);

    SEXP ret = PROTECT(allocVector(RAWSXP, out_len));
    if (out && out_len > 0) {
        memcpy(RAW(ret), out, out_len);
    }
    if (out && p_ntg_bytes_free) p_ntg_bytes_free(out);
    UNPROTECT(1);
    return ret;
}

SEXP r_ntg_exchange_keys(SEXP s_handle, SEXP s_user_id, SEXP s_g_a_or_b, SEXP s_fingerprint) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t user_id = sexp_to_int64(s_user_id);
    const uint8_t* g_ptr = (const uint8_t*)RAW(s_g_a_or_b);
    size_t g_len = LENGTH(s_g_a_or_b);
    int64_t fp = sexp_to_int64(s_fingerprint);

    ntg_auth_params out;
    memset(&out, 0, sizeof(out));
    ntg_result res = p_ntg_exchange_keys(holder->instance, user_id, g_ptr, g_len, fp, &out);
    check_call_result(res);

    SEXP names = PROTECT(allocVector(STRSXP, 2));
    SET_STRING_ELT(names, 0, mkChar("key_fingerprint"));
    SET_STRING_ELT(names, 1, mkChar("g_a_or_b"));

    SEXP g_out = PROTECT(allocVector(RAWSXP, out.g_a_or_b_len));
    if (out.g_a_or_b && out.g_a_or_b_len > 0) {
        memcpy(RAW(g_out), out.g_a_or_b, out.g_a_or_b_len);
    }

    SEXP ret = PROTECT(allocVector(VECSXP, 2));
    SET_VECTOR_ELT(ret, 0, ScalarReal((double)out.key_fingerprint));
    SET_VECTOR_ELT(ret, 1, g_out);
    setAttrib(ret, R_NamesSymbol, names);

    if (p_ntg_auth_params_free) p_ntg_auth_params_free(&out);
    UNPROTECT(3);
    return ret;
}

SEXP r_ntg_skip_exchange(SEXP s_handle, SEXP s_user_id, SEXP s_key, SEXP s_outgoing) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t user_id = sexp_to_int64(s_user_id);
    const uint8_t* key_ptr = (const uint8_t*)RAW(s_key);
    size_t key_len = LENGTH(s_key);
    bool is_outgoing = asLogical(s_outgoing);

    ntg_result res = p_ntg_skip_exchange(holder->instance, user_id, key_ptr, key_len, is_outgoing);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_connect_p2p(SEXP s_handle, SEXP s_user_id, SEXP s_servers, SEXP s_versions, SEXP s_p2p_allowed, SEXP s_custom_params) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t user_id = sexp_to_int64(s_user_id);
    bool p2p_allowed = asLogical(s_p2p_allowed);
    const char* custom_params = sexp_to_cstring_opt(s_custom_params);

    size_t srv_count = LENGTH(s_servers);
    ntg_rtc_server* srvs = (ntg_rtc_server*)calloc(srv_count > 0 ? srv_count : 1, sizeof(ntg_rtc_server));
    for (size_t i = 0; i < srv_count; ++i) {
        SEXP item = VECTOR_ELT(s_servers, i);
        srvs[i].id = (uint64_t)asReal(VECTOR_ELT(item, 0));
        srvs[i].ipv4 = (char*)sexp_to_cstring(VECTOR_ELT(item, 1));
        srvs[i].ipv6 = (char*)sexp_to_cstring(VECTOR_ELT(item, 2));
        srvs[i].port = (uint16_t)asInteger(VECTOR_ELT(item, 3));
        srvs[i].username = (char*)sexp_to_cstring_opt(VECTOR_ELT(item, 4));
        srvs[i].password = (char*)sexp_to_cstring_opt(VECTOR_ELT(item, 5));
        srvs[i].turn = asLogical(VECTOR_ELT(item, 6));
        srvs[i].stun = asLogical(VECTOR_ELT(item, 7));
        srvs[i].tcp = asLogical(VECTOR_ELT(item, 8));
        SEXP s_ptag = VECTOR_ELT(item, 9);
        if (s_ptag != R_NilValue && TYPEOF(s_ptag) == RAWSXP) {
            srvs[i].peer_tag = (uint8_t*)RAW(s_ptag);
            srvs[i].peer_tag_len = LENGTH(s_ptag);
        }
    }

    size_t ver_count = LENGTH(s_versions);
    const char** vers = (const char**)calloc(ver_count > 0 ? ver_count : 1, sizeof(char*));
    for (size_t i = 0; i < ver_count; ++i) {
        vers[i] = CHAR(STRING_ELT(s_versions, i));
    }

    ntg_result res = p_ntg_connect_p2p(holder->instance, user_id, srvs, srv_count, vers, ver_count, p2p_allowed, custom_params);
    free(srvs);
    free(vers);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_create_call(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    char* out = NULL;
    ntg_result res = p_ntg_create_call(holder->instance, chat_id, &out);
    check_call_result(res);
    SEXP ret = PROTECT(mkString(out ? out : ""));
    if (out && p_ntg_string_free) p_ntg_string_free(out);
    UNPROTECT(1);
    return ret;
}

SEXP r_ntg_init_presentation(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    char* out = NULL;
    ntg_result res = p_ntg_init_presentation(holder->instance, chat_id, &out);
    check_call_result(res);
    SEXP ret = PROTECT(mkString(out ? out : ""));
    if (out && p_ntg_string_free) p_ntg_string_free(out);
    UNPROTECT(1);
    return ret;
}

SEXP r_ntg_init_conference(SEXP s_handle, SEXP s_chat_id, SEXP s_user_id, SEXP s_last_block) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    int64_t user_id = sexp_to_int64(s_user_id);

    const uint8_t* block_ptr = NULL;
    size_t block_len = 0;
    if (s_last_block != R_NilValue && TYPEOF(s_last_block) == RAWSXP) {
        block_ptr = (const uint8_t*)RAW(s_last_block);
        block_len = LENGTH(s_last_block);
    }

    ntg_conference_join_params out;
    memset(&out, 0, sizeof(out));
    ntg_result res = p_ntg_init_conference(holder->instance, chat_id, user_id, block_ptr, block_len, &out);
    check_call_result(res);

    SEXP names = PROTECT(allocVector(STRSXP, 3));
    SET_STRING_ELT(names, 0, mkChar("payload"));
    SET_STRING_ELT(names, 1, mkChar("public_key"));
    SET_STRING_ELT(names, 2, mkChar("block"));

    SEXP r_pk = PROTECT(allocVector(RAWSXP, out.public_key_len));
    if (out.public_key && out.public_key_len > 0) memcpy(RAW(r_pk), out.public_key, out.public_key_len);

    SEXP r_bl = PROTECT(allocVector(RAWSXP, out.block_len));
    if (out.block && out.block_len > 0) memcpy(RAW(r_bl), out.block, out.block_len);

    SEXP ret = PROTECT(allocVector(VECSXP, 3));
    SET_VECTOR_ELT(ret, 0, mkString(out.payload ? out.payload : ""));
    SET_VECTOR_ELT(ret, 1, r_pk);
    SET_VECTOR_ELT(ret, 2, r_bl);
    setAttrib(ret, R_NamesSymbol, names);

    if (p_ntg_conference_join_params_free) p_ntg_conference_join_params_free(&out);
    UNPROTECT(4);
    return ret;
}

SEXP r_ntg_connect(SEXP s_handle, SEXP s_chat_id, SEXP s_params, SEXP s_presentation) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    const char* params = sexp_to_cstring(s_params);
    bool presentation = asLogical(s_presentation);

    ntg_result res = p_ntg_connect(holder->instance, chat_id, params, presentation);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_add_incoming_video(SEXP s_handle, SEXP s_chat_id, SEXP s_user_id, SEXP s_endpoint, SEXP s_ssrc_groups) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    int64_t user_id = sexp_to_int64(s_user_id);
    const char* endpoint = sexp_to_cstring(s_endpoint);

    size_t grp_count = LENGTH(s_ssrc_groups);
    ntg_ssrc_group* grps = (ntg_ssrc_group*)calloc(grp_count > 0 ? grp_count : 1, sizeof(ntg_ssrc_group));
    for (size_t i = 0; i < grp_count; ++i) {
        SEXP item = VECTOR_ELT(s_ssrc_groups, i);
        grps[i].semantics = (char*)sexp_to_cstring(VECTOR_ELT(item, 0));
        SEXP ssrcs_vec = VECTOR_ELT(item, 1);
        grps[i].ssrcs_len = LENGTH(ssrcs_vec);
        grps[i].ssrcs = (uint32_t*)malloc(grps[i].ssrcs_len * sizeof(uint32_t));
        for (size_t j = 0; j < grps[i].ssrcs_len; ++j) {
            grps[i].ssrcs[j] = (uint32_t)INTEGER(ssrcs_vec)[j];
        }
    }

    uint32_t out = 0;
    ntg_result res = p_ntg_add_incoming_video(holder->instance, chat_id, user_id, endpoint, grps, grp_count, &out);
    for (size_t i = 0; i < grp_count; ++i) free(grps[i].ssrcs);
    free(grps);
    check_call_result(res);
    return ScalarInteger((int)out);
}

SEXP r_ntg_remove_incoming_video(SEXP s_handle, SEXP s_chat_id, SEXP s_endpoint) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    const char* endpoint = sexp_to_cstring(s_endpoint);

    bool out = false;
    ntg_result res = p_ntg_remove_incoming_video(holder->instance, chat_id, endpoint, &out);
    check_call_result(res);
    return ScalarLogical(out);
}

SEXP r_ntg_set_stream_sources(SEXP s_handle, SEXP s_chat_id, SEXP s_mode, SEXP s_media) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_stream_mode mode = (ntg_stream_mode)asInteger(s_mode);

    ntg_media_description media;
    memset(&media, 0, sizeof(media));

    ntg_audio_description mic_desc;
    ntg_audio_description spk_desc;
    ntg_video_description cam_desc;
    ntg_video_description scr_desc;

    SEXP s_mic = VECTOR_ELT(s_media, 0);
    if (s_mic != R_NilValue) {
        memset(&mic_desc, 0, sizeof(mic_desc));
        mic_desc.media_source = (ntg_media_source)asInteger(VECTOR_ELT(s_mic, 0));
        mic_desc.sample_rate = (uint32_t)asInteger(VECTOR_ELT(s_mic, 1));
        mic_desc.channel_count = (uint8_t)asInteger(VECTOR_ELT(s_mic, 2));
        mic_desc.input = (char*)sexp_to_cstring(VECTOR_ELT(s_mic, 3));
        mic_desc.keep_open = asLogical(VECTOR_ELT(s_mic, 4));
        media.microphone = &mic_desc;
    }

    SEXP s_spk = VECTOR_ELT(s_media, 1);
    if (s_spk != R_NilValue) {
        memset(&spk_desc, 0, sizeof(spk_desc));
        spk_desc.media_source = (ntg_media_source)asInteger(VECTOR_ELT(s_spk, 0));
        spk_desc.sample_rate = (uint32_t)asInteger(VECTOR_ELT(s_spk, 1));
        spk_desc.channel_count = (uint8_t)asInteger(VECTOR_ELT(s_spk, 2));
        spk_desc.input = (char*)sexp_to_cstring(VECTOR_ELT(s_spk, 3));
        spk_desc.keep_open = asLogical(VECTOR_ELT(s_spk, 4));
        media.speaker = &spk_desc;
    }

    SEXP s_cam = VECTOR_ELT(s_media, 2);
    if (s_cam != R_NilValue) {
        memset(&cam_desc, 0, sizeof(cam_desc));
        cam_desc.media_source = (ntg_media_source)asInteger(VECTOR_ELT(s_cam, 0));
        cam_desc.width = (int16_t)asInteger(VECTOR_ELT(s_cam, 1));
        cam_desc.height = (int16_t)asInteger(VECTOR_ELT(s_cam, 2));
        cam_desc.fps = (uint8_t)asInteger(VECTOR_ELT(s_cam, 3));
        cam_desc.input = (char*)sexp_to_cstring(VECTOR_ELT(s_cam, 4));
        cam_desc.keep_open = asLogical(VECTOR_ELT(s_cam, 5));
        media.camera = &cam_desc;
    }

    SEXP s_scr = VECTOR_ELT(s_media, 3);
    if (s_scr != R_NilValue) {
        memset(&scr_desc, 0, sizeof(scr_desc));
        scr_desc.media_source = (ntg_media_source)asInteger(VECTOR_ELT(s_scr, 0));
        scr_desc.width = (int16_t)asInteger(VECTOR_ELT(s_scr, 1));
        scr_desc.height = (int16_t)asInteger(VECTOR_ELT(s_scr, 2));
        scr_desc.fps = (uint8_t)asInteger(VECTOR_ELT(s_scr, 3));
        scr_desc.input = (char*)sexp_to_cstring(VECTOR_ELT(s_scr, 4));
        scr_desc.keep_open = asLogical(VECTOR_ELT(s_scr, 5));
        media.screen = &scr_desc;
    }

    ntg_result res = p_ntg_set_stream_sources(holder->instance, chat_id, mode, media);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_pause(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    bool out = false;
    ntg_result res = p_ntg_pause(holder->instance, chat_id, &out);
    check_call_result(res);
    return ScalarLogical(out);
}

SEXP r_ntg_resume(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    bool out = false;
    ntg_result res = p_ntg_resume(holder->instance, chat_id, &out);
    check_call_result(res);
    return ScalarLogical(out);
}

SEXP r_ntg_mute(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    bool out = false;
    ntg_result res = p_ntg_mute(holder->instance, chat_id, &out);
    check_call_result(res);
    return ScalarLogical(out);
}

SEXP r_ntg_unmute(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    bool out = false;
    ntg_result res = p_ntg_unmute(holder->instance, chat_id, &out);
    check_call_result(res);
    return ScalarLogical(out);
}

SEXP r_ntg_stop(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_result res = p_ntg_stop(holder->instance, chat_id);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_stop_presentation(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_result res = p_ntg_stop_presentation(holder->instance, chat_id);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_get_emojis_fingerprint(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    char* out = NULL;
    ntg_result res = p_ntg_get_emojis_fingerprint(holder->instance, chat_id, &out);
    check_call_result(res);
    SEXP ret = PROTECT(mkString(out ? out : ""));
    if (out && p_ntg_string_free) p_ntg_string_free(out);
    UNPROTECT(1);
    return ret;
}

SEXP r_ntg_time(SEXP s_handle, SEXP s_chat_id, SEXP s_mode) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_stream_mode mode = (ntg_stream_mode)asInteger(s_mode);
    uint64_t out = 0;
    ntg_result res = p_ntg_time(holder->instance, chat_id, mode, &out);
    check_call_result(res);
    return ScalarReal((double)out);
}

SEXP r_ntg_get_state(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_media_state out;
    memset(&out, 0, sizeof(out));
    ntg_result res = p_ntg_get_state(holder->instance, chat_id, &out);
    check_call_result(res);

    SEXP names = PROTECT(allocVector(STRSXP, 5));
    SET_STRING_ELT(names, 0, mkChar("muted"));
    SET_STRING_ELT(names, 1, mkChar("video_paused"));
    SET_STRING_ELT(names, 2, mkChar("video_stopped"));
    SET_STRING_ELT(names, 3, mkChar("presentation_paused"));
    SET_STRING_ELT(names, 4, mkChar("presentation_stopped"));

    SEXP ret = PROTECT(allocVector(VECSXP, 5));
    SET_VECTOR_ELT(ret, 0, ScalarLogical(out.muted));
    SET_VECTOR_ELT(ret, 1, ScalarLogical(out.video_paused));
    SET_VECTOR_ELT(ret, 2, ScalarLogical(out.video_stopped));
    SET_VECTOR_ELT(ret, 3, ScalarLogical(out.presentation_paused));
    SET_VECTOR_ELT(ret, 4, ScalarLogical(out.presentation_stopped));
    setAttrib(ret, R_NamesSymbol, names);

    UNPROTECT(2);
    return ret;
}

SEXP r_ntg_get_call_type(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_call_type out = NTG_CALL_TYPE_GROUP;
    ntg_result res = p_ntg_get_call_type(holder->instance, chat_id, &out);
    check_call_result(res);
    return ScalarInteger((int)out);
}

SEXP r_ntg_get_connection_mode(SEXP s_handle, SEXP s_chat_id) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_connection_mode out = NTG_CONNECTION_MODE_NONE;
    ntg_result res = p_ntg_get_connection_mode(holder->instance, chat_id, &out);
    check_call_result(res);
    return ScalarInteger((int)out);
}

SEXP r_ntg_calls(SEXP s_handle) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    ntg_call_info_entry* out = NULL;
    size_t out_len = 0;
    ntg_result res = p_ntg_calls(holder->instance, &out, &out_len);
    check_call_result(res);

    SEXP ret = PROTECT(allocVector(VECSXP, out_len));
    SEXP names = PROTECT(allocVector(STRSXP, out_len));

    for (size_t i = 0; i < out_len; ++i) {
        char key_str[64];
        snprintf(key_str, sizeof(key_str), "%lld", (long long)out[i].key);
        SET_STRING_ELT(names, i, mkChar(key_str));

        SEXP c_names = PROTECT(allocVector(STRSXP, 2));
        SET_STRING_ELT(c_names, 0, mkChar("playback"));
        SET_STRING_ELT(c_names, 1, mkChar("capture"));

        SEXP c_val = PROTECT(allocVector(VECSXP, 2));
        SET_VECTOR_ELT(c_val, 0, ScalarInteger(out[i].value.playback));
        SET_VECTOR_ELT(c_val, 1, ScalarInteger(out[i].value.capture));
        setAttrib(c_val, R_NamesSymbol, c_names);

        SET_VECTOR_ELT(ret, i, c_val);
        UNPROTECT(2);
    }
    setAttrib(ret, R_NamesSymbol, names);

    if (out && p_ntg_call_info_entry_free) p_ntg_call_info_entry_free(out, out_len);
    UNPROTECT(2);
    return ret;
}

SEXP r_ntg_send_broadcast_timestamp(SEXP s_handle, SEXP s_chat_id, SEXP s_timestamp) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    int64_t ts = sexp_to_int64(s_timestamp);
    ntg_result res = p_ntg_send_broadcast_timestamp(holder->instance, chat_id, ts);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_send_broadcast_part(SEXP s_handle, SEXP s_chat_id, SEXP s_segment_id, SEXP s_part_id, SEXP s_status, SEXP s_quality_update, SEXP s_data) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    int64_t segment_id = sexp_to_int64(s_segment_id);
    int32_t part_id = asInteger(s_part_id);
    ntg_media_segment_part_status status = (ntg_media_segment_part_status)asInteger(s_status);
    bool quality_update = asLogical(s_quality_update);

    const uint8_t* data_ptr = NULL;
    size_t data_len = 0;
    if (s_data != R_NilValue && TYPEOF(s_data) == RAWSXP) {
        data_ptr = (const uint8_t*)RAW(s_data);
        data_len = LENGTH(s_data);
    }

    ntg_result res = p_ntg_send_broadcast_part(holder->instance, chat_id, segment_id, part_id, status, quality_update, data_ptr, data_len);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_send_signaling_data(SEXP s_handle, SEXP s_chat_id, SEXP s_data) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    const uint8_t* data_ptr = (const uint8_t*)RAW(s_data);
    size_t data_len = LENGTH(s_data);

    ntg_result res = p_ntg_send_signaling_data(holder->instance, chat_id, data_ptr, data_len);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_send_external_frame(SEXP s_handle, SEXP s_chat_id, SEXP s_device, SEXP s_data, SEXP s_frame_data) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    ntg_stream_device dev = (ntg_stream_device)asInteger(s_device);
    const uint8_t* data_ptr = (const uint8_t*)RAW(s_data);
    size_t data_len = LENGTH(s_data);

    ntg_frame_data fd;
    memset(&fd, 0, sizeof(fd));
    fd.absolute_capture_timestamp_ms = sexp_to_int64(VECTOR_ELT(s_frame_data, 0));
    fd.rotation = (ntg_video_rotation)asInteger(VECTOR_ELT(s_frame_data, 1));
    fd.width = (uint16_t)asInteger(VECTOR_ELT(s_frame_data, 2));
    fd.height = (uint16_t)asInteger(VECTOR_ELT(s_frame_data, 3));

    ntg_result res = p_ntg_send_external_frame(holder->instance, chat_id, dev, data_ptr, data_len, fd);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_update_audio_ssrc_mappings(SEXP s_handle, SEXP s_chat_id, SEXP s_mappings) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);

    size_t count = LENGTH(s_mappings);
    ntg_ssrc_mapping* mappings = (ntg_ssrc_mapping*)calloc(count > 0 ? count : 1, sizeof(ntg_ssrc_mapping));
    for (size_t i = 0; i < count; ++i) {
        SEXP item = VECTOR_ELT(s_mappings, i);
        mappings[i].user_id = sexp_to_int64(VECTOR_ELT(item, 0));
        mappings[i].ssrc = asInteger(VECTOR_ELT(item, 1));
    }

    ntg_result res = p_ntg_update_audio_ssrc_mappings(holder->instance, chat_id, mappings, count);
    free(mappings);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_apply_blocks(SEXP s_handle, SEXP s_chat_id, SEXP s_subchain, SEXP s_next_offset, SEXP s_blocks, SEXP s_short_poll) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    int32_t subchain = asInteger(s_subchain);
    int32_t next_offset = asInteger(s_next_offset);
    bool short_poll = asLogical(s_short_poll);

    size_t count = LENGTH(s_blocks);
    ntg_bytes* blocks = (ntg_bytes*)calloc(count > 0 ? count : 1, sizeof(ntg_bytes));
    for (size_t i = 0; i < count; ++i) {
        SEXP raw_item = VECTOR_ELT(s_blocks, i);
        blocks[i].data = (uint8_t*)RAW(raw_item);
        blocks[i].len = LENGTH(raw_item);
    }

    ntg_result res = p_ntg_apply_blocks(holder->instance, chat_id, subchain, next_offset, blocks, count, short_poll);
    free(blocks);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_finish_subchain_request(SEXP s_handle, SEXP s_chat_id, SEXP s_subchain) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int64_t chat_id = sexp_to_int64(s_chat_id);
    int32_t subchain = asInteger(s_subchain);

    ntg_result res = p_ntg_finish_subchain_request(holder->instance, chat_id, subchain);
    check_call_result(res);
    return R_NilValue;
}

SEXP r_ntg_setup_callbacks(SEXP s_handle) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    if (p_ntg_on_upgrade_callback) {
        p_ntg_on_upgrade_callback(holder->instance, cb_trampoline_upgrade, holder);
    }
    if (p_ntg_on_stream_end_callback) {
        p_ntg_on_stream_end_callback(holder->instance, cb_trampoline_stream_end, holder);
    }
    if (p_ntg_on_connection_change_callback) {
        p_ntg_on_connection_change_callback(holder->instance, cb_trampoline_connection_change, holder);
    }
    if (p_ntg_on_signaling_data_callback) {
        p_ntg_on_signaling_data_callback(holder->instance, cb_trampoline_signaling_data, holder);
    }
    if (p_ntg_on_remote_source_change_callback) {
        p_ntg_on_remote_source_change_callback(holder->instance, cb_trampoline_remote_source_change, holder);
    }
    if (p_ntg_on_request_broadcast_part_callback) {
        p_ntg_on_request_broadcast_part_callback(holder->instance, cb_trampoline_request_broadcast_part, holder);
    }
    if (p_ntg_on_request_broadcast_timestamp_callback) {
        p_ntg_on_request_broadcast_timestamp_callback(holder->instance, cb_trampoline_request_broadcast_timestamp, holder);
    }
    if (p_ntg_on_request_participants_callback) {
        p_ntg_on_request_participants_callback(holder->instance, cb_trampoline_request_participants, holder);
    }
    if (p_ntg_on_outbound_block_callback) {
        p_ntg_on_outbound_block_callback(holder->instance, cb_trampoline_outbound_block, holder);
    }
    if (p_ntg_on_subchain_request_callback) {
        p_ntg_on_subchain_request_callback(holder->instance, cb_trampoline_subchain_request, holder);
    }
    if (p_ntg_on_update_emojis_callback) {
        p_ntg_on_update_emojis_callback(holder->instance, cb_trampoline_update_emojis, holder);
    }
    return ScalarLogical(TRUE);
}

SEXP r_ntg_poll_events(SEXP s_handle, SEXP s_max_events) {
    ntg_client_holder* holder = get_client_holder(s_handle);
    int max_count = asInteger(s_max_events);
    if (max_count <= 0) max_count = 1000;

    ntg_mutex_lock(&holder->queue.lock);
    size_t count = holder->queue.count;
    if (count > (size_t)max_count) count = (size_t)max_count;

    ntg_event_node* popped_head = NULL;
    ntg_event_node* popped_tail = NULL;
    size_t actual_popped = 0;

    while (actual_popped < count && holder->queue.head) {
        ntg_event_node* node = holder->queue.head;
        holder->queue.head = node->next;
        if (!holder->queue.head) holder->queue.tail = NULL;
        holder->queue.count--;
        node->next = NULL;

        if (popped_tail) {
            popped_tail->next = node;
            popped_tail = node;
        } else {
            popped_head = node;
            popped_tail = node;
        }
        actual_popped++;
    }
    ntg_mutex_unlock(&holder->queue.lock);

    SEXP ret = PROTECT(allocVector(VECSXP, actual_popped));
    ntg_event_node* curr = popped_head;
    size_t idx = 0;

    while (curr && idx < actual_popped) {
        SEXP item = R_NilValue;
        SEXP item_names = R_NilValue;

        switch (curr->type) {
            case NTG_EVT_UPGRADE: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("state"));

                SEXP st_names = PROTECT(allocVector(STRSXP, 5));
                SET_STRING_ELT(st_names, 0, mkChar("muted"));
                SET_STRING_ELT(st_names, 1, mkChar("video_paused"));
                SET_STRING_ELT(st_names, 2, mkChar("video_stopped"));
                SET_STRING_ELT(st_names, 3, mkChar("presentation_paused"));
                SET_STRING_ELT(st_names, 4, mkChar("presentation_stopped"));

                SEXP st_val = PROTECT(allocVector(VECSXP, 5));
                SET_VECTOR_ELT(st_val, 0, ScalarLogical(curr->data.upgrade_state.muted));
                SET_VECTOR_ELT(st_val, 1, ScalarLogical(curr->data.upgrade_state.video_paused));
                SET_VECTOR_ELT(st_val, 2, ScalarLogical(curr->data.upgrade_state.video_stopped));
                SET_VECTOR_ELT(st_val, 3, ScalarLogical(curr->data.upgrade_state.presentation_paused));
                SET_VECTOR_ELT(st_val, 4, ScalarLogical(curr->data.upgrade_state.presentation_stopped));
                setAttrib(st_val, R_NamesSymbol, st_names);

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("upgrade"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, st_val);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(4);
                break;
            }
            case NTG_EVT_STREAM_END: {
                item_names = PROTECT(allocVector(STRSXP, 4));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("type"));
                SET_STRING_ELT(item_names, 3, mkChar("device"));

                item = PROTECT(allocVector(VECSXP, 4));
                SET_VECTOR_ELT(item, 0, mkString("stream_end"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, ScalarInteger((int)curr->data.stream_end.type));
                SET_VECTOR_ELT(item, 3, ScalarInteger((int)curr->data.stream_end.device));
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(2);
                break;
            }
            case NTG_EVT_CONNECTION_CHANGE: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("state"));

                SEXP ci_names = PROTECT(allocVector(STRSXP, 2));
                SET_STRING_ELT(ci_names, 0, mkChar("state"));
                SET_STRING_ELT(ci_names, 1, mkChar("kind"));

                SEXP ci_val = PROTECT(allocVector(VECSXP, 2));
                SET_VECTOR_ELT(ci_val, 0, ScalarInteger((int)curr->data.connection_info.state));
                SET_VECTOR_ELT(ci_val, 1, ScalarInteger((int)curr->data.connection_info.kind));
                setAttrib(ci_val, R_NamesSymbol, ci_names);

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("connection_change"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, ci_val);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(4);
                break;
            }
            case NTG_EVT_SIGNALING_DATA: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("data"));

                SEXP raw_vec = PROTECT(allocVector(RAWSXP, curr->data.raw_data.data_len));
                if (curr->data.raw_data.data && curr->data.raw_data.data_len > 0) {
                    memcpy(RAW(raw_vec), curr->data.raw_data.data, curr->data.raw_data.data_len);
                }

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("signaling_data"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, raw_vec);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(3);
                break;
            }
            case NTG_EVT_REMOTE_SOURCE_CHANGE: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("remote_source"));

                SEXP rs_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(rs_names, 0, mkChar("ssrc"));
                SET_STRING_ELT(rs_names, 1, mkChar("state"));
                SET_STRING_ELT(rs_names, 2, mkChar("device"));

                SEXP rs_val = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(rs_val, 0, ScalarInteger((int)curr->data.remote_source.ssrc));
                SET_VECTOR_ELT(rs_val, 1, ScalarInteger((int)curr->data.remote_source.state));
                SET_VECTOR_ELT(rs_val, 2, ScalarInteger((int)curr->data.remote_source.device));
                setAttrib(rs_val, R_NamesSymbol, rs_names);

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("remote_source_change"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, rs_val);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(4);
                break;
            }
            case NTG_EVT_REQUEST_BROADCAST_PART: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("request"));

                SEXP r_names = PROTECT(allocVector(STRSXP, 7));
                SET_STRING_ELT(r_names, 0, mkChar("segment_id"));
                SET_STRING_ELT(r_names, 1, mkChar("part_id"));
                SET_STRING_ELT(r_names, 2, mkChar("limit"));
                SET_STRING_ELT(r_names, 3, mkChar("timestamp"));
                SET_STRING_ELT(r_names, 4, mkChar("quality_update"));
                SET_STRING_ELT(r_names, 5, mkChar("channel_id"));
                SET_STRING_ELT(r_names, 6, mkChar("quality"));

                SEXP r_val = PROTECT(allocVector(VECSXP, 7));
                SET_VECTOR_ELT(r_val, 0, ScalarReal((double)curr->data.broadcast_part_request.segment_id));
                SET_VECTOR_ELT(r_val, 1, ScalarInteger(curr->data.broadcast_part_request.part_id));
                SET_VECTOR_ELT(r_val, 2, ScalarInteger(curr->data.broadcast_part_request.limit));
                SET_VECTOR_ELT(r_val, 3, ScalarReal((double)curr->data.broadcast_part_request.timestamp));
                SET_VECTOR_ELT(r_val, 4, ScalarLogical(curr->data.broadcast_part_request.quality_update));
                SET_VECTOR_ELT(r_val, 5, ScalarInteger(curr->data.broadcast_part_request.channel_id));
                SET_VECTOR_ELT(r_val, 6, ScalarInteger(curr->data.broadcast_part_request.quality));
                setAttrib(r_val, R_NamesSymbol, r_names);

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("request_broadcast_part"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, r_val);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(4);
                break;
            }
            case NTG_EVT_REQUEST_BROADCAST_TIMESTAMP: {
                item_names = PROTECT(allocVector(STRSXP, 2));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));

                item = PROTECT(allocVector(VECSXP, 2));
                SET_VECTOR_ELT(item, 0, mkString("request_broadcast_timestamp"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(2);
                break;
            }
            case NTG_EVT_REQUEST_PARTICIPANTS: {
                item_names = PROTECT(allocVector(STRSXP, 2));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));

                item = PROTECT(allocVector(VECSXP, 2));
                SET_VECTOR_ELT(item, 0, mkString("request_participants"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(2);
                break;
            }
            case NTG_EVT_OUTBOUND_BLOCK: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("block"));

                SEXP raw_vec = PROTECT(allocVector(RAWSXP, curr->data.raw_data.data_len));
                if (curr->data.raw_data.data && curr->data.raw_data.data_len > 0) {
                    memcpy(RAW(raw_vec), curr->data.raw_data.data, curr->data.raw_data.data_len);
                }

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("outbound_block"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, raw_vec);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(3);
                break;
            }
            case NTG_EVT_SUBCHAIN_REQUEST: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("subchain_request"));

                SEXP req_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(req_names, 0, mkChar("subchain"));
                SET_STRING_ELT(req_names, 1, mkChar("height"));
                SET_STRING_ELT(req_names, 2, mkChar("limit"));

                SEXP req_val = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(req_val, 0, ScalarInteger(curr->data.subchain_request.subchain));
                SET_VECTOR_ELT(req_val, 1, ScalarInteger(curr->data.subchain_request.height));
                SET_VECTOR_ELT(req_val, 2, ScalarInteger(curr->data.subchain_request.limit));
                setAttrib(req_val, R_NamesSymbol, req_names);

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("subchain_request"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, req_val);
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(4);
                break;
            }
            case NTG_EVT_UPDATE_EMOJIS: {
                item_names = PROTECT(allocVector(STRSXP, 3));
                SET_STRING_ELT(item_names, 0, mkChar("event"));
                SET_STRING_ELT(item_names, 1, mkChar("chat_id"));
                SET_STRING_ELT(item_names, 2, mkChar("emojis"));

                item = PROTECT(allocVector(VECSXP, 3));
                SET_VECTOR_ELT(item, 0, mkString("update_emojis"));
                SET_VECTOR_ELT(item, 1, ScalarReal((double)curr->chat_id));
                SET_VECTOR_ELT(item, 2, mkString(curr->data.emojis ? curr->data.emojis : ""));
                setAttrib(item, R_NamesSymbol, item_names);
                UNPROTECT(2);
                break;
            }
            default:
                break;
        }


        if (item != R_NilValue) {
            SET_VECTOR_ELT(ret, idx, item);
        }
        ntg_event_node* next = curr->next;
        free_event_node(curr);
        curr = next;
        idx++;
    }

    UNPROTECT(1);
    return ret;
}
