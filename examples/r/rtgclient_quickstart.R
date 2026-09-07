library(ntgcalls)
library(rtgclient)

mock_mtproto <- MockMTProtoAdapter$new()
client <- rtg_client(mtproto_adapter = mock_mtproto)

client$on_stream_end(function(chat_id, type, device) {
  cat(sprintf("[Stream End] Chat ID: %s, Device: %s\n", chat_id, device))
})

client$on_connection_change(function(chat_id, state) {
  cat(sprintf("[Connection State Change] Chat ID: %s\n", chat_id))
})

client$start()

chat_id <- -1004485855305
audio_stream <- AudioStream("test_audio.raw", sample_rate = 48000L, channel_count = 2L)

cat(sprintf("[RTgClient] Joining group call in %s...\n", chat_id))
client$play(chat_id, audio_stream)

cat(sprintf("[RTgClient] Call status: %s\n", client$get_status(chat_id)))

client$pause(chat_id)
cat(sprintf("[RTgClient] Call status after pause: %s\n", client$get_status(chat_id)))

client$resume(chat_id)
cat(sprintf("[RTgClient] Call status after resume: %s\n", client$get_status(chat_id)))

client$change_volume(chat_id, participant_id = 12345678L, volume = 80L)

client$leave_call(chat_id)
cat(sprintf("[RTgClient] Left group call. Final status: %s\n", client$get_status(chat_id)))

client$stop()

