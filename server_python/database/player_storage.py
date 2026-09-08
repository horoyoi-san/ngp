"""
Player Storage Manager
Stores player profiles, characters, and inventory in JSON files.
"""

import os
import json
import time
from typing import Dict, Any, Optional

DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "players")


class PlayerStorage:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.players_dir = DATA_DIR
        os.makedirs(self.players_dir, exist_ok=True)
        self._next_aid = 10001
        self._next_pid = 1000000001
        self._scan_existing_ids()

    def _scan_existing_ids(self):
        for fname in os.listdir(self.players_dir):
            if fname.endswith(".json"):
                try:
                    fpath = os.path.join(self.players_dir, fname)
                    with open(fpath, "r", encoding="utf-8") as f:
                        data = json.load(f)
                        aid = data.get("aid", 0)
                        pid = data.get("pid", 0)
                        if aid >= self._next_aid:
                            self._next_aid = aid + 1
                        if pid >= self._next_pid:
                            self._next_pid = pid + 1
                except Exception:
                    pass

    def get_or_create_by_account(self, account_name: str) -> Dict[str, Any]:
        """Gets or creates player data by account name."""
        account_name = (account_name or "Player").strip()
        fpath = os.path.join(self.players_dir, f"{account_name}.json")

        if os.path.exists(fpath):
            try:
                with open(fpath, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception as e:
                print(f"[PlayerStorage] Error loading {fpath}: {e}")

        # Create new default player profile
        default_cfg = self.config.get("gameplay", {}).get("default_player", {})
        player = {
            "account": account_name,
            "aid": self._next_aid,
            "pid": self._next_pid,
            "token": f"token_{account_name}_{int(time.time())}",
            "name": default_cfg.get("name", account_name),
            "level": default_cfg.get("level", 90),
            "gender": default_cfg.get("gender", 1),
            "gold": default_cfg.get("gold", 999999),
            "diamond": default_cfg.get("diamond", 99999),
            "stamina": default_cfg.get("stamina", 240),
            "created_at": int(time.time()),
            "last_login": int(time.time()),
            "has_created_role": True,
            "characters": [
                {
                    "character_id": 1001,
                    "level": default_cfg.get("level", 90),
                    "exp": 0,
                    "star": 5,
                }
            ],
            "inventory": [
                {"item_id": 101, "count": 999},
                {"item_id": 102, "count": 999},
            ],
        }
        self._next_aid += 1
        self._next_pid += 1
        self.save_player(player)
        return player

    def get_player_by_aid(self, aid: int) -> Optional[Dict[str, Any]]:
        for fname in os.listdir(self.players_dir):
            if fname.endswith(".json"):
                fpath = os.path.join(self.players_dir, fname)
                try:
                    with open(fpath, "r", encoding="utf-8") as f:
                        p = json.load(f)
                        if p.get("aid") == aid:
                            return p
                except Exception:
                    pass
        return None

    def get_player_by_pid(self, pid: int) -> Optional[Dict[str, Any]]:
        for fname in os.listdir(self.players_dir):
            if fname.endswith(".json"):
                fpath = os.path.join(self.players_dir, fname)
                try:
                    with open(fpath, "r", encoding="utf-8") as f:
                        p = json.load(f)
                        if p.get("pid") == pid:
                            return p
                except Exception:
                    pass
        return None

    def save_player(self, player: Dict[str, Any]):
        account = player.get("account", "default")
        fpath = os.path.join(self.players_dir, f"{account}.json")
        try:
            with open(fpath, "w", encoding="utf-8") as f:
                json.dump(player, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"[PlayerStorage] Failed to save player {account}: {e}")
