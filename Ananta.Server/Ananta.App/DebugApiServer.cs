using System.Net;
using System.Text;
using System.Text.Json;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.Configuration;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.App;

/// <summary>
/// Localhost-only HTTP debug server: serves the embedded debug panel (GET /)
/// plus the JSON API for it. Optional: enable via config "debug".
/// Never exposed outside 127.0.0.1 by default.
/// </summary>
internal sealed class DebugApiServer(PrivateServerConfig config, GameSessionHub hub) : IDisposable
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false,
    };

    private static readonly Lazy<byte[]> PanelHtml = new(() =>
    {
        using var stream = typeof(DebugApiServer).Assembly
            .GetManifestResourceStream("Ananta.App.DebugPanel.index.html")
            ?? throw new InvalidOperationException("Embedded debug panel is missing (Ananta.App.DebugPanel.index.html).");
        using var ms = new MemoryStream();
        stream.CopyTo(ms);
        return ms.ToArray();
    });

    private readonly HttpListener _listener = new();
    private readonly CancellationTokenSource _cts = new();
    private Task? _loop;

    internal void Start()
    {
        var prefix = $"http://{config.Debug.Host}:{config.Debug.Port}/";
        _listener.Prefixes.Add(prefix);
        _listener.Start();
        _loop = LoopAsync(_cts.Token);
        Console.WriteLine($"[DEBUG-API] panel+api on {prefix}");
    }

    internal void Stop()
    {
        try { _cts.Cancel(); } catch { }
        try { _listener.Stop(); } catch { }
        try { _listener.Close(); } catch { }
    }

    public void Dispose() => Stop();

    private async Task LoopAsync(CancellationToken token)
    {
        while (!token.IsCancellationRequested)
        {
            HttpListenerContext ctx;
            try
            {
                ctx = await _listener.GetContextAsync().WaitAsync(token);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (HttpListenerException)
            {
                break;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DEBUG-API] accept failed: {ex.Message}");
                continue;
            }

            _ = HandleAsync(ctx, token);
        }
    }

    private async Task HandleAsync(HttpListenerContext ctx, CancellationToken token)
    {
        try
        {
            var path = ctx.Request.Url?.AbsolutePath ?? "/";
            var method = ctx.Request.HttpMethod.ToUpperInvariant();

            if (method == "GET" && (path == "/" || path == "/index.html"))
                await WriteHtmlAsync(ctx, token);
            else if (method == "GET" && path == "/api/status")
                await WriteJsonAsync(ctx, Status(), token);
            else if (method == "GET" && path == "/api/fleet")
                await WriteJsonAsync(ctx, Fleet(), token);
            else if (method == "POST" && path == "/api/garage/resync")
                await WriteJsonAsync(ctx, await GarageResyncAsync(token), token);
            else if (method == "POST" && path == "/api/garage/unlock-all")
                await WriteJsonAsync(ctx, await GarageUnlockAllAsync(token), token);
            else if (method == "POST" && path == "/api/player/teleport")
                await WriteJsonAsync(ctx, await TeleportAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/spawn")
                await WriteJsonAsync(ctx, await VehicleSpawnAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/to-me")
                await WriteJsonAsync(ctx, await VehicleToMeAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/goto")
                await WriteJsonAsync(ctx, await VehicleGotoAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/remove")
                await WriteJsonAsync(ctx, await VehicleRemoveAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/enter")
                await WriteJsonAsync(ctx, await VehicleEnterAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/exit")
                await WriteJsonAsync(ctx, await VehicleExitAsync(token), token);
            else if (method == "GET" && path == "/api/time")
                await WriteJsonAsync(ctx, TimeStatus(), token);
            else if (method == "POST" && path == "/api/time/set")
                await WriteJsonAsync(ctx, await TimeSetAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else
                await WriteJsonAsync(ctx, new { ok = false, error = "unknown route (GET /api/status, GET /api/fleet, GET /api/time, POST /api/time/set, POST /api/garage/resync, POST /api/garage/unlock-all, POST /api/player/teleport, POST /api/vehicle/spawn, POST /api/vehicle/to-me, POST /api/vehicle/goto, POST /api/vehicle/remove, POST /api/vehicle/enter, POST /api/vehicle/exit)" }, token, 404);
        }
        catch (Exception ex)
        {
            try { await WriteJsonAsync(ctx, new { ok = false, error = ex.Message }, token, 500); } catch { }
        }
    }

    private object Status()
    {
        var session = hub.Current;
        if (session is null)
            return new { online = false };

        var pid = Profile.PlayerPid;
        Vec3 pos = Profile.WorldSpawn;
        Vec3 rot = new(0f, Profile.WorldFacing, 0f);
        var hasFix = false;
        var ready = false;
        var activeUnit = Profile.InitialUnitId;

        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                pos = state.LastReportedPlayerPosition;
                rot = state.LastReportedPlayerRotation;
                hasFix = state.HasLastReportedPlayerTransform;
                ready = state.Ready;
                if (state.ActiveSpiritUnitId != 0)
                    activeUnit = state.ActiveSpiritUnitId;
            }
        }

        var summoned = GameRouter.SummonedSnapshot()
            .Select(v => new { entityId = v.EntityId, configId = v.ConfigId, x = v.X, y = v.Y, z = v.Z, yaw = v.Yaw, hasFix = v.HasFix })
            .ToList();
        var (inVehicle, inSeat) = GameRouter.VehicleSeatSnapshot(session);
        var (hour, minute, fix, hasTime) = ReadSessionTime(session);

        return new
        {
            online = true,
            pid,
            ready,
            activeUnit,
            player = new { x = pos.X, y = pos.Y, z = pos.Z, yaw = rot.Y, hasFix },
            spawn = new { x = Profile.WorldSpawn.X, y = Profile.WorldSpawn.Y, z = Profile.WorldSpawn.Z },
            summoned,
            inVehicle,
            inSeat,
            fleetCount = config.Gameplay.Vehicles.FleetIds.Length,
            hour,
            minute,
            fix,
            hasTime,
        };
    }

    private object Fleet()
    {
        return VehicleCatalog.All
            .Select(v => new { id = v.Id, name = v.Name, cat = v.Category })
            .ToList();
    }

    /// <summary>
    /// Full vehicle catalog (other team's list, 2026-09-09): id + display name + category.
    /// Includes broken/undrivable entries (marked in the name) — spawn is warn-and-allow,
    /// the client has the final say. Single source for the panel dropdowns.
    /// </summary>
    private static class VehicleCatalog
    {
        internal sealed record Entry(uint Id, string Name, string Category);

        internal static readonly Entry[] All =
        [
            // Sport / Luxury / Unique
            new(81005001, "Kazama CE68", "sport"),
            new(81005008, "Hoyne Bridgemont Aether", "sport"),
            new(81005013, "NO001", "sport"),
            new(81007004, "NO002", "sport"),
            new(81007086, "GTR-S55", "sport"),
            new(81005009, "Pallas Solaris", "sport"),
            new(81005005, "Erebos E55 L convertible", "sport"),
            new(81007068, "Erebos E55 L [broken]", "sport"),
            new(81007085, "Erebos E55 L [broken]", "sport"),
            new(81004021, "Fusion Rhino S2 [no livery]", "sport"),
            new(81005006, "Fusion Rhino S2", "sport"),
            new(81002008, "Rowden Bulldog", "sport"),
            new(81007071, "Rowden Bulldog", "sport"),
            new(81002006, "Smove SR-5", "sport"),
            new(81007072, "Smove SR-5", "sport"),
            new(81007087, "Smove SR-5", "sport"),
            new(81007069, "Sunset CE86 [broken camera]", "sport"),
            new(81005003, "Sunset GT X Convertible [black hood]", "sport"),
            new(81007027, "Sunset GT X Convertible [carbon hood]", "sport"),
            new(81000007, "Sunset GT X Coupe [carbon roof]", "sport"),
            new(81000011, "Sunset GT X Coupe [black roof]", "sport"),
            new(81005002, "Sunset GT X Coupe [carbon roof]", "sport"),
            new(81007054, "Sunset GT X Coupe [black roof]", "sport"),
            new(81007066, "Sunset GT X Coupe [black roof]", "sport"),
            new(81002001, "Sunset GT7", "sport"),
            new(81007003, "Sunset GT7", "sport"),
            new(81007018, "Sunset GT7", "sport"),
            new(81007033, "Sunset GT7 [broken camera]", "sport"),
            new(81002009, "Sunset Selena GT", "sport"),
            new(81005007, "Veloce Quicksilver", "sport"),
            new(81000028, "Monster Car", "sport"),
            new(81007020, "Monster Car Claws Out", "sport"),
            new(81007023, "Monster Car Broken", "sport"),
            new(81002002, "GTR R35 Roofless", "sport"),
            new(81007064, "GTR R35 Roofless", "sport"),
            // Regular cars
            new(81001010, "Aico C5", "regular"),
            new(81001006, "Kazama CRN6", "regular"),
            new(81007074, "Kazama CRN6", "regular"),
            new(81007090, "Kazama CRN6", "regular"),
            new(81004001, "Kazama CRN6 Taxi [undrivable]", "regular"),
            new(81004015, "Kazama CRN6 Taxi [undrivable]", "regular"),
            new(81007025, "Kazama CRN6 Taxi", "regular"),
            new(81007043, "Kazama CRN6 Taxi", "regular"),
            new(81007029, "Kazama CRN6 Police", "regular"),
            new(81007044, "Kazama CRN6 Police", "regular"),
            new(81001009, "Kazama Elegant", "regular"),
            new(81004002, "Kazama Elegant Police", "regular"),
            new(81004016, "Kazama Elegant Police", "regular"),
            new(81007078, "Kazama Elegant Police", "regular"),
            new(81004026, "Kazama Elegant unmarked police", "regular"),
            new(81001007, "Kazama Jiame", "regular"),
            new(81004004, "Kazama NT-Comfort [undrivable]", "regular"),
            new(81001016, "Kazama P300", "regular"),
            new(81001002, "Korou RV6", "regular"),
            new(81007001, "Korou RV6", "regular"),
            new(81002007, "Pico Boxer Cat R", "regular"),
            new(81007002, "Pico Boxer Cat R", "regular"),
            new(81007011, "Pico Boxer Cat R", "regular"),
            new(81007082, "Pico Boxer Cat R", "regular"),
            new(81001017, "Pulse Type 3", "regular"),
            new(81001013, "Smove S3", "regular"),
            new(81001015, "Stahlwerk TengDa", "regular"),
            new(81001008, "Sunset Asuka", "regular"),
            new(81007084, "Sunset Asuka", "regular"),
            new(81007077, "Sunset Asuka dirty", "regular"),
            new(81001011, "Sunset NEO:E", "regular"),
            new(81001001, "Sunset Spider", "regular"),
            new(81007096, "Sunset Spider [broken]", "regular"),
            new(81003001, "Sunset Traveler W7", "regular"),
            new(81007019, "Sunset Traveler W7", "regular"),
            new(81007021, "Sunset Traveler W7", "regular"),
            new(81007041, "Sunset Traveler W7 [broken camera]", "regular"),
            new(81003006, "Sunset XD", "regular"),
            new(81007040, "Sunset XD [broken windshield]", "regular"),
            new(81007076, "Sunset XD [undrivable]", "regular"),
            new(81001018, "Sunset Tianyue", "regular"),
            new(81007032, "Civic 2025 [unfinished]", "regular"),
            // SUV / Pickups
            new(81001012, "Erebos SC53", "suv"),
            new(81003016, "Kazama Kanu", "suv"),
            new(81003004, "Sandstrom 70 stock", "suv"),
            new(81003005, "Sandstrom 70 offroad", "suv"),
            new(81007028, "Sandstrom 70 stock", "suv"),
            new(81003010, "Sandstrom 70 enemy 2 seats", "suv"),
            new(81003011, "Sandstrom 70 enemy 4 seats", "suv"),
            new(81003013, "Highland Sandstrom 200", "suv"),
            new(81007093, "Highland Sandstrom 200 [broken]", "suv"),
            new(81004027, "Highland Sandstrom 200 police", "suv"),
            new(81001019, "Traveler 3", "suv"),
            new(81004033, "Traveler 3 patrol", "suv"),
            new(81003012, "Wasteland pickup enemy", "suv"),
            new(81005004, "Wasteland pickup", "suv"),
            new(81003008, "Reiforce Jim", "suv"),
            new(81003007, "Hilux-ish pickup", "suv"),
            // Vans / Bus
            new(81007009, "Freelander Yeti milk van", "van"),
            new(81007095, "Freelander Yeti [broken anim]", "van"),
            new(81003009, "Kazama Express Van", "van"),
            new(81007063, "Kazama Express Van [undrivable]", "van"),
            new(81001003, "Kazama Jialu", "van"),
            new(81001020, "Normal20a", "van"),
            new(81007073, "Kazama Jialu", "van"),
            new(81007083, "Kazama Jialu", "van"),
            new(81003002, "Kazama Kairo", "van"),
            new(81004011, "Kazama Kairo ambulance", "van"),
            new(81004013, "Korou MT600 bus", "van"),
            // Trucks / Heavy duty
            new(81000005, "Erebos BlackBox truck", "truck"),
            new(81000004, "Firetruck", "truck"),
            new(81004014, "Firetruck dirty", "truck"),
            new(81007094, "Firetruck marine", "truck"),
            new(81007012, "Firetruck [no water]", "truck"),
            new(81004017, "Korou Cruze M stripped", "truck"),
            new(81004018, "Korou Cruze M flatbed", "truck"),
            new(81004019, "Korou Cruze M flatbed tow", "truck"),
            new(81004020, "Korou Cruze M hook tow", "truck"),
            new(81004022, "Korou Cruze cargo", "truck"),
            new(81004024, "Korou Cruze L livestock", "truck"),
            new(81004025, "Korou Cruze fridge", "truck"),
            new(81007079, "Korou Cruze cargo [empty]", "truck"),
            new(81007088, "Korou Cruze fridge [livery]", "truck"),
            new(81007091, "Korou Cruze cargo [vault]", "truck"),
            new(81007092, "Korou Cruze cargo", "truck"),
            new(81004005, "Marine M300 mixer", "truck"),
            new(81004006, "Marine M300 garbage", "truck"),
            new(81004007, "Marine M300 hauler no trailer", "truck"),
            new(81004008, "Marine M300 hauler + trailer", "truck"),
            new(81004009, "Marine M300 hauler + trailer old", "truck"),
            new(81004010, "Marine M300 tanker", "truck"),
            new(81007035, "Marine M300 hauler", "truck"),
            new(81007036, "Marine M300 hauler", "truck"),
            new(81007042, "Marine M300 hauler", "truck"),
            new(81004023, "Marine M500 enemy", "truck"),
            new(81007053, "Marine M500 open", "truck"),
            new(81007055, "Marine M500 closed", "truck"),
            new(81004029, "Marine WL500 loader", "truck"),
            new(81004012, "Forklift", "truck"),
            new(81007075, "Motus Hercules + trailer", "truck"),
            new(81003003, "Reiforce Lingtu", "truck"),
            new(81003022, "Reiforce Lingtu", "truck"),
            new(81007024, "Reiforce Lingtu", "truck"),
            new(81007060, "Reiforce Lingtu", "truck"),
            new(81004003, "Dump truck", "truck"),
            // Motorcycles / Scooters
            new(81006002, "Belkraft Dark Roast", "moto"),
            new(81006007, "Belkraft Metal Knight enemy", "moto"),
            new(81006006, "Shikage delivery scooter", "moto"),
            new(81003015, "Shikage Junkrat quad", "moto"),
            new(81004028, "Shikage Freelancer 800 police", "moto"),
            new(81006003, "Shikage Excellent scooter", "moto"),
            new(81007089, "Shikage Excellent scooter", "moto"),
            new(81006010, "Shikage Freelancer 800", "moto"),
            new(81006013, "Shikage SL550 dirt", "moto"),
            new(81006011, "Sunset M125", "moto"),
            new(81006012, "Sunset M125 bosozoku", "moto"),
            new(81006009, "Sunset M125-T trike", "moto"),
            // Watercraft
            new(81006008, "SonicShark jetski", "water"),
            new(81000010, "Speed Tour s200 boat", "water"),
            new(81006005, "Speed Tour s200 boat", "water"),
            // Aircraft
            new(81006001, "Reed helicopter", "air"),
        ];
    }

    /// <summary>
    /// Pushes the FULL catalog (all entries incl. broken/unverified) as the owned
    /// fleet. Explicit button-only action; the default auto-publish/resync stays on
    /// the verified set (config fleetIds).
    /// </summary>
    private async Task<object> GarageUnlockAllAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var body = new SceneMethods.AskGetUnlockedVehiclesResult
        {
            Vehicles = VehicleCatalog.All.Select(v => new SceneMethods.PlayerVehicleClientDetail
            {
                Id = v.Id,
                Parts = [],
                SuitId = 0,
                IsPersistent = true,
            }).ToList(),
        };
        var bytes = UxSerializer.Serialize(body);
        await session.NotifyAsync(MethodId.SyncAllUnlockedVehicles, bytes, token);
        session.Log.Info($"[DEBUG-API] garage UNLOCK-ALL pushed ({body.Vehicles.Count} vehicles, incl. unverified)");
        return new { ok = true, count = body.Vehicles.Count, verified = false };
    }

    private async Task<object> GarageResyncAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var body = new SceneMethods.AskGetUnlockedVehiclesResult
        {
            Vehicles = config.Gameplay.Vehicles.FleetIds.Select(id => new SceneMethods.PlayerVehicleClientDetail
            {
                Id = id,
                Parts = [],
                SuitId = 0,
                IsPersistent = true,
            }).ToList(),
        };
        var bytes = UxSerializer.Serialize(body);
        await session.NotifyAsync(MethodId.SyncAllUnlockedVehicles, bytes, token);
        session.Log.Info($"[DEBUG-API] garage resync pushed ({body.Vehicles.Count} vehicles)");
        return new { ok = true, count = body.Vehicles.Count };
    }

    private async Task<object> TeleportAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        float x, y, z, facing;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            x = root.TryGetProperty("x", out var px) ? (float)px.GetDouble() : throw new InvalidDataException("missing numeric 'x'");
            y = root.TryGetProperty("y", out var py) ? (float)py.GetDouble() : throw new InvalidDataException("missing numeric 'y'");
            z = root.TryGetProperty("z", out var pz) ? (float)pz.GetDouble() : throw new InvalidDataException("missing numeric 'z'");
            facing = root.TryGetProperty("facing", out var pf) ? (float)pf.GetDouble() : Profile.WorldFacing;
            if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z) || !float.IsFinite(facing))
                throw new InvalidDataException("coordinates must be finite numbers");
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        ulong unitId = Profile.InitialUnitId;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                if (state.ActiveSpiritUnitId != 0)
                    unitId = state.ActiveSpiritUnitId;
                state.LastReportedPlayerPosition = new Vec3(x, y, z);
                state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
                state.HasLastReportedPlayerTransform = true;
            }
        }

        return await SendPlayerTeleportAsync(session, unitId, x, y, z, facing, "teleport", token);
    }

    private async Task<object> VehicleGotoAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (!doc.RootElement.TryGetProperty("entityId", out var pe) || (entityId = pe.GetUInt64()) == 0)
                return new { ok = false, error = "missing numeric 'entityId'" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var target = GameRouter.SummonedSnapshot().FirstOrDefault(v => v.EntityId == entityId);
        if (target.EntityId == 0 || !target.HasFix)
            return new { ok = false, error = $"no live coordinates for entityId {entityId} (not tracked or never moved)" };

        // Land behind the vehicle so the player does not spawn inside it.
        var yawRad = target.Yaw * (float)Math.PI / 180f;
        var x = target.X - (float)Math.Sin(yawRad) * 3f;
        var z = target.Z - (float)Math.Cos(yawRad) * 3f;
        var y = target.Y + 0.5f;

        ulong unitId = Profile.InitialUnitId;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                if (state.ActiveSpiritUnitId != 0)
                    unitId = state.ActiveSpiritUnitId;
            }
        }

        return await SendPlayerTeleportAsync(session, unitId, x, y, z, target.Yaw, $"goto vehicle {entityId}", token);
    }

    private static async Task<object> SendPlayerTeleportAsync(TcpSession session, ulong unitId, float x, float y, float z, float facing, string reason, CancellationToken token)
    {
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                state.LastReportedPlayerPosition = new Vec3(x, y, z);
                state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
                state.HasLastReportedPlayerTransform = true;
            }
        }

        var bytes = UxSerializer.Serialize(WorldCodec.PositionAndFacing(unitId, new Vec3(x, y, z), facing));
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing, bytes, token);
        session.Log.Info($"[DEBUG-API] {reason} unit={unitId} to=({x:F1},{y:F1},{z:F1}) facing={facing:F1}");
        return new { ok = true, x, y, z, facing };
    }

    private async Task<object> VehicleSpawnAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var fleet = config.Gameplay.Vehicles.FleetIds;
        uint configId = fleet.Length > 0 ? fleet[0] : 81001001;
        var distance = 6.0f;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("configId", out var pc) && pc.GetUInt32() != 0)
                configId = pc.GetUInt32();
            if (root.TryGetProperty("distance", out var pd))
                distance = (float)pd.GetDouble();
            if (!float.IsFinite(distance) || distance < 2f || distance > 60f)
                return new { ok = false, error = "distance must be 2..60" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        Vec3 pos = Profile.WorldSpawn;
        var yawDeg = Profile.WorldFacing;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                pos = state.LastReportedPlayerPosition;
                yawDeg = state.LastReportedPlayerRotation.Y;
            }
        }
        if (!float.IsFinite(yawDeg))
            yawDeg = Profile.WorldFacing;

        var result = await GameRouter.SpawnDirectAsync(session, configId, pos, yawDeg, rightOffset: distance, sourceType: 2, reason: "debug-panel");
        if (!result.Ok)
            return new { ok = false, error = result.Message };
        return new { ok = true, entityId = result.EntityId, configId, x = result.SpawnPos.X, y = result.SpawnPos.Y, z = result.SpawnPos.Z };
    }

    private async Task<object> VehicleToMeAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (!doc.RootElement.TryGetProperty("entityId", out var pe) || (entityId = pe.GetUInt64()) == 0)
                return new { ok = false, error = "missing numeric 'entityId'" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        if (!GameRouter.SummonedSnapshot().Any(v => v.EntityId == entityId))
            return new { ok = false, error = $"unknown entityId {entityId} (not summoned via server)" };

        Vec3 pos = Profile.WorldSpawn;
        var yawDeg = Profile.WorldFacing;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                pos = state.LastReportedPlayerPosition;
                yawDeg = state.LastReportedPlayerRotation.Y;
            }
        }
        if (!float.IsFinite(yawDeg))
            yawDeg = Profile.WorldFacing;

        var yawRad = yawDeg * (float)Math.PI / 180f;
        var sx = pos.X + (float)Math.Sin(yawRad) * 3f;
        var sz = pos.Z + (float)Math.Cos(yawRad) * 3f;
        var sy = pos.Y + 0.5f;

        var body = new SceneMethods.SyncTeleportVehicle
        {
            EntityId = entityId,
            Position = new SceneMethods.UxVector3(sx, sy, sz),
            Rotation = new SceneMethods.UxVector3(0f, yawDeg, 0f),
            Velocity = 0f,
            Reset = true,
            MoveToken = 0,
        };
        var bytes = UxSerializer.Serialize(body);
        await session.NotifyAsync(MethodId.SyncTeleportVehicle, bytes, token);
        session.Log.Info($"[DEBUG-API] vehicle to-me entity={entityId} at=({sx:F1},{sy:F1},{sz:F1})");
        return new { ok = true, entityId, x = sx, y = sy, z = sz };
    }

    private async Task<object> VehicleRemoveAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (!doc.RootElement.TryGetProperty("entityId", out var pe) || (entityId = pe.GetUInt64()) == 0)
                return new { ok = false, error = "missing numeric 'entityId'" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        await GameRouter.DestroyDirectAsync(session, entityId, "debug-panel");
        return new { ok = true, entityId };
    }

    private async Task<object> VehicleEnterAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId = 0;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (doc.RootElement.TryGetProperty("entityId", out var pe))
                entityId = pe.GetUInt64();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var result = await GameRouter.ForceEnterVehicleAsync(session, entityId);
        return result.Ok
            ? new { ok = true, message = result.Message }
            : new { ok = false, error = result.Message };
    }

    private async Task<object> VehicleExitAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var result = await GameRouter.ForceExitVehicleAsync(session);
        return result.Ok
            ? new { ok = true, message = result.Message }
            : new { ok = false, error = result.Message };
    }

    private object TimeStatus()
    {
        var session = hub.Current;
        if (session is null)
            return new { online = false };
        var (hour, minute, fix, hasTime) = ReadSessionTime(session);
        return new { online = true, hour, minute, fix, hasTime };
    }

    private static (uint Hour, uint Minute, bool Fix, bool HasTime) ReadSessionTime(TcpSession session)
    {
        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return (12, 0, true, false);
        lock (state.SyncRoot)
            return (state.TimeHour, state.TimeMinute, state.TimeFixed, state.HasExplicitTime);
    }

    private async Task<object> TimeSetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        uint hour = 12, minute = 0, transition = 5;
        var fix = true;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("hour", out var ph))
                hour = ph.GetUInt32();
            if (root.TryGetProperty("minute", out var pm))
                minute = pm.GetUInt32();
            if (root.TryGetProperty("transition", out var pt))
                transition = pt.GetUInt32();
            if (root.TryGetProperty("fix", out var pf) && (pf.ValueKind == JsonValueKind.True || pf.ValueKind == JsonValueKind.False))
                fix = pf.GetBoolean();
            if (hour > 23 || minute > 59)
                return new { ok = false, error = "hour must be 0..23 and minute 0..59" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };
        lock (state.SyncRoot)
        {
            state.TimeHour = hour;
            state.TimeMinute = minute;
            state.TimeFixed = fix;
            state.TimeTransitionSeconds = transition;
            state.HasExplicitTime = true;
        }
        await GameRouter.PushSessionTimeAsync(session);
        session.Log.Info($"[DEBUG-API] time set {hour:D2}:{minute:D2} fix={fix} transition={transition}s");
        return new { ok = true, hour, minute, fix };
    }

    private static async Task<string> ReadBodyAsync(HttpListenerRequest request, CancellationToken token)
    {
        if (!request.HasEntityBody)
            return string.Empty;
        using var reader = new StreamReader(request.InputStream, request.ContentEncoding);
        return await reader.ReadToEndAsync(token);
    }

    private static async Task WriteHtmlAsync(HttpListenerContext ctx, CancellationToken token)
    {
        var bytes = PanelHtml.Value;
        ctx.Response.StatusCode = 200;
        ctx.Response.ContentType = "text/html; charset=utf-8";
        ctx.Response.ContentLength64 = bytes.Length;
        await ctx.Response.OutputStream.WriteAsync(bytes, token);
        ctx.Response.Close();
    }

    private static async Task WriteJsonAsync(HttpListenerContext ctx, object payload, CancellationToken token, int status = 200)
    {
        var bytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(payload, JsonOptions));
        ctx.Response.StatusCode = status;
        ctx.Response.ContentType = "application/json; charset=utf-8";
        ctx.Response.ContentLength64 = bytes.Length;
        await ctx.Response.OutputStream.WriteAsync(bytes, token);
        ctx.Response.Close();
    }
}
