using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record AmbientVehicleSpawn(
    int SpawnId,
    uint VehicleId,
    uint DriverNpcType,
    uint PassengerNpcType,
    bool HasPassenger,
    bool InMass,
    uint[] ColorMods);

internal static class VehicleSpawnCatalog
{
    private static readonly Lazy<IReadOnlyList<AmbientVehicleSpawn>> Cache = new(Load);

    
    internal static IReadOnlyList<AmbientVehicleSpawn> Ambient => Cache.Value;

    internal static int Count => Cache.Value.Count;

    private static IReadOnlyList<AmbientVehicleSpawn> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(
            PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "VehicleSpawnConfig.json");
        if (!File.Exists(path))
            throw new InvalidDataException($"VehicleSpawnConfig 不存在: {path}");

        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records)
            || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"VehicleSpawnConfig 没有 records: {path}");

        var list = new List<AmbientVehicleSpawn>();
        foreach (var row in records.EnumerateArray())
        {
            static uint[] UInts(JsonElement row, string name)
            {
                if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
                    return [];
                var buf = new List<uint>();
                foreach (var e in node.EnumerateArray())
                    if (e.TryGetUInt32(out var v)) buf.Add(v);
                return [.. buf];
            }

            var spawnId = row.TryGetProperty("Id", out var idNode) && idNode.TryGetInt32(out var id) ? id : 0;
            var vehicleId = row.TryGetProperty("VehicleId", out var vNode) && vNode.TryGetUInt32(out var vid) ? vid : 0u;
            if (vehicleId == 0)
                continue;

            var inMass = row.TryGetProperty("InMass", out var mNode)
                         && mNode.ValueKind == JsonValueKind.True;
            if (!inMass)
                continue;

            var driverTypes = UInts(row, "NewNpcType");
            var passengerTypes = UInts(row, "NewPassengerType");
            var hasPassenger = row.TryGetProperty("HasPassenger", out var hpNode)
                               && hpNode.TryGetInt32(out var hp) && hp != 0;

            list.Add(new AmbientVehicleSpawn(
                spawnId,
                vehicleId,
                driverTypes.Length > 0 ? driverTypes[0] : 0u,
                passengerTypes.Length > 0 ? passengerTypes[0] : 0u,
                hasPassenger,
                true,
                UInts(row, "ColorMod")));
        }

        if (list.Count == 0)
            throw new InvalidDataException(
                $"VehicleSpawnConfig 里没有 InMass=true 的条目: {path}");

        return list;
    }
}
