import requests
import os
import yaml
from datetime import datetime

launcher = {
    "cn": {
        "beta": "https://l50.update.netease.com/Ananta_Official_zhCN.yml",
        "live": ""
    },
    "os": {
        "beta": "",
        "live": ""
    }
}

game = {
    "cn": {
        "beta": "https://l50.update.netease.com/version_win_netease_player_online.json",
        "live": ""
    },
    "os": {
        "beta": "",
        "live": ""
    }
}


# =========================
# LOG SYSTEM
# =========================

def write_log(message):
    os.makedirs("ananta beta/main/ngp/log", exist_ok=True)

    log_file = datetime.now().strftime("ananta beta/main/ngp/log/%Y-%m-%d.txt")
    time_now = datetime.now().strftime("%H:%M:%S")

    full_message = f"[{time_now}] {message}"

    with open(log_file, "a", encoding="utf-8") as f:
        f.write(full_message + "\n")

    print(full_message)


# =========================
# GET CONFIG VERSION
# =========================

def get_config_version(url):
    if not url:
        return None, None, None

    try:
        write_log(f"Fetching URL: {url}")

        response = requests.get(url, timeout=30)

        if response.status_code != 200:
            write_log(f"Failed request ({response.status_code}) -> {url}")
            return None, None, None

        data = yaml.safe_load(response.text)

        version = data.get("version")

        if not version:
            version = data.get("pc", {}).get("pkg", {}).get("showVersion")

        write_log(f"Detected version: {version}")

        return version, response.content, data

    except Exception as e:
        write_log(f"Error parsing {url}: {e}")
        return None, None, None


# =========================
# SAVE FILE
# =========================

def save_file(directory, filename, content):
    try:
        os.makedirs(directory, exist_ok=True)

        path = os.path.join(directory, filename)

        with open(path, "wb") as f:
            f.write(content)

        write_log(f"Saved file -> {path}")

    except Exception as e:
        write_log(f"Error saving file {filename}: {e}")


# =========================
# PROCESS URLS
# =========================

def process_urls(url_dict, base_dir):
    for region, types in url_dict.items():

        for type_, url in types.items():

            if not url:
                write_log(f"Skipped empty URL ({region}/{type_})")
                continue

            write_log(f"Processing {region}/{type_}")

            version, content, data = get_config_version(url)

            if version:

                filename = url.split("/")[-1]

                directory = f"ananta beta/main/{base_dir}/{region}/{type_}/{version}"

                # Save main config
                save_file(directory, filename, content)

                # Extra file download
                if isinstance(data, dict):

                    pkg = data.get("pc", {}).get("pkg", {})

                    base_url = pkg.get("url")
                    patch_id = pkg.get("patch")

                    if base_url and patch_id:

                        if not base_url.endswith("/"):
                            base_url += "/"

                        extra_files = [
                            "catalog.txt",
                            "trunks.txt"
                        ]

                        for extra_file in extra_files:

                            file_url = f"{base_url}{patch_id}/{extra_file}"

                            try:
                                write_log(f"Downloading {extra_file}")

                                extra_resp = requests.get(
                                    file_url,
                                    timeout=30
                                )

                                if extra_resp.status_code == 200:

                                    save_file(
                                        directory,
                                        extra_file,
                                        extra_resp.content
                                    )

                                else:
                                    write_log(
                                        f"Failed to fetch {extra_file} "
                                        f"(Status {extra_resp.status_code})"
                                    )

                            except Exception as e:
                                write_log(
                                    f"Error downloading {extra_file}: {e}"
                                )

                    else:
                        write_log(
                            f"No patch/base_url found for version {version}"
                        )

            else:
                write_log(f"Version not found for {url}")


# =========================
# MAIN
# =========================

if __name__ == "__main__":

    write_log("========== START ==========")

    process_urls(launcher, "launcher")

    process_urls(game, "game")

    write_log("=========== END ===========")