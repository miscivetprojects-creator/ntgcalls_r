import asyncio
import os
import sys
import json
import logging

try:
    loop = asyncio.get_event_loop()
except RuntimeError:
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

import yt_dlp
from pyrogram import Client, raw
from pyrogram.errors import FloodWait
import ntgcalls

logging.basicConfig(level=logging.INFO, format="[%(asctime)s] %(levelname)s: %(message)s")
logger = logging.getLogger("StreamPlayer")

DEFAULT_YOUTUBE_URL = "https://youtu.be/Bc1A16p_Fk0?si=0rlo6_DNG-uZZATn"
DEFAULT_CHAT_ID = -1004485855305

def extract_youtube_stream(url: str):
    logger.info(f"Extracting video & audio streams from YouTube: {url}")
    ydl_opts = {
        "format": "bestvideo[height<=720]+bestaudio/best[height<=720]/best",
        "quiet": True,
        "no_warnings": True,
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)
        title = info.get("title", "YouTube Stream")
        duration = info.get("duration", 0)

        video_url = None
        audio_url = None

        if "requested_formats" in info and len(info["requested_formats"]) >= 2:
            video_url = info["requested_formats"][0]["url"]
            audio_url = info["requested_formats"][1]["url"]
        else:
            video_url = info.get("url")
            audio_url = info.get("url")

        return {
            "title": title,
            "duration": duration,
            "video_url": video_url,
            "audio_url": audio_url,
            "webpage_url": info.get("webpage_url", url)
        }

async def start_player():
    api_id = os.getenv("API_ID")
    api_hash = os.getenv("API_HASH")
    session_string = os.getenv("STRING_SESSION")
    chat_id = int(os.getenv("TG_CHAT_ID", str(DEFAULT_CHAT_ID)))
    play_url = os.getenv("PLAY_URL", DEFAULT_YOUTUBE_URL)

    print("=======================================================")
    print("      NTgCalls + Pyrogram Live Video/Audio Player     ")
    print("======================================================\n")

    if not api_id or not api_hash or not session_string:
        print("[Notice] Missing Telegram session credentials in environment variables.")
        print("Please provide the following:")
        if not api_id:
            api_id = input("Enter API_ID: ").strip()
        if not api_hash:
            api_hash = input("Enter API_HASH: ").strip()
        if not session_string:
            session_string = input("Enter STRING_SESSION: ").strip()

    api_id = int(api_id)

    app = Client(
        name="ntgcalls_session",
        api_id=api_id,
        api_hash=api_hash,
        session_string=session_string,
        in_memory=True
    )

    ntg = ntgcalls.NTgCalls()
    logger.info(f"NTgCalls WebRTC engine initialized (version {ntgcalls.__version__})")

    stream_info = extract_youtube_stream(play_url)
    logger.info(f"Loaded Track: '{stream_info['title']}' (Duration: {stream_info['duration']}s)")

    await app.start()
    me = await app.get_me()
    logger.info(f"Logged in as Telegram User: @{me.username or me.first_name} (ID: {me.id})")

    try:
        peer = await app.resolve_peer(chat_id)
        chat = await app.get_chat(chat_id)
        logger.info(f"Target Telegram Group: {chat.title} (ID: {chat_id})")

        input_group_call = getattr(chat, "call", None)
        if not input_group_call:
            full_chat = await app.invoke(raw.functions.channels.GetFullChannel(channel=peer))
            input_group_call = getattr(full_chat.full_chat, "call", None)

        if not input_group_call:
            logger.info("No active voice chat found. Creating group call...")
            await app.invoke(raw.functions.phone.CreateGroupCall(
                peer=peer,
                random_id=int(os.urandom(4).hex(), 16) % 100000000
            ))
            full_chat = await app.invoke(raw.functions.channels.GetFullChannel(channel=peer))
            input_group_call = full_chat.full_chat.call

        logger.info(f"Group call identified: {input_group_call}")

        logger.info("Generating WebRTC join payload...")
        join_payload = ntg.create_call(chat_id)

        logger.info("Joining Telegram group voice chat via MTProto...")
        result = await app.invoke(raw.functions.phone.JoinGroupCall(
            call=input_group_call,
            join_as=raw.types.InputPeerSelf(),
            params=raw.types.DataJSON(data=join_payload),
            muted=False,
            video_stopped=False
        ))

        signaling_data = None
        for update in result.updates:
            if isinstance(update, raw.types.UpdateGroupCallConnection):
                signaling_data = update.params.data
                break2

        if not signaling_data:
            logger.error("Could not find UpdateGroupCallConnection in join result!")
            return

        logger.info("Connecting NTgCalls WebRTC transport to Telegram server...")
        ntg.connect(chat_id, signaling_data)


        logger.info("Configuring live Video + Audio media stream...")
        audio_desc = ntgcalls.AudioDescription(
            ntgcalls.MediaSource.FFMPEG,
            48000,
            2,
            stream_info["audio_url"],
            False
        )
        video_desc = ntgcalls.VideoDescription(
            ntgcalls.MediaSource.FFMPEG,
            1280,
            720,
            30,
            stream_info["video_url"],
            False
        )
        media_desc = ntgcalls.MediaDescription(audio_desc, None, video_desc, None)

        ntg.set_stream_sources(
            chat_id,
            ntgcalls.StreamMode.AUDIO | ntgcalls.StreamMode.VIDEO,
            media_desc
        )

        announcement = (
            f"□️ **Now Streaming in Voice Chat!**\n\n"
            f"🎵 **Title:** [{stream_info['title']}]({stream_info['webpage_url']})\n"
            f"⏱ **Duration:** {stream_info['duration'] // 60}:{stream_info['duration'] % 60:02d} min\n"
            f"🎞 **Stream Mode:** Video (720p 30fps) + Audio (48kHz Stereo)\n"
            f"⚡️ **Powered by:** NTgCalls WebRTC Core"
        )
        await app.send_message(chat_id, announcement, disable_web_page_preview=False)
        logger.info("Notification message sent to group chat successfully!")


        print("\n" + "="*55)
        print("   LIVE STREAMING ACTIVE IN TELEGRAM VOICE CHAT!     ")
        print("   Press Ctrl+C to stop the stream and leave.        ")
        print("="*55 + "\n")


        while True:
            await asyncio.sleep(1)

    except KeyboardInterrupt:
        logger.info("Stopping stream upon user request...")
    except Exception as e:
        logger.error(f"Streaming error: {e}", exc_info=True)
    finally:
        try:
            ntg.stop(chat_id)
        except Exception:
            pass
        await app.stop()
        logger.info("Session closed cleanly.")

if __name__ == "__main__":
    asyncio.run(start_player())
