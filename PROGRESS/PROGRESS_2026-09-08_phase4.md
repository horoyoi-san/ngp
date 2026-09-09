# Progress Report — Phase 4: presets fixed + catalog + story diagnostics (2026-09-08)

## Phase 5: admin Enter/Exit buttons (same day, user request)

- Skipped F-enter debugging per user request; server-forced seating instead.
- Verified 4229938 enter vocabulary in dump.cs: `SyncPlayerMoveToDriveSeat(pid, vid)`,
  `SyncPlayerStartEnterOrExitVehicle(driveState)`, `SyncPlayerVehicleStateChange`,
  `SyncPlayerFinishEnterOrExitVehicle`, `SyncPlayerExitVehicle(vid, force, stop)`.
- `ForceEnterVehicleAsync`: interactable=false → move-to-seat → boarding status 4
  (seated) → start/state-change/finish → controller=pid → S011 enter child + delete.
  `ForceExitVehicleAsync`: exit + status 0 + controller 0 + interactable + node deletes.
- Admin: `POST /api/vehicle/enter`, `POST /api/vehicle/exit` + panel buttons.
- NOTE: constant names are dump-truncated (`SyncPlayerStartEnterOrExitVehicl`,
  `SyncPlayerFinishEnterOrExitVehic`) — do not "fix" the spelling, ids are what matter.

## User test results from Phase 3

- **Scene switching "works mostly now"** (preset display was the main breakage).
- S011 root **is** sent and the client answers story messages — but F-enter still dead.
- Pasted logs decoded by hand:
  - C2S `SyncStoryCoreClientInfo` 22b = `FF 03 | 03 <i64 RpcId=8> 01 | 03 <i64 RpcId=8> 01`
    → two reliable-heartbeat commands, no vehicle content. Channel framing is
    mutually compatible (my ConfirmRpc answers echo correctly, ids advance 7→8).
  - `AskInteractCmd` 72b every ~0.6s = CmdType 19 heartbeat from pid 666, unrelated.
  - So: story channel alive, but the client never emits an enter request on F.

## What was implemented

1. **Preset display fix**: admin JSON now uses `JsonNamingPolicy.CamelCase`
   (`AdminScenePreset.Key/Label/...` → `key/label/...`); anonymous payloads unchanged.
2. **Scene catalog** (`SceneCatalog4229938.cs` + copied `RaidConfig.json`,
   `MapentranceConfig.json`): instance id = raid `SceneId`, universe = raid
   `Multiverse` (else config), arrival = `MapTeleportPos` ?? `Coordinate` + facing.
   ~93 entrance presets with English labels + Nova-spawn / Lingyun-Dinglan defaults.
3. **Aether init** (`EnsureAetherVehicleInit`, called in `OnLoadingFinished` before the
   story root): `SyncAetherAIInitDatas` with raid id, zone-graph flag (Nova only),
   handle `-1044702623`, empty lists — the one reference-proven notify not yet ported.
4. **Diagnostics**: every non-heartbeat story command now logs full detail
   (`[VEHICLE-STORY] cmd ...`); non-19 `AskInteractCmd` gets a real decoding handler
   (CmdType/sender/receiver logged, accepted) so any future F-via-interact is visible.
5. New handler ids registered: `SyncStoryCoreClientInfo` (already), `AskInteractCmd`.

## Verification

- `dotnet build AnantaPS.sln` → **succeeded, 0 warnings, 0 errors**; 65 unique handlers.
- Live client test required (user runs server).

## How to test (user)

1. Log in, spawn a car, walk up, **watch for the F prompt**: does any "enter vehicle"
   prompt appear at all? (This distinguishes "prompt shown, F ignored" from "no prompt".)
2. Press F several times. Paste any new `[VEHICLE-STORY] cmd ...` lines,
   `[INTERACT] cmd=...` lines that are NOT CmdType 19, and `[VEHICLE]` lines.
3. If still nothing: try the in-game phone F1 car-call if it exists, and report what
   happens (that path sends `AskSummonVehicle` → different spawn leg).

## Next steps queued (pending test outcome)

- If the client needs `PlayerInfo` vehicle seeding (`VehicleInfo.UnlockedVehicles`,
  phone contacts, module progress — reference has it, we don't), port it into
  `MinimalPlayerInfo4229938` (requires checking current Auto `InfoMinor` shape first).
- If F goes through `GetInVehicleCommandData` interact path, implement that reply.
- If S011 root is ignored (framing drift), iterate on Create/Validate tags using the
  new command logs as oracle.
