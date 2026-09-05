#include "ntgcalls_r.h"
#include <R_ext/Rdynload.h>
#include <R_ext/Visibility.h>

static const R_CallMethodDef CallEntries[] = {
    {"r_ntg_instance_create", (DL_FUNC)&r_ntg_instance_create, 0},
    {"r_ntg_instance_destroy", (DL_FUNC)&r_ntg_instance_destroy, 1},
    {"r_ntg_get_version", (DL_FUNC)&r_ntg_get_version, 0},
    {"r_ntg_last_error", (DL_FUNC)&r_ntg_last_error, 0},
    {"r_ntg_ping", (DL_FUNC)&r_ntg_ping, 0},
    {"r_ntg_cpu_usage", (DL_FUNC)&r_ntg_cpu_usage, 1},
    {"r_ntg_enable_glib_loop", (DL_FUNC)&r_ntg_enable_glib_loop, 1},
    {"r_ntg_get_protocol", (DL_FUNC)&r_ntg_get_protocol, 0},
    {"r_ntg_get_media_devices", (DL_FUNC)&r_ntg_get_media_devices, 0},

    {"r_ntg_create_p2p_call", (DL_FUNC)&r_ntg_create_p2p_call, 2},
    {"r_ntg_init_exchange", (DL_FUNC)&r_ntg_init_exchange, 4},
    {"r_ntg_exchange_keys", (DL_FUNC)&r_ntg_exchange_keys, 4},
    {"r_ntg_skip_exchange", (DL_FUNC)&r_ntg_skip_exchange, 4},
    {"r_ntg_connect_p2p", (DL_FUNC)&r_ntg_connect_p2p, 6},

    {"r_ntg_create_call", (DL_FUNC)&r_ntg_create_call, 2},
    {"r_ntg_init_presentation", (DL_FUNC)&r_ntg_init_presentation, 2},
    {"r_ntg_init_conference", (DL_FUNC)&r_ntg_init_conference, 4},
    {"r_ntg_connect", (DL_FUNC)&r_ntg_connect, 4},

    {"r_ntg_add_incoming_video", (DL_FUNC)&r_ntg_add_incoming_video, 5},
    {"r_ntg_remove_incoming_video", (DL_FUNC)&r_ntg_remove_incoming_video, 3},
    {"r_ntg_set_stream_sources", (DL_FUNC)&r_ntg_set_stream_sources, 4},
    {"r_ntg_pause", (DL_FUNC)&r_ntg_pause, 2},
    {"r_ntg_resume", (DL_FUNC)&r_ntg_resume, 2},
    {"r_ntg_mute", (DL_FUNC)&r_ntg_mute, 2},
    {"r_ntg_unmute", (DL_FUNC)&r_ntg_unmute, 2},
    {"r_ntg_stop", (DL_FUNC)&r_ntg_stop, 2},
    {"r_ntg_stop_presentation", (DL_FUNC)&r_ntg_stop_presentation, 2},
    {"r_ntg_get_emojis_fingerprint", (DL_FUNC)&r_ntg_get_emojis_fingerprint, 2},
    {"r_ntg_time", (DL_FUNC)&r_ntg_time, 3},
    {"r_ntg_get_state", (DL_FUNC)&r_ntg_get_state, 2},
    {"r_ntg_get_call_type", (DL_FUNC)&r_ntg_get_call_type, 2},
    {"r_ntg_get_connection_mode", (DL_FUNC)&r_ntg_get_connection_mode, 2},
    {"r_ntg_calls", (DL_FUNC)&r_ntg_calls, 1},

    {"r_ntg_send_broadcast_timestamp", (DL_FUNC)&r_ntg_send_broadcast_timestamp, 3},
    {"r_ntg_send_broadcast_part", (DL_FUNC)&r_ntg_send_broadcast_part, 7},
    {"r_ntg_send_signaling_data", (DL_FUNC)&r_ntg_send_signaling_data, 3},
    {"r_ntg_send_external_frame", (DL_FUNC)&r_ntg_send_external_frame, 5},
    {"r_ntg_update_audio_ssrc_mappings", (DL_FUNC)&r_ntg_update_audio_ssrc_mappings, 3},
    {"r_ntg_apply_blocks", (DL_FUNC)&r_ntg_apply_blocks, 6},
    {"r_ntg_finish_subchain_request", (DL_FUNC)&r_ntg_finish_subchain_request, 3},

    {"r_ntg_setup_callbacks", (DL_FUNC)&r_ntg_setup_callbacks, 1},
    {"r_ntg_poll_events", (DL_FUNC)&r_ntg_poll_events, 2},
    {NULL, NULL, 0}
};

attribute_visible void R_init_ntgcalls(DllInfo* dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    R_forceSymbols(dll, TRUE);
}
