using System.Collections.Concurrent;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>Public snapshot of the tracked game session for the admin panel (no internal types leak).</summary>
public sealed class AdminPlayerSnapshot
{
    public bool Connected { get; init; }
    public string SessionId { get; init; } = string.Empty;
    public string? LastSeenUtc { get; init; }
    public ulong UnitId { get; init; }
    public uint TemplateId { get; init; }
    public float X { get; init; }
    public float Y { get; init; }
    public float Z { get; init; }
    public float Facing { get; init; }
    public bool HasTransform { get; init; }
    public bool Ready { get; init; }
    public uint ActiveRaidId { get; init; }
    public ulong ActiveInstanceId { get; init; }
    public uint ActiveUniverseId { get; init; }
    public ulong PendingTeleportId { get; init; }
    public uint LastAdminVehicleId { get; init; }
    public ulong LastSpawnedVehicleUid { get; init; }
    public ulong CurrentVehicleId { get; init; }
    public int CurrentVehicleSeat { get; init; }
    public byte LastVehicleDriveState { get; init; }
    public bool HasVehicleDriveState { get; init; }
    public uint TimeHour { get; init; }
    public uint TimeMinute { get; init; }
    public bool TimeFixed { get; init; }
    public bool HasExplicitTime { get; init; }
    public uint WeatherId { get; init; }
    public bool HasExplicitWeather { get; init; }
}

/// <summary>Public weapon catalog entry for the admin panel.</summary>
public sealed class AdminWeaponEntry
{
    public uint TemplateId { get; init; }
    public string Name { get; init; } = string.Empty;
    public ulong InstanceId { get; init; }
}

/// <summary>Public scene preset (raid/instance/universe + arrival) for the admin panel.</summary>
public sealed class AdminScenePreset
{
    public string Key { get; init; } = string.Empty;
    public string Label { get; init; } = string.Empty;
    public uint RaidId { get; init; }
    public ulong InstanceId { get; init; }
    public uint UniverseId { get; init; }
    public float X { get; init; }
    public float Y { get; init; }
    public float Z { get; init; }
    public float Facing { get; init; }
}

/// <summary>
/// Bridge between the game session and the embedded admin web server.
/// Fed by the per-frame hook in PrivateServerApplication (every login+game frame);
/// only sessions carrying a 4229938 world state are treated as the player session.
/// All pushes use the same DTOs + method ids as the in-game handlers.
/// </summary>
public static class GameAdminBridge
{
    private static readonly ConcurrentDictionary<string, (TcpSession Session, long Ticks)> Sessions = new();
    private static long s_adminTeleportCounter = 950_000;

    public static void Touch(TcpSession session)
        => Sessions[session.Id] = (session, DateTimeOffset.UtcNow.Ticks);

    public static AdminPlayerSnapshot GetSnapshot()
    {
        var best = PickPlayerSession();
        if (best is null)
            return new AdminPlayerSnapshot { Connected = false };
        var (session, ticks) = best.Value;
        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return new AdminPlayerSnapshot
            {
                Connected = false,
                SessionId = session.Id,
                LastSeenUtc = new DateTimeOffset(ticks, TimeSpan.Zero).ToString("o"),
            };
        lock (state.SyncRoot)
        {
            return new AdminPlayerSnapshot
            {
                Connected = true,
                SessionId = session.Id,
                LastSeenUtc = new DateTimeOffset(ticks, TimeSpan.Zero).ToString("o"),
                UnitId = state.ActiveSpiritUnitId,
                TemplateId = state.ActiveSpiritTemplateId,
                X = state.LastReportedPlayerPosition.X,
                Y = state.LastReportedPlayerPosition.Y,
                Z = state.LastReportedPlayerPosition.Z,
                Facing = state.HasLastReportedPlayerTransform ? state.LastReportedPlayerRotation.Y : state.WorldEntryCreateHeroFacing,
                HasTransform = state.HasLastReportedPlayerTransform,
                Ready = state.Ready,
                ActiveRaidId = state.ActiveRaidId,
                ActiveInstanceId = state.ActiveInstanceId,
                ActiveUniverseId = state.ActiveUniverseId,
                PendingTeleportId = state.PendingTeleportId,
                LastAdminVehicleId = state.LastAdminVehicleId,
                LastSpawnedVehicleUid = state.LastSpawnedVehicleUid,
                CurrentVehicleId = GameRouter.GetVehicleRuntimeState(session) is { } vehicles
                    ? CurrentVehicleOf(vehicles) : 0,
                CurrentVehicleSeat = GameRouter.GetVehicleRuntimeState(session) is { } vehicles2
                    ? CurrentSeatOf(vehicles2) : -1,
                LastVehicleDriveState = state.LastVehicleDriveState,
                HasVehicleDriveState = state.HasVehicleDriveState,
                TimeHour = state.TimeHour,
                TimeMinute = state.TimeMinute,
                TimeFixed = state.TimeFixed,
                HasExplicitTime = state.HasExplicitTime,
                WeatherId = state.WeatherId,
                HasExplicitWeather = state.HasExplicitWeather,
            };
        }
    }

    private static ulong CurrentVehicleOf(GameRouter.VehicleRuntimeState runtime)
    {
        lock (runtime.SyncRoot)
            return runtime.CurrentVehicleId;
    }

    private static int CurrentSeatOf(GameRouter.VehicleRuntimeState runtime)
    {
        lock (runtime.SyncRoot)
            return runtime.CurrentVehicleSeat;
    }

    public static uint[] FleetIds()
    {
        try { return PrivateServerConfigStore.Current.Gameplay.Vehicles.FleetIds ?? []; }
        catch { return []; }
    }

    /// <summary>
    /// Scene presets: curated world spawns first, then every map entrance from the
    /// game dump (SceneCatalog4229938: RaidConfig SceneId = instance id). Falls back
    /// to the two curated entries if the catalog fails to load.
    /// </summary>
    public static IReadOnlyList<AdminScenePreset> ScenePresets()
    {
        uint universe;
        try { universe = PrivateServerConfigStore.Current.World.UniverseId; }
        catch { universe = 76000888; }
        var result = new List<AdminScenePreset>
        {
            new()
            {
                Key = "nova-spawn", Label = "Nova spawn (WorldMap_Release)",
                RaidId = 23300888, InstanceId = 20001222, UniverseId = universe,
                X = 3142.669922f, Y = 0f, Z = 2522.780029f, Facing = 0f,
            },
            new()
            {
                Key = "lingyun-dinglan", Label = "Dinglan North Road — Lingyun (23300999)",
                RaidId = 23300999, InstanceId = 20001223, UniverseId = universe,
                X = -1638f, Y = 18.025f, Z = 1540.5f, Facing = -6.39965f,
            },
        };
        try
        {
            foreach (var p in ClientData.Client4229938.SceneCatalog4229938.Presets)
                result.Add(new AdminScenePreset
                {
                    Key = p.Key, Label = p.Label, RaidId = p.RaidId, InstanceId = p.InstanceId,
                    UniverseId = p.UniverseId, X = p.X, Y = p.Y, Z = p.Z, Facing = p.Facing,
                });
        }
        catch { /* curated defaults above still work */ }
        return result;
    }

    internal static bool TryGetScenePreset(uint raidId, out AdminScenePreset? preset)
    {
        foreach (var p in ScenePresets())
        {
            if (p.RaidId != raidId)
                continue;
            preset = p;
            return true;
        }
        preset = null;
        return false;
    }

    /// <summary>Instant move: SyncUnitPosition_P with SetPositionType.Teleport(6).</summary>
    public static async Task<(bool Ok, string Message)> TeleportInstantAsync(float x, float y, float z, float? facing)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        var (session, state) = target.Value;
        ulong unitId;
        float face;
        lock (state.SyncRoot)
        {
            unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
            face = facing ?? (state.HasLastReportedPlayerTransform ? state.LastReportedPlayerRotation.Y : Profile.WorldFacing);
            state.LastReportedPlayerPosition = new Vec3(x, y, z);
            state.LastReportedPlayerRotation = new Vec3(0f, face, 0f);
            state.HasLastReportedPlayerTransform = true;
        }
        try
        {
            var body = UxSerializer.Serialize(WorldCodec.PositionP(unitId, new Vec3(x, y, z), face, setPositionType: 6));
            await session.NotifyAsync(MethodId.SyncUnitPosition_P, body, CancellationToken.None);
            session.Log.Info($"[ADMIN] instant teleport unit={unitId} pos=({x:F2},{y:F2},{z:F2}) facing={face:F2}");
            return (true, $"instant teleport sent: unit={unitId} ({x:F2},{y:F2},{z:F2}) facing={face:F2}");
        }
        catch (Exception ex)
        {
            return (false, $"send failed: {ex.Message}");
        }
    }

    /// <summary>Loading-flow move: SyncPreTeleportOption + SyncTeleport with a fresh teleport id.</summary>
    public static async Task<(bool Ok, string Message)> TeleportWithLoadingAsync(float x, float y, float z, float? facing)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        var (session, state) = target.Value;
        float face;
        ulong teleportId;
        lock (state.SyncRoot)
        {
            face = facing ?? (state.HasLastReportedPlayerTransform ? state.LastReportedPlayerRotation.Y : Profile.WorldFacing);
            teleportId = (ulong)Interlocked.Increment(ref s_adminTeleportCounter);
            state.PendingTeleportId = teleportId;
            state.PendingTeleportPreFinished = false;
            state.PendingTeleportSyncSent = true;
            state.LastReportedPlayerPosition = new Vec3(x, y, z);
            state.LastReportedPlayerRotation = new Vec3(0f, face, 0f);
            state.HasLastReportedPlayerTransform = true;
        }
        try
        {
            var pre = new GameMethods.PreTeleportOption
            {
                configId = 0,
                teleportId = teleportId,
                ForceClear = false,
                TimeLineDration = 0,
                position = new GameMethods.TeleportVec3(x, y, z),
                facing = face,
                beforeResName = string.Empty,
                customBeforeTrans = false,
                beforePosition = new GameMethods.TeleportVec3(x, y, z),
                beforeRot = new GameMethods.TeleportVec3(0f, face, 0f),
                loadingResName = string.Empty,
                afterResName = string.Empty,
                customAfterTrans = false,
                afterPosition = new GameMethods.TeleportVec3(x, y, z),
                afterRot = new GameMethods.TeleportVec3(0f, face, 0f),
                extParams = string.Empty,
            };
            await session.NotifyAsync(MethodId.SyncPreTeleportOption, UxSerializer.Serialize(pre), CancellationToken.None);
            var sync = new GameMethods.TeleportOption
            {
                teleportId = teleportId,
                Position = new GameMethods.TeleportVec3(x, y, z),
                Facing = face,
                IsSwitchScene = false,
                WaitTaskResource = false,
                MapEntranceId = 0,
            };
            await session.NotifyAsync(MethodId.SyncTeleport, UxSerializer.Serialize(sync), CancellationToken.None);
            session.Log.Info($"[ADMIN] loading-flow teleport teleportId={teleportId} pos=({x:F2},{y:F2},{z:F2}) facing={face:F2}");
            return (true, $"loading-flow teleport sent: teleportId={teleportId} ({x:F2},{y:F2},{z:F2}) facing={face:F2}; watch ReportPre/PostTeleportFinish in logs");
        }
        catch (Exception ex)
        {
            return (false, $"send failed: {ex.Message}");
        }
    }

    /// <summary>
    /// Admin vehicle spawn: validates against the catalog/fleet, then runs the same
    /// direct-scene-spawn push as client summon (SyncLogicVehicleEnter + SyncSpawnVehicle,
    /// interactable). The car appears beside the player; walk up and press F to drive.
    /// </summary>
    public static async Task<(bool Ok, string Message, ulong Uid)> SpawnVehicleAsync(uint vehicleId)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)", 0UL);
        var (session, state) = target.Value;
        var fleet = FleetIds();
        if (fleet.Length != 0 && !fleet.Contains(vehicleId))
            return (false, $"vehicleId {vehicleId} is not in gameplay.vehicles.fleetIds ({fleet.Length} entries)", 0UL);
        Vec3 near;
        float facing;
        lock (state.SyncRoot)
        {
            near = state.LastReportedPlayerPosition;
            facing = state.HasLastReportedPlayerTransform ? state.LastReportedPlayerRotation.Y : state.WorldEntryCreateHeroFacing;
        }
        try
        {
            var result = await GameRouter.SpawnDirectAsync(session, vehicleId, near, facing, "admin-panel");
            return (result.Ok, result.Message, result.EntityId);
        }
        catch (Exception ex)
        {
            return (false, $"spawn failed: {ex.Message}", 0UL);
        }
    }

    /// <summary>Admin enter: seats the player in the last spawned vehicle (no F-press needed).</summary>
    public static async Task<(bool Ok, string Message)> EnterVehicleAsync()
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        try
        {
            return await GameRouter.ForceEnterVehicleAsync(target.Value.Session);
        }
        catch (Exception ex)
        {
            return (false, $"enter failed: {ex.Message}");
        }
    }

    /// <summary>Admin exit: ejects the player from the current vehicle.</summary>
    public static async Task<(bool Ok, string Message)> ExitVehicleAsync()
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        try
        {
            return await GameRouter.ForceExitVehicleAsync(target.Value.Session);
        }
        catch (Exception ex)
        {
            return (false, $"exit failed: {ex.Message}");
        }
    }

    /// <summary>Admin time set: records + pushes SyncPlayerCurrentTime.</summary>
    public static async Task<(bool Ok, string Message)> SetTimeAsync(int hour, int minute, bool fix, int transition)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        if (hour is < 0 or > 23 || minute is < 0 or > 59)
            return (false, "hour must be 0..23 and minute 0..59");
        if (transition < 0)
            transition = 0;
        var (session, state) = target.Value;
        lock (state.SyncRoot)
        {
            state.TimeHour = (uint)hour;
            state.TimeMinute = (uint)minute;
            state.TimeFixed = fix;
            state.TimeTransitionSeconds = (uint)transition;
            state.HasExplicitTime = true;
        }
        try
        {
            await GameRouter.PushSessionTimeAsync(session);
            return (true, $"time set to {hour:D2}:{minute:D2} (fix={fix})");
        }
        catch (Exception ex)
        {
            return (false, $"time push failed: {ex.Message}");
        }
    }

    /// <summary>Admin weather set: records + pushes SyncPlayerWeather.</summary>
    public static async Task<(bool Ok, string Message)> SetWeatherAsync(int weatherId, int transition)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        if (weatherId < 0 || transition < 0)
            return (false, "weatherId and transition must be >= 0");
        var (session, state) = target.Value;
        lock (state.SyncRoot)
        {
            state.WeatherId = (uint)weatherId;
            state.WeatherTransitionSeconds = (uint)transition;
            state.HasExplicitWeather = weatherId != 0;
        }
        if (weatherId == 0)
            return (true, "weather override cleared (client default resumes)");
        try
        {
            await GameRouter.PushSessionWeatherAsync(session);
            return (true, $"weather set to {weatherId}");
        }
        catch (Exception ex)
        {
            return (false, $"weather push failed: {ex.Message}");
        }
    }

    public static object TimeWeatherStatus()
    {
        var snap = GetSnapshot();
        return new
        {
            connected = snap.Connected,
            hour = snap.TimeHour,
            minute = snap.TimeMinute,
            fix = snap.TimeFixed,
            hasTime = snap.HasExplicitTime,
            weatherId = snap.WeatherId,
            hasWeather = snap.HasExplicitWeather,
            weathers = ClientData.Client4229938.WeatherCatalog4229938.All.Select(w => new { id = w.Id, name = w.Name }).ToList(),
        };
    }

    /// <summary>Admin weapon grant: pushes SyncArmoryAddWeapon for a catalog template.</summary>
    public static async Task<(bool Ok, string Message)> GrantWeaponAsync(uint templateId)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        if (templateId == 0)
            return (false, "templateId must be non-zero");
        try
        {
            return await GameRouter.GrantWeaponAsync(target.Value.Session, templateId);
        }
        catch (Exception ex)
        {
            return (false, $"grant failed: {ex.Message}");
        }
    }

    public static IReadOnlyList<AdminWeaponEntry> WeaponCatalog()
        => GameRouter.WeaponCatalog().Select(w => new AdminWeaponEntry
        {
            TemplateId = w.TemplateId,
            Name = ClientData.Client4229938.WeaponNameTranslator4229938.EnglishFor(w.TemplateId, w.Name),
            InstanceId = w.InstanceId,
        }).ToList();

    /// <summary>Admin scene ("raid") switch: re-push SyncEnterScene for the destination.</summary>
    public static async Task<(bool Ok, string Message)> SwitchSceneAsync(
        uint raidId, ulong instanceId, uint universeId, float x, float y, float z, float facing)
    {
        var target = RequirePlayerSession();
        if (target is null)
            return (false, "no player session tracked yet (log in with the game client first)");
        if (raidId == 0 || instanceId == 0 || universeId == 0)
            return (false, "raidId/instanceId/universeId must all be non-zero");
        if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z) || !float.IsFinite(facing))
            return (false, "coordinates must be finite numbers");
        try
        {
            await GameRouter.SwitchSceneAsync(target.Value.Session, raidId, instanceId, universeId, x, y, z, facing, "admin-panel");
            return (true, $"scene switch sent: raid={raidId} instance={instanceId} universe={universeId} ({x:F2},{y:F2},{z:F2}) — loading screen expected, then arrival");
        }
        catch (Exception ex)
        {
            return (false, $"switch failed: {ex.Message}");
        }
    }

    private static (TcpSession Session, WorldEntryState State)? RequirePlayerSession()
    {
        var best = PickPlayerSession();
        if (best is null)
            return null;
        var state = GameRouter.GetStateIfExists(best.Value.Session);
        return state is null ? null : (best.Value.Session, state);
    }

    private static (TcpSession Session, long Ticks)? PickPlayerSession()
    {
        (TcpSession Session, long Ticks)? best = null;
        foreach (var entry in Sessions.Values)
        {
            try
            {
                if (!entry.Session.Client.Connected)
                    continue;
            }
            catch { continue; }
            if (GameRouter.GetStateIfExists(entry.Session) is null)
                continue;
            if (best is null || entry.Ticks > best.Value.Ticks)
                best = entry;
        }
        return best;
    }
}
