import discord
import asyncio
import time

import requests
import json
import yaml
import os
import hashlib

from datetime import datetime, timezone

# =========================================================
# Discord
# =========================================================

TOKEN = os.environ.get("DISCORD_TOKEN")

intents = discord.Intents.default()

bot = discord.Client(
    intents=intents
)

# =========================================================
# Branding
# =========================================================

BOT_NAME = "Ananta"

BOT_ICON = (
    "https://github.com/horoyoi-san/ngp/"
    "blob/webhook/assets/ananta4k.png?raw=true"
)

# =========================================================
# Channels
# =========================================================

CHANNELS = [
    1292097230924283965, # TEST
    1291728736739131402, # 1
    1267379122338791435, # 2
]

# =========================================================
# APIs
# =========================================================

ANANTA_API = (
    "https://???????????????.com/"
    "??????????????????????.yml"
)

ANANTA_IMAGE = (
    "https://www.anantagame.com/pc/gw/"
    "20250904162009/assets/kv-full_f7467c2a.jpg"
)

ANANTA_THUMBNAIL = (
    "https://github.com/horoyoi-san/ngp/"
    "blob/webhook/assets/ananta4k.png?raw=true"
)

# =========================================================
# Fetch YAML
# =========================================================

def fetch_yaml(url):

    try:

        resp = requests.get(
            url,
            timeout=10
        )

        resp.raise_for_status()

        return yaml.safe_load(
            resp.text
        )

    except Exception as e:

        print(
            f"❌ YAML fetch error: {url}"
        )

        print(e)

        return None

# =========================================================
# Logging
# =========================================================

def log_and_check(
    api_url,
    name
):

    try:

        resp = requests.get(
            api_url,
            timeout=10
        )

        resp.raise_for_status()

        text = resp.text

        try:

            data = json.loads(text)

        except:

            data = yaml.safe_load(text)

    except Exception as e:

        print(
            f"❌ Error fetching {name}"
        )

        print(e)

        return False, None

    # =====================================================
    # Hash
    # =====================================================

    current_hash = hashlib.md5(
        text.encode("utf-8")
    ).hexdigest()

    # =====================================================
    # Log Path
    # =====================================================

    log_dir = os.path.join(
        os.getcwd(),
        "Ananta",
        "ngp",
        "log",
        name
    )

    os.makedirs(
        log_dir,
        exist_ok=True
    )

    hash_file = os.path.join(
        log_dir,
        "last_hash.txt"
    )

    raw_file = os.path.join(
        log_dir,
        "raw_log.jsonl"
    )

    # =====================================================
    # Write Raw Log
    # =====================================================

    try:

        with open(
            raw_file,
            "a",
            encoding="utf-8"
        ) as f:

            f.write(json.dumps({

                "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

                "data":
                data

            }, ensure_ascii=False, default=str) + "\n")

        print(
            f"✅ Wrote raw log: {raw_file}"
        )

    except Exception as e:

        print(
            "❌ Log write error"
        )

        print(e)

    # =====================================================
    # Last Hash
    # =====================================================

    last_hash = ""

    if os.path.exists(hash_file):

        with open(
            hash_file,
            "r",
            encoding="utf-8"
        ) as f:

            last_hash = f.read().strip()

    # =====================================================
    # Changed
    # =====================================================

    if current_hash != last_hash:

        with open(
            hash_file,
            "w",
            encoding="utf-8"
        ) as f:

            f.write(current_hash)

        return True, data

    return False, data

# =========================================================
# Convert
# =========================================================

def convert_ananta():

    data = fetch_yaml(
        ANANTA_API
    )

    if not data:
        return None

    files = data.get(
        "files",
        []
    )

    first_file = (
        files[0]
        if files else {}
    )

    return {
        "default": {
            "resource": {

                "version":
                data.get(
                    "version",
                    "Unknown"
                ),

                "size":
                first_file.get(
                    "size",
                    0
                ),

                "md5":
                data.get(
                    "sha512",
                    ""
                ),

                "path":
                first_file.get(
                    "url",
                    ""
                ),

                "releaseDate":
                data.get(
                    "releaseDate",
                    ""
                ),

                "forceUpdate":
                data.get(
                    "forceUpdate",
                    False
                )
            }
        }
    }

# =========================================================
# Discord Send
# =========================================================

async def send_embed_message(
    channel_id,
    data,
    title,
    image_url=None
):

    try:

        channel = await bot.fetch_channel(
            channel_id
        )

    except Exception as e:

        print(
            f"❌ Channel fetch error: {channel_id}"
        )

        print(e)

        return

    default = data.get(
        "default",
        {}
    )

    resource = default.get(
        "resource",
        {}
    )

    version = resource.get(
        "version",
        "Unknown"
    )

    size = resource.get(
        "size",
        0
    )

    sha512 = resource.get(
        "md5",
        ""
    )

    path = resource.get(
        "path",
        ""
    )

    release_date = resource.get(
        "releaseDate",
        ""
    )

    force_update = resource.get(
        "forceUpdate",
        False
    )

    size_mb = round(
        size / 1024 / 1024,
        2
    )

    embed = discord.Embed(
        title=f"{title} Launcher Update Detected",
        description=(
            "A new launcher build has been detected "
            "from NetEase CDN."
        ),
        color=0xFF4500,
        timestamp=datetime.now(
            timezone.utc
        )
    )

    embed.add_field(
        name="Version",
        value=f"`{version}`",
        inline=True
    )

    embed.add_field(
        name="Size",
        value=f"`{size_mb} MB`",
        inline=True
    )

    embed.add_field(
        name="SHA512",
        value=f"`{sha512[:40]}...`",
        inline=False
    )

    embed.add_field(
        name="Release Date",
        value=f"`{release_date}`",
        inline=False
    )

    embed.add_field(
        name="Force Update",
        value=f"`{force_update}`",
        inline=True
    )

    embed.add_field(
        name="Download",
        value=path,
        inline=False
    )

    embed.set_thumbnail(
        url=ANANTA_THUMBNAIL
    )

    embed.set_image(
        url=image_url or ANANTA_IMAGE
    )

    embed.set_footer(
        text="NGP Monitor • Ananta Beta Tracker",
        icon_url=ANANTA_THUMBNAIL
    )

    try:

        await channel.send(
            embed=embed
        )

        print(
            f"✅ Sent -> {channel_id}"
        )

        await asyncio.sleep(1)

    except Exception as e:

        print(
            f"❌ Send error -> {channel_id}"
        )

        print(e)

# =========================================================
# Main
# =========================================================

async def main():

    await bot.login(TOKEN)

    print(
        f"✅ Logged in as {bot.user}"
    )

    changed, _ = log_and_check(
        ANANTA_API,
        "Ananta Launcher"
    )

    if changed:

        print(
            "🆕 Update detected!"
        )

        data = convert_ananta()

        if data:

            for channel_id in CHANNELS:

                await send_embed_message(
                    channel_id,
                    data,
                    "Ananta",
                    ANANTA_IMAGE
                )

    else:

        print(
            "✅ No change"
        )

# =========================================================
# Start
# =========================================================

async def runner():

    task = asyncio.create_task(
        bot.start(TOKEN)
    )

    await asyncio.sleep(5)

    await main()

    await asyncio.sleep(60)

    await bot.close()

    await task

asyncio.run(runner())