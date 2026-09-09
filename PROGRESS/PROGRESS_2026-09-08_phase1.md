# Progress Report — Phase 1 (2026-09-08)

## User choices (confirmed before work started)

- Admin panel: **embedded C# HTTP server**, port in `private-server.json`.
- Auth: **none, localhost only** (for now).
- Teleport: **try both** (instant `SyncUnitPosition_P` + loading-flow `SyncTeleport`), log results.
- Vehicles: **investigate then implement** (handlers first, spawn-push as testable stub).
- Unknown-method log: **`logs/unknown-methods.log`**, single append log.
- Missing-method priority: **time/sync + ping**.

## What was investigated (evidence, not guesses)

- Framing/heartbeat: `Ananta.Server/Ananta.Network/RpcFrameDispatcher.cs:17-47`.
- Session state key: `GameRouter.cs:13` (`client4229938-world`), live transform in
  `WorldEntryState.cs:60-62`, updated in `GameRouter.Movement.cs:11-44`.
- `RpcSurface.json` is client→server only; server→client signatures taken from
  `dump.cs` (e.g. `SyncTeleport(TeleportOption)` :1732684, `SyncUnitPosition_P(...)`
  :1731925, `SendServerTimeGame(double,double)` :1732987,
  `AskVehicleShopSpawnVehicle→ulong` :1726402, `GmAddVehicle(uint)` :1736357).
- Field order from lua: `WriteTeleportOption` (`RPCSerializeAuto.lua:10271`),
  `WritePreTeleportOption` (:8337), `WriteUXVector3` (:11429).
- `SetPositionTypeForClient` enum values from `dump.cs` (Force=0 … Teleport=6, Gm=7 …).
- Found wiring bug: `PrivateServerApplication.cs:42-48` accepted an optional
  `GameSessionHub` but the game server was created without one, so **no game session
  was ever tracked** — fixed as part of the admin bridge.

## What was implemented (this phase)

1. `logs/unknown-methods.log` — `UnknownMethodLogger` (Core) hooked into
   `DefaultUnknownInvoke/Notify4229938`; return behavior unchanged.
2. Time/sync — verified the existing `GetServerTimeGame` (63266454) handler in
   `GameRouter.Endpoints.cs:19-29` already answers with `SendServerTimeGame`
   (an earlier draft added a duplicate handler and crashed at startup with
   "Duplicate invoke handler" — removed; single handler confirmed).
3. Teleport (`GameRouter.Teleport.cs` + `TeleportMethods.cs` DTOs):
   inbound `AskTeleport` / `ReportPreTeleportFinish` / `ReportPostTeleportFinish` /
   GM `Teleport(x,z)` handlers (log + protocol-correct replies);
   outbound `TeleportPlayerAsync` (instant `SyncUnitPosition_P` type=Teleport) and
   `TeleportPlayerWithLoadingAsync` (`SyncPreTeleportOption` + `SyncTeleport`).
4. Vehicles (`GameRouter.Vehicle.cs` + `VehicleMethods.cs` DTOs):
   `GmAddVehicle`, `AskVehicleShopSpawnVehicle` (returns generated uid),
   `VehicleDriveStateChange` (records last drive state per session).
   Complex-return methods (`AskGetUnlockedVehicles`, `AskSummonVehicle`) intentionally
   left on the typed-default fallback so they appear in the new unknown log for study.
5. Admin panel (`Ananta.App/Admin/AdminWebServer.cs`, `admin` config section,
   default `127.0.0.1:17888`): status/position polling, teleport form (instant +
   loading-flow modes), vehicle spawn form (fleet list from config + last drive
   state), unknown-log tail viewer.
6. Docs: `KNOWLEDGEBASE.md` (this folder) + this report.

## Config changes

- `PrivateServerConfig.cs`: new `AdminSettings` (`enabled, host, port`) + validation.
- `config/private-server.json` + `config/private-server.example.json`:
  added `"admin": { "enabled": true, "host": "127.0.0.1", "port": 17888 }`.

## Verification (build)

- `dotnet build AnantaPS.sln` → **succeeded, 0 warnings, 0 errors** (2026-09-08).
- Both `config/private-server.json` and `config/private-server.example.json` parse
  and contain `admin { enabled:true, host:127.0.0.1, port:17888 }`.
- Live client test still required (see below) — the server cannot be fully verified
  without the game client, which only the user can run.

## How to verify (needs user — client can't be modified)

1. `dotnet build AnantaPS.sln` (from `Ananta-PS_08.05/`).
2. Run `START.cmd` / `Run-All.ps1`, log in with the game client, move around.
3. Open `http://127.0.0.1:17888/` → position should update as you move.
4. Teleport: enter X/Y/Z (+facing), mode `instant`, submit → player should move.
   Then try mode `loading` → report whether a loading screen appears and whether
   the player lands at the target (check `logs/` + unknown-methods.log for
   `ReportPre/PostTeleportFinish`).
5. Vehicle: pick a fleet id from the admin page, submit → report what happens
   (expected Phase-1: logged server-side; client may show nothing — paste the
   related `logs/unknown-methods.log` lines + packet log excerpts).
6. Unknown log: `logs/unknown-methods.log` should now list every unhandled method
   with id + hex prefix while you play.

## Known risks / open questions for testing

- `SyncTeleport` loading flow may require matching `PreTeleportOption.configId`;
  current stub uses `configId=0` + client-reported position — needs live feedback.
- `SyncAllUnlockedVehicles` push shape is not yet reverse-engineered; admin spawn
  currently records intent + attempts push, result must be observed client-side.
- `DriveState` lua enum names are obfuscated (values 0/1/2 only); semantics
  (enter/exit/driving) need observation of `VehicleDriveStateChange` traffic.
