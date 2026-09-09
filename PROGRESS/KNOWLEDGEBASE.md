# Ananta Private Server — Knowledge Base (client 4229938)

> Living document. Lua files under `lua/` are absolute truth for field order and
> (de)serialization. `dump.cs` (IL2CPP) is truth for method signatures.
> `Ananta.Server/ClientData/4229938/MethodId.dump.cs` + `MethodIds.json` are truth for IDs.
> `RpcSurface.json` covers **client→server only** (`IClientToGame*`); server→client
> signatures come from `dump.cs` abstract/interface declarations.

## 1. Transport / framing (verified in source)

- TCP servers: login x2 (`network.loginPorts`), game (`network.gamePort`), wired in
  `Ananta.Server/Ananta.App/PrivateServerApplication.cs` via `TcpServer` + `RpcRouter`.
- `Ananta.Server/Ananta.Network/RpcFrameDispatcher.cs`:
  - `mode 0x04` (8-byte payload) = heartbeat request → reply `mode 0x03` same bytes.
  - `mode 0x03` len 8 = heartbeat reply, ignored.
  - `mode 0x08` len ≥ 9 = client reports unimplemented server invoke → server ACKs
    `Return(methodId, invokeId, 0, empty)`.
  - `mode 0x09` = RPC packet → `RpcRouter.DispatchAsync`.
- `Ananta.SDK/Rpc/RpcRouter.cs`: invoke handlers by method id, else `OnUnknownInvoke`;
  notify handlers, else `OnUnknownNotify`. Exceptions in invoke handlers fall back to
  the unknown-invoke handler (typed-default reply), so the client callback never hangs.
- `TcpSession` (`Ananta.SDK/Network/TcpSession.cs`): `NotifyAsync(methodId, body, token)`
  and `ReturnAsync(...)` are thread-safe (`_sendLock`) → safe to call from admin threads.
- Session state: `TcpSession.Items["client4229938-world"]` → `WorldEntryState`
  (`Ananta.Core/Protocol/Client4229938/WorldEntryState.cs`), via `GameRouter.GetWorldState`.
  Live transform lives in `LastReportedPlayerPosition/Rotation` (+ `HasLastReported...`),
  updated by `GameRouter.Movement.cs` from all 5 movement RPCs.
- `Ananta.Core` exposes internals to `Ananta.Handlers` + `Ananta.App`;
  `Ananta.Handlers` exposes internals to `Ananta.App` (see `AssemblyInfo.cs` files).

## 2. Serialization rules (lua is truth)

- Wire = UX.RPC custom ordered binary (`UXBinaryWriter/Reader`), NOT protobuf.
  `proto_dump/*.proto` field numbers are synthetic ordinals for browsing only.
- C# mirror: `[UxContract(Inline = true)]` classes in
  `Ananta.Server/Ananta.RpcTypes/...`; field **declaration order = wire order**.
  `UxSerializer.Serialize<T>` is public (`Ananta.SDK/Serialization/UxContract.cs`).
  Enums serialize as their underlying type (byte for drive/set-position enums).
- `UXVector3` = 3× single (X, Y, Z). Verified `RPCSerializeAuto.lua:11429`.
- `TeleportOption` (server→client `SyncTeleport` 64030755), verified
  `RPCSerializeAuto.lua:10271` + `dump.cs` (`TeleportOption` TypeDef 33016):
  `teleportId u64, Position UXVector3, Facing single, IsSwitchScene bool,
  WaitTaskResource bool, MapEntranceId u32`.
- `PreTeleportOption` (client→server `AskTeleport` 63175104 arg), verified
  `RPCSerializeAuto.lua:8337` + `dump.cs` (TypeDef 33015):
  `configId u32, teleportId u64, ForceClear bool, TimeLineDration u32, position,
  facing single, beforeResName string, customBeforeTrans bool, beforePosition,
  beforeRot, loadingResName string, afterResName string, customAfterTrans bool,
  afterPosition, afterRot, extParams string`.
- `SetPositionTypeForClient` enum (`dump.cs` TypeDef 32205):
  `Force=0, RejectSync=1, Revive=2, SwitchSpirit=3, SpoonNoLoading=4, FallGround=5,
  Teleport=6, Gm=7, Portal=8, OutOfStuck=9`. Serialized as byte.
- Existing C# DTOs already match: `SyncUnitPositionP` (WorldMethods.cs:124),
  `SyncUnitPositionAndFacing` (:272), `WorldCodec.PositionP/PositionAndFacing`
  (default type 3 = SwitchSpirit).

## 3. Teleport (all IDs verified in `MethodId.cs`)

| Id | Name | Dir | Signature (dump.cs / lua) |
|---|---|---|---|
| 62733679 | `Teleport` | C→S invoke? (UXRPCMethodArgs: `x,z` floats) | GM teleport x,z |
| 63175104 | `AskTeleport` | C→S invoke `UXRPCTask` | arg `PreTeleportOption` |
| 63032762 | `ReportPreTeleportFinish` | C→S invoke | arg `teleportId u64` |
| 63682240 | `ReportPostTeleportFinish` | C→S notify void | args `teleportId u64, result` |
| 64167855 | `SyncPreTeleportOption` | S→C notify | arg `PreTeleportOption` |
| 64030755 | `SyncTeleport` (`IGameToClient_SyncTeleport`) | S→C notify | arg `TeleportOption` |
| 68030312 | `SyncUnitPositionAndFacing` | S→C notify | `(unitId u64, pos, facing, moveId u8, continueMove bool, type, moveGroundInfo?, loadingInfo?)` |
| 68233969 | `SyncUnitPosition_P` | S→C notify | `(unitId u64, pos, facing, moveId u8, type u8)` |
| 68088911 | `SyncTeleportVehicle` | S→C | `(entityId u64, position, rotation, velocity float, reset bool, moveToken int)` |
| 69073332 | `GmTeleportXYZ` (GM svc) | C→S | `(x,y,z,facing=0)` |

Admin-teleport strategy (user chose "try both, log results"):
1. **Primary: instant move** — `SyncUnitPosition_P` with `type=6 (Teleport)`.
   No loading flow, mirrors what `WorldCodec.PositionP` already builds.
2. **Secondary: loading flow** — `SyncPreTeleportOption` + `SyncTeleport`
   (`TeleportOption`, fresh `teleportId`, `IsSwitchScene=false`), then expect
   `ReportPreTeleportFinish` / `ReportPostTeleportFinish` from client (logged).
3. **Inbound**: handle `AskTeleport` (log + empty-ok), `ReportPre/PostTeleportFinish`
   (log + accept), GM `Teleport(x,z)` (log + treat as position hint).

## 4. Vehicles (IDs verified)

| Id | Name | Dir | Signature |
|---|---|---|---|
| 62135059 | `GmAddVehicle` | C→S invoke `UXRPCTask` | `(vehicleId u32)` |
| 63497070 | `AskVehicleShopSpawnVehicle` | C→S invoke `UXRPCTask<ulong>` | `(shopId u32, vehicleId u32, isBind bool)` → `vehicleUid u64` |
| 63495445 | `VehicleDriveStateChange` | C→S invoke `UXRPCTask` | `(state: DriveState enum as byte)`; lua enum values 0/1/2 |
| 63272881 | `AskGetUnlockedVehicles` | C→S invoke | returns `List<PlayerVehicleClientDetail>` (complex → typed-default fallback for now) |
| 67012447 | `AskSummonVehicle` | C→S invoke | returns `SummonVehicleResult` (complex → fallback+log for now) |
| 64871623 | `SyncAllUnlockedVehicles` | S→C notify | unlock-list push (shape TBD — needs client test) |

- Fleet ids live in `config/private-server.json → gameplay.vehicles.fleetIds`
  (currently `enabled:false`). `VehicleConfig.json` / `VehicleSpawnConfig.json` in
  `ConfigDump_v3/` hold template data.
- Phase-1 server work: real handlers for the 3 simple methods (correct return shapes:
  empty-ok / ulong uid / empty-ok) + recording last-seen drive state per session for
  the admin panel. Full S→C spawn push (`SyncAllUnlockedVehicles` /
  `SyncTeleportVehicle`) is implemented as stubs behind the admin API and MUST be
  validated against the live client before being called "working".

## 9. Scene ("raid") switching (Phase 2, live-test pending)

- Verified pattern (both `old_servers` agree): full switch = re-push `SyncEnterScene`
  (64406364) with new raid/instance/universe + arrival, then the normal barrier
  lifecycle (`AskLoadSceneCompleted` → quartet → `AskLoadingFinished` → movement).
  Implemented in `GameRouter.SceneSwitch.cs:SwitchSceneAsync`, callable from the admin
  bridge and from `AskPublicSwitchToPublicScene` (63491547, args raidId/delay/entrance).
- Known cities: Nova `23300888/20001222` (WorldMap_Release) and Lingyun/Chongxiao
  `23300999/20001223` (arrival `-1638,18.025,1540.5` facing `-6.4`), same universe
  `76000888`. Lingyun ids proven on sibling 4091149 build; `23300999` confirmed present
  in current `ConfigDump_v3/RaidConfig.json`.
- `WorldEntryState.WorldEntryAllowNonInitialControl`: switches re-arm the transaction
  on the active character; login strictness (initial actor) unchanged
  (`GameRouter.World.cs` profile-identity check).
- `EnterSceneInfo` 4229938 shape (current `Auto` contracts, login-proven) is reused
  as-is for switches via `RuntimePayloadFactory.EnterScene`.

## 10. Vehicles, real spawn (Phase 2, live-test pending)

- Reference: `old_servers/newcityps/.../GameRouter.Vehicle4091149.cs` direct-spawn path.
  4229938 deltas applied from current lua: `LogicVehicleClientInfo.VehicleSpoonName`
  tail string, `PlayerVehicleClientDetail.IsPersistent` tail bool.
- Spawn push: `SyncLogicVehicleEnter` (68983719, `CreateSourceType=2`) +
  `SyncSpawnVehicle` (68333117, controller 0, interactable) +
  `SyncChangeVehicleInteractable` (68943521, true); entity ids from
  `8.2e18` counter (same as proven 4091149 build), seats from
  `VehicleConfig.json` (`VehicleSeatNum`), spawn at player-right 5.5m / +0.15m.
- Ownership: `SyncAllUnlockedVehicles` (64871623, `List<PlayerVehicleClientDetail>`,
  top-level list return proven) published once on `LoginGame` when
  `gameplay.vehicles.enabled=true`; `AskGetUnlockedVehicles` (63272881) serves snapshots.
- `AskSummonVehicle` (67012447, args u32 config + vec3 + f32 facing, 20-byte body)
  validates then spawns; returns `SummonVehicleResult{entity,token}`.
- Enter/exit/move/seat notifies (`AskPlayerStartEnterOrExitVehicle` 67225310 notify,
  `AskPlayerFinishEnterOrExitVehicle` 67211905 notify, `AskVehicleMove` 67743393 notify
  with `RaidVehicleSyncData`, `AskClaimVehicleSeat` 67793830 invoke → u8) are
  logged + tracked only — no speculative pushes until live traffic is observed.
  `AskVehicleMove` mirrors position while `CurrentVehicleId` matches (panel follows).

## 11. S011 boarding story (Phase 3, live-test pending)

- Live finding: without the S011 root node the client sends *nothing* on F.
  Story channel: S→C `SyncStoryCoreServerInfo` (68629349, raw bytes),
  C→S `SyncStoryCoreClientInfo` (67130745, notify, raw bytes).
- Writer (`StoryS011Codec4229938.cs`): Create=3/Delete=4/ConfirmRpc=2/Enable=6/
  Validate=9; payload tags Bool=5/Int=12/ULong=44; base RpcId/HasRpcId trail.
  dump.cs verified: `StoryClientCommand{RpcId,HasRpcId}` (69583),
  `StoryServerCommand{RpcId,HasRpcId}` (69590), Create{Nid,Type,**StoryboardGuid**,Sync}
  (69592), Validate{Nid + 4 string lists} (69593), Delete{Nid} (69594),
  Enable{Nid + 3 NamedPayload lists} (69595), ConfirmRpc{ConfirmRpcId} (69599),
  `S011EnterVehicleRequestPayload{VehicleId u64, SeatIndices byte[]}` (69653),
  `S011VehicleAndSeatPayload{VehicleId, SeatIndex}` (69654).
- Root bootstrap (nid 1, type `StoryServer.Story.World.S011.S011PlayerNet`, seven
  `S011PlayerNet*Request` messengers) is pushed after every `AskLoadingFinished`;
  enter/exit children (nids 2/3) + cumulative RpcId confirms drive the seat phases
  with `SyncUnitVehicleStatus` 2→3→4 / 5→0 and controller handoffs
  (`GameRouter.VehicleStory.cs`).
- Numeric type marks are carried over from the sibling 4091149 build (class set
  identical, stability assumed); the C2S parser returns prefixes + `partial parse`
  warnings so drift is diagnosable from logs.

## 12. Scene catalog (Phase 3, live-test pending)

- `SceneCatalog4229938.cs` over `RaidConfig.json` + `MapentranceConfig.json`:
  instance id = raid `SceneId`, universe = raid `Multiverse` (else config universe),
  arrival = `MapTeleportPos` ?? `Coordinate` + `EntranceFacing`.
- ~93 entrance presets (61 Nova + 28 Lingyun + 3 single-entrance raids) with English
  labels, plus curated Nova-spawn / Lingyun-Dinglan defaults.
- Admin JSON uses `JsonNamingPolicy.CamelCase` (class DTOs serialize camelCase;
  fixes the "undefined" preset display).

## 5. Time / sync (user priority)

- Gate already OK: `LoginGateRouter.GateGetServerTime` handles `GetServerTime`
  (52951195, invoke AND notify) → `SendServerTime` (53477227) with
  `LoginCodec.ServerTime(clientUnixTime?)`.
- Game side: `GameRouter.Endpoints.GetServerTime` already answers `GetServerTimeGame`
  (63266454, invoke AND notify) → `SendServerTimeGame` (64114176) echoing the client
  clock via `LoginCodec.ServerTime(clientUnixTime)`; world entry also pushes
  `SendServerTimeGame` on `LoginGame`. No change needed.
- Heartbeat is frame-level (dispatcher), no method id.

## 6. Unknown-method logging

- Before: `GameRouter.Compatibility4229938.DefaultUnknownInvoke/Notify` only wrote to
  console/log stream; `AskSummonVehicle`-style complex methods silently got typed
  defaults with no durable record.
- After: both paths also append one line to `logs/unknown-methods.log`
  (dir = resolved `logging.directory`): UTC timestamp, kind, `name [hex]`,
  body length, hex prefix (capped). Return behavior unchanged.

## 7. Admin panel

- Embedded `HttpListener` in `Ananta.App` (`Admin/AdminWebServer.cs`), configured via
  new `admin` section in `private-server.json` (`enabled, host, port`; default
  `127.0.0.1:17888`, localhost-only, no auth per user choice).
- Session bridge: `GameAdminBridge` (public static, in `Ananta.Handlers`) — session
  registry fed by the per-frame hook in `PrivateServerApplication` (previously the
  `GameSessionHub` was created but never passed to the game server, so nothing was
  tracked — fixed by registering every game frame's session).
- API: `GET /api/status` (pos/rot/unit/ready/session age), `POST /api/teleport`,
  `POST /api/vehicle/spawn` (Phase-1: records intent + tries unlock push; result logged),
  `GET /api/vehicles` (fleet + last drive state), `GET /api/unknown-log/tail`.
- Single-page HTML UI polls status (position visible), forms for teleport + vehicle.

## 8. Methodology (how to extend safely)

1. Find method name in `lua/LuaGen/AutoGen/RPCMethodIdToName.lua` → id.
2. Confirm id in `MethodId.cs` / `MethodIds.json`.
3. Get C→S signature: `ClientToGame*.lua` serializer + `RpcSurface.json` (kind/returnType).
4. Get S→C signature: `dump.cs` abstract/virtual declarations.
5. Get field order: `RPCSerializeAuto.lua` `Auto.Write*` (declaration order = wire order).
6. Mirror as `[UxContract(Inline=true)]` DTO in `Ananta.RpcTypes`, handler in
   `Ananta.Handlers/Game/GameRouter.*.cs`, register id in `GameRouter.Enabled4229938MethodIds`
   (or rely on unknown fallback + log first to capture live traffic).
7. Test: build (`dotnet build`), run server, exercise client, read
   `logs/unknown-methods.log` + packet logs to confirm shapes before hardening.
