# Progress Report — Phase 3: scene catalog + S011 boarding (2026-09-08)

## User test results from Phase 2

- Login still works (ownership notify is safe).
- **Vehicle spawn works** — cars appear beside the player.
- **F-enter does nothing**: logs prove the client sends *zero* vehicle traffic on F.
  Diagnosis: the client only offers the enter prompt inside the S011 story flow, and
  we never sent the S011 root node. Ported the story channel (below).
- **Presets show "undefined"**: root cause found — `AdminScenePreset` serializes
  PascalCase by default (`Key/Label/RaidId`) while the panel JS reads camelCase.
  Fixed via `JsonNamingPolicy.CamelCase` (anonymous payloads already camelCase,
  unaffected). Scene switching itself was likely fine; the preset-switch request
  just carried an empty preset key.

## What was implemented

1. **Scene catalog from the game dump** (`SceneCatalog4229938.cs`):
   - Copied `RaidConfig.json` + `MapentranceConfig.json` into client data.
   - Verified pattern: raid `SceneId` == instance id (Nova 20001222, Lingyun 20001223);
     universe = raid `Multiverse` (e.g. raid 23301290 → 76001290) else config universe.
   - Presets = curated Nova spawn + Lingyun Dinglan + **every map entrance with valid
     coords (~93: 61 Nova, 28 Lingyun, + 23301096/23301098/23301148)** labeled with
     their English names, e.g. "Zenith Center (raid 23300999)".
   - `AskPublicSwitchToPublicScene` resolves any catalog raid (first preset of the raid).
2. **S011 boarding story** (the F-enter fix):
   - `StoryS011Codec4229938.cs`: server-command writer (Create=3/Delete=4/ConfirmRpc=2/
     Enable=6/Validate=9; payload tags Bool=5/Int=12/ULong=44), verified against dump.cs
     story classes (69583-69599, S011 payloads 69653-69655). 4229938 delta applied:
     `CreateClientNodeServerCommand` gained `StoryboardGuid` → sent as null.
   - `StoryVehicleCodec4229938.cs`: defensive C2S story parser (prefix returned on
     unknown marks; "partial parse" warnings pinpoint framing drift).
   - `GameRouter.VehicleStory.cs`: S011 root bootstrap pushed after every
     `AskLoadingFinished`; full enter (reserve → child + controller + status 2/3/4) /
     exit (child + status 5 → 0) phase machine with cumulative RpcId confirms;
     story-aware `AskClaimVehicleSeat`; best-effort eject before scene switches.
   - Seat reservations/occupants tracked per vehicle; `ForceLeaveVehicleAsync` on switch.
3. **Admin panel**: JSON casing fixed (presets will now show), scene select populated
   from `/api/scenes` (~95 entries), status already shows raid/vehicle.

## Verification

- `dotnet build AnantaPS.sln` → **succeeded, 0 warnings, 0 errors**; 64 unique handlers.
- Live client test required (user runs server).

## How to test (user)

1. Log in → panel status shows raid; check server log for
   `[VEHICLE-STORY] S011 root ready` after loading finishes.
2. Spawn a car → walk up → **press F**. Report: enter animation? seated? drive?
   Paste ALL `[VEHICLE-STORY]` lines plus any `partial parse` warnings (those tell me
   if the 4229938 story framing drifted from the reference).
3. If seated: drive with WASD, then exit (F again?). Paste move/exit lines.
4. Scene presets should now list real names — try a Lingyun entrance preset
   (e.g. Zenith Center), then back to Nova spawn. Paste `[SCENE]`/`[WORLD]` lines,
   especially any `rejected`.

## Open risks

- Story command/payload numeric marks (2/3/4/5/6, 5/6/12/36/37/44) are carried over
  from the sibling build (class set verified identical, marks assumed stable). If F
  still does nothing AND no `SyncStoryCoreClientInfo` traffic appears in logs, the
  root bootstrap framing needs adjustment — the `partial parse` warnings will show it.
- `Create.StoryboardGuid=null` is an inference (no storyboard for server nodes).
- Single-entrance raids (23301096/23301098/23301148) and non-Nova/Lingyun RaidType-1
  maps are untested destinations; custom form is the fallback.
