import asyncio
import os
import sys

try:
    loop = asyncio.get_event_loop()
except RuntimeError:
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

from pyrogram import Client

async def generate_session():
    print("="*60)
    print("      Telegram Pyrogram String Session Generator            ")
    print("="*60 + "\n")

    print("Get your API_ID and API_HASH from https://my.telegram.org\n")

    api_id_input = input("Enter your API_ID: ").strip()
    api_hash = input("Enter your API_HASH: ").strip()

    if not api_id_input or not api_hash:
        print("\n[Error] API_ID and API_HASH cannot be empty.")
        return

    try:
        api_id = int(api_id_input)
    except ValueError:
        print("\n[Error] API_ID must be an integer.")
        return

    print("\n[1/3] Connecting to Telegram...")

    async with Client(
        name="session_generator",
        api_id=api_id,
        api_hash=api_hash,
        in_memory=True
    ) as app:
        me = await app.get_me()
        session_str = await app.export_session_string()

        print("\n" + "="*60)
        print(f"  Logged in successfully as: @{me.username or me.first_name} (ID: {me.id})")
        print("="*60)
        print("\nYOUR STRING_SESSION:\n")
        print(session_str)
        print("\n" + "="*60)

        try:
            await app.send_message(
                "me",
                f"**Here is your Pyrogram String Session:**\n\n`{session_str}`\n\n⚠️ *Keep this safe and do not share it with anyone!*"
            )
            print("[Safe Backup] Your String Session was also sent to your Telegram 'Saved Messages'.\n")
        except Exception:
            pass

if __name__ == "__main__":
    asyncio.run(generate_session())
