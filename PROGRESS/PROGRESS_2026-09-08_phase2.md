# Progress Report — Phase 2: scene switching + real vehicle spawn (2026-09-08)

## User test results from Phase 1

- **Instant teleport: works perfectly.** `SyncUnitPosition_P` type=Teleport confirmed live.
- **Vehicle spawn: nothing happened** (expected — Phase-1 admin spawn only recorded,
  sent zero packets). Unknown log is being written correctly.
- User supplied `old_servers/`: `newcityps` (4091149, same lineage, new city, few
  features) and `oldserverfeatures` (8+ months old, many features). Both mined for
  reference; every port verified against current 4229938 lua + dump before use.
- New priority: **scene ("raid") switching first**, then vehicles.

## What the old servers taught (verified, not copied blind)

- Scene switch = re-push `SyncEnterScene` with new raid/instance/universe + arrival,
  then let the normal load-barrier lifecycle run again (both old servers agree;
  `newcityps` `AirportTravel4091149.BeginAirportTravel`, old `SceneSwitchManager.SwitchScene`).
- Vehicle direct spawn = `SyncLogicVehicleEnter` + `SyncSpawnVehicle` (interactable)
  + return `SummonVehicleResult{entity,token}` (+ `SyncChangeVehicleInteractable`).
  `newcityps` `GameRouter.Vehicle4091149.AskSummonVehicle4091149` full flow used as reference.
- 4229938 wire deltas vs 4091149 found in current lua and applied:
  `LogicVehicleClientInfo.VehicleSpoonName` (tail string) and
  `PlayerVehicleClientDetail.IsPersistent` (tail bool).
- All 20+ vehicle/scene method ids are **identical** between 4091149 and 4229938
  (same lineage) — verified one by one in current `MethodId.cs`.
- Raid `23300999` (Lingyun/Chongxiao) confirmed present in current
  `ConfigDump_v3/RaidConfig.json`.

## What was implemented

1. **Scene switching** (`GameRouter.SceneSwitch.cs`):
   - `SwitchSceneAsync`: re-arms the world-entry transaction (new generation, arrival
     as CreateHero transform, all barrier flags reset), clears vehicle runtime, pushes
     `SyncGamePause(true)` + `SyncEnterScene` with the destination. Existing
     `OnLoadSceneCompleted` / `OnLoadingFinished` / movement handlers finish the handoff.
   - `AskPublicSwitchToPublicScene` handler: known preset raids switch, rest logged.
   - `AskEnterRaidByMapEntrance` handler: logged + accepted (no entrance map yet).
   - `WorldEntryState.WorldEntryAllowNonInitialControl`: switches can land on any owned
     character (login path strictness unchanged).
   - Admin: presets Nova `23300888/20001222` + Lingyun `23300999/20001223` (same universe
     `76000888`), custom raid/instance/universe/coords form, status shows active raid.
2. **Vehicles, real** (`GameRouter.Vehicle.cs` rewritten + `VehicleMethods4229938.cs` DTOs
   + `VehicleCatalog4229938.cs` over `ClientData/4229938/Configs/VehicleConfig.json`
   copied from the game dump):
   - `SyncAllUnlockedVehicles` ownership publish on `LoginGame` (gated by
     `gameplay.vehicles.enabled`, now default `true`).
   - `AskGetUnlockedVehicles` → returns owned list (proves top-level `List<T>` returns).
   - `AskSummonVehicle` → validates (20-byte body, catalog, prefab, seats) then the
     direct-spawn push beside the player (right 5.5m, +0.15m), returns
     `SummonVehicleResult{entity,token}`.
   - Admin spawn now runs the **same** push — car really appears; walk up, press F.
   - Enter/exit/move/seat notifies (`AskPlayerStart/FinishEnterOrExitVehicle`,
     `AskVehicleMove`, `AskClaimVehicleSeat`) are logged + tracked (current vehicle shown
     in panel; position follows while driving). **No speculative enter pushes yet** —
     the next step depends on what the live client sends.
3. **Admin panel**: scene card (preset select + custom), vehicle card updated, status
   shows raid/instance/universe + current vehicle/seat.

## Verification

- `dotnet build AnantaPS.sln` → **succeeded, 0 warnings, 0 errors**.
- Handler id uniqueness re-checked: 63 unique game handlers, 24 gate.
- Live client test required (user runs server).

## How to test (user)

1. Start server, log in. Admin status should now also show `raid=23300888 ...`.
2. **Scene**: click "Switch to preset" on Lingyun → expect loading screen, arrival at
   `(-1638, 18.025, 1540.5)`. Report: does it load? Correct place? Can you move?
   Then switch back to Nova preset. Paste `[SCENE]` / `[WORLD]` log lines, especially
   any `rejected` lines.
3. **Vehicle**: spawn e.g. `81001001` → car should appear beside you. Walk up, press F.
   Report: can you enter? drive? Paste `[VEHICLE]` lines (ENTER/EXIT/move-start) and
   any new `unknown-methods.log` entries around entering/driving (e.g. S011 story
   `SyncStoryCoreServerInfo`, `AskUpdateVehicleAITaskStatus`, phone/F1 `AskSummonVehicle`).
4. In-game F1 summon (phone car call) if available — report what happens.

## Known risks / open questions

- Lingyun arrival coordinates come from the 4091149 build; geometry may differ in
  4229938 — custom coordinates form is the fallback.
- Enter/drive flow may need S011 story-channel pushes (`newcityps` used them); Phase 2
  deliberately sends none until live traffic shows what's needed.
- `PlayerVehicleClientDetail.IsPersistent=false` for all owned; semantics unknown.
- `gameplay.vehicles.enabled` flipped to `true` — ownership notify is new login traffic;
  if login breaks, set it back to `false` and report.
