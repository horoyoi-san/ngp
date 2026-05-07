import requests
import json
import yaml
import os
import hashlib
from datetime import datetime, timezone

# ================= Webhook =================
webhook_urls = [
    os.environ.get("WEBHOOK"),
    os.environ.get("WEBHOOK1"),
    os.environ.get("WEBHOOK2"),
]

# ================= APIs =================
ANANTA_API = "https://l50.update.netease.com/Ananta_Official_zhCN.yml"

# ================= Utils =================
def fetch_yaml(url):
    try:
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        return yaml.safe_load(resp.text)
    except Exception as e:
        print(f"❌ YAML fetch error: {url} -> {e}")
        return None


def fetch_json(url):
    try:
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        print(f"❌ JSON fetch error: {url} -> {e}")
        return None


# ================= Logging =================
def log_and_check(api_url, name):
    try:
        resp = requests.get(api_url, timeout=10)
        resp.raise_for_status()

        text = resp.text

        # รองรับทั้ง JSON และ YAML
        try:
            data = json.loads(text)
        except:
            data = yaml.safe_load(text)

    except Exception as e:
        print(f"❌ Error fetching {name}: {e}")
        return False, None

    current_hash = hashlib.md5(text.encode("utf-8")).hexdigest()

    log_dir = os.path.join(os.getcwd(), "ngp", "log", name)
    os.makedirs(log_dir, exist_ok=True)

    hash_file = os.path.join(log_dir, "last_hash.txt")
    raw_file = os.path.join(log_dir, "raw_log.jsonl")

    # write log
    with open(raw_file, "a", encoding="utf-8") as f:
        f.write(json.dumps({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "data": data
        }, ensure_ascii=False, default=str) + "\n")

    last_hash = ""

    if os.path.exists(hash_file):
        with open(hash_file, "r", encoding="utf-8") as f:
            last_hash = f.read().strip()

    if current_hash != last_hash:
        with open(hash_file, "w", encoding="utf-8") as f:
            f.write(current_hash)

        return True, data

    return False, data


# ================= Embed =================
def split_text_to_embeds(
    title,
    text,
    color=16776960,
    max_len=1024,
    image_url=None
):
    if not text:
        return []

    embeds = []

    lines = text.split("\n")
    current = ""
    part = 1

    for line in lines:
        if len(current) + len(line) + 1 > max_len:
            embeds.append({
                "title": f"{title} {part}",
                "description": current,
                "color": color,
                "image": {"url": image_url} if image_url else {}
            })

            current = line
            part += 1

        else:
            current += ("\n" if current else "") + line

    if current:
        embeds.append({
            "title": f"{title} {part}",
            "description": current,
            "color": color,
            "image": {"url": image_url} if image_url else {}
        })

    return embeds


# ================= Convert =================
def convert_ananta():
    data = fetch_yaml(ANANTA_API)

    if not data:
        return None

    files = data.get("files", [])

    first_file = files[0] if files else {}

    return {
        "default": {
            "resource": {
                "version": data.get("version", "Unknown"),
                "size": first_file.get("size", 0),
                "md5": data.get("sha512", ""),
                "path": first_file.get("url", ""),
                "releaseDate": data.get("releaseDate", ""),
                "forceUpdate": data.get("forceUpdate", False)
            },
            "cdnList": [{"url": ""}]
        }
    }


# ================= Discord =================
def send_webhook(
    data,
    title,
    webhook_url,
    image_url=None
):
    if not webhook_url:
        return

    blocks = []

    default = data.get("default", {})
    resource = default.get("resource", {})

    version = resource.get("version", "Unknown")
    size = resource.get("size", 0)
    sha512 = resource.get("md5", "")
    path = resource.get("path", "")
    release_date = resource.get("releaseDate", "")
    force_update = resource.get("forceUpdate", False)

    size_mb = round(size / 1024 / 1024, 2)

    desc = (
        f"**Version:** {version}\n"
        f"**Size:** {size_mb} MB\n"
        f"**Force Update:** {force_update}\n"
        f"**Release Date:** {release_date}\n"
        f"**SHA512:** `{sha512}`\n"
        f"**Download:** {path}"
    )

    blocks += split_text_to_embeds(
        title + " — Launcher",
        desc,
        image_url=image_url
    )

    # send embeds
    for i, embed in enumerate(blocks, 1):
        try:
            r = requests.post(
                webhook_url,
                json={"embeds": [embed]},
                timeout=10
            )

            if r.status_code in [200, 204]:
                print(f"✅ Sent {title} embed {i}")

            else:
                print(f"❌ Discord Error {r.status_code}")
                print(r.text)

        except Exception as e:
            print("❌ Webhook error:", e)


# ================= Main =================
def check_for_updates():
    changed, _ = log_and_check(
        ANANTA_API,
        "Ananta Launcher"
    )

    if changed:
        print("🆕 Update detected!")

        data = convert_ananta()

        if data:
            for url in webhook_urls:
                send_webhook(
                    data,
                    "Ananta",
                    url
                )

    else:
        print("✅ No change")


# ================= Start =================
if __name__ == "__main__":
    check_for_updates()