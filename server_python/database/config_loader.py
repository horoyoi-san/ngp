"""
Game Config Loader
Loads JSON data from ConfigDump/ConfigDump_v3.
"""

import os
import json
from typing import Dict, Any, Optional

CONFIG_DUMP_DIR = os.path.abspath(
    os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "ConfigDump", "ConfigDump_v3")
)


class ConfigLoader:
    def __init__(self, dump_dir: str = CONFIG_DUMP_DIR):
        self.dump_dir = dump_dir
        self._cache: Dict[str, Any] = {}

    def get_config(self, name: str) -> Optional[Dict[str, Any]]:
        """Loads a config JSON file by name (e.g., 'CharacterConfig' or 'GlobalServerConfig')."""
        if not name.endswith(".json"):
            name += ".json"

        if name in self._cache:
            return self._cache[name]

        fpath = os.path.join(self.dump_dir, name)
        if not os.path.exists(fpath):
            return None

        try:
            with open(fpath, "r", encoding="utf-8") as f:
                data = json.load(f)
                self._cache[name] = data
                return data
        except Exception as e:
            print(f"[ConfigLoader] Failed to read {fpath}: {e}")
            return None
