# Progress Report — Phase 5/6: unhandled-log batch + weapons + combat profile (2026-09-08)

## User test results from Phase 4

- Enter/Exit buttons + driving + nitro + drift **all work**. F-enter officially abandoned.
- New orders: (1) implement unhandled items from the log, (2) weapon wheel grants,
  (3) character skills / combat.

## 1. Unknown-log triage (top hits)

| Method | Count | Action |
|---|---|---|
| CameraMove / CamRotation / CamFOV / CamAspect | ~8000 | Silent no-op handlers (pure telemetry) |
| OnParkourStateChange | 893 | Registered at last (handler existed, id missing from allow-set — real bug) |
| AskVehicleNitroValue / ReportDrivingVehicle | 1507 / 418 | Decoded + tracked per vehicle (nitro value, driving flag, odometer) |
| AskInteractCmd | 668 | Already handled in Phase 4 |
| SyncChangeSafeArea / Indoor / Building | 52 / 45 / 19 | Decoded logging accepts (sector control later) |
| AskGetVehicleRadioContent | 53 | Logged + explicit typed-default reply |
| AskVehicleNitro / Horn / TopSpeed / ContactDamage / InteractConfig / DestructibleParts | misc | Decoded logging handlers (nitro returns OK) |
| Trade/Market/History, Ranking, Popularity×2, InspireHub×3, Link×2, LastMode | misc | Registered at last (same allow-set bug) |
| Mail/AkxSession/Metro/Moments/Panel/NameEffect/PersonalInfo | ~150 | Second neutral batch (typed-default + info log) |

**Allow-set bug**: `AttributedHandlerRegistry.RegisterSelected` only registers ids in
`Enabled4229938MethodIds`. The 12 Compatibility handlers (neutral economy/social +
parkour) were never registered, so they fell into the unknown fallback despite existing.
Fixed by listing them. Total handlers now: ~100 unique.

## 2. Weapon grant (admin panel)

- `GameRouter.WeaponGrant.cs`: `GrantWeaponAsync` resolves
  `CombatCatalogRepository.AccountWeapons` by template id (~634 armory weapons) and
  pushes `SyncArmoryAddWeapon` (64463649) with the deterministic instance id.
  No wheel mutation needed — existing `AskLoadWeaponToSlot` accepts any account weapon,
  so the user equips in-game via the armory UI.
- Panel: weapon card with full catalog dropdown + Grant button
  (`GET /api/weapons`, `POST /api/weapons/grant`).

## 3. Combat profile restore (the skill unblock)

- Root cause: `CombatProfilePublished` was never set `true`, so `OnClientUseSkill`
  rejected every skill request. New `PublishCombatProfile` (Profiles.cs) sends the
  reference order — HP → attrs → urban → fight-style unlock/action → charges →
  resources → battle module → weapon snapshot → 6 skill bindings → last-used →
  switch-action → capability buffs — on **first gameplay movement** (deferred
  hydration, login flow untouched).
- Skill-adjacent RPC accepts (logged empty replies): InterruptSkillExecute2,
  SkillExecute3/End2, SkillAddState, SkillOpen/CloseShield, SkillTimeCurve,
  SkillAnimationEnd, SkillSpawnItem, SwitchSpiritComplete, SpoonClientAttack,
  VehicleSkillDamage, SkillDestructibleCreate Gadget/Vehicle variants.

## Verification

- `dotnet build AnantaPS.sln` → **succeeded, 0 warnings, 0 errors**.
- Live client test required (user runs server).

## How to test (user)

1. Log in, move (first movement now publishes the combat profile — look for
   `[COMBAT] profile` in console). Play normally: do skills work better/differently?
   Any UI errors? Paste `[COMBAT]` lines.
2. Weapon card: grant a weapon (e.g. pick any rifle), open armory/wheel in game —
   does it appear? Can you slot + wield it?
3. `unknown-methods.log` should be dramatically quieter (camera/parkour/UI gone).
   Paste any remaining high-frequency entries.
4. Driving/teleport/scenes regression check (combat profile touches first movement).

## Next (not yet done)

- Authoritative damage/HP (`OnSkillHit` still logs only), skill echo (VFX),
  cooldown consumption, buffs beyond traversal, indoor sector control. Awaiting test
  signal before changing live combat further.

## Crash fix (same day): missing fight-style dicts

- Symptom: client dies ~1 frame after `[COMBAT] profile` (connection drops seconds
  later when the server notices the dead socket).
- Root cause: `SyncPlayerFightStyleUnLockInfo` body was short — dump.cs proves
  `PlayerFightStyleUnLockChangeInfo` has 3 fields (`playerInfoFightStyle`,
  `addOrUpdateUnlockInfo`, **`addOrUpdateUnlockTimeInfo` Dict&lt;uint,uint&gt;`) and
  `PlayerInfoFightStyle` has 2 (`FightStyleIsUnLocked`,
  **`FightStyleFirstUnlockTimes` Dict&lt;uint,uint&gt;**); our DTOs omitted the last
  dict in each. The client reader over-read into garbage → crash.
- Fix: appended both dicts (empty) in dump order. All other profile DTOs re-verified
  against `dump.cs` interface signatures (`SyncUnitAttrs`, `SyncPlayerAllSkillChargeData`,
  `SyncFightResource`, `SyncChangeCommonSkill`, `SyncAttachBattleModule`,
  `SpiritFightTypeChangeAction`, `ChargeData` all match).
