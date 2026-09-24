using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record VehicleCatalogEntry4229938(uint Id, string Name, string Model, int SeatCount, string SpoonName);

internal static class VehicleCatalog4229938
{
    private static readonly Lazy<Dictionary<uint, VehicleCatalogEntry4229938>> Cache = new(Load);

    internal static bool TryGet(uint id, out VehicleCatalogEntry4229938 entry)
        => Cache.Value.TryGetValue(id, out entry!);

    
    internal static IReadOnlyList<VehicleCatalogEntry4229938> AllSummonable => Cache.Value.Values
        .Where(v => !string.IsNullOrWhiteSpace(v.Model) && v.SeatCount is >= 1 and <= 16)
        .OrderBy(v => v.Id)
        .ToArray();

    
    
    
    
    
    
    
    
    
    
    internal static IReadOnlyList<uint> PoliceVehicleIds
    {
        get
        {
            var keywords = new[] { "patrol", "ncca", "police" };
            return [.. Cache.Value.Values
                .Where(v => !string.IsNullOrWhiteSpace(v.Model) && v.SeatCount is >= 1 and <= 16)
                .Where(v => keywords.Any(k => v.Name.Contains(k, StringComparison.OrdinalIgnoreCase)))
                .OrderBy(v => v.Name.Contains("patrol", StringComparison.OrdinalIgnoreCase) ? 0 : 1)
                .ThenBy(v => v.Id)
                .Select(v => v.Id)];
        }
    }

    private static Dictionary<uint, VehicleCatalogEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "VehicleConfig.json");
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"VehicleConfig does not contain records: {path}");
        var result = new Dictionary<uint, VehicleCatalogEntry4229938>();
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;
            static string Str(JsonElement row, string name)
                => row.TryGetProperty(name, out var n) && n.ValueKind == JsonValueKind.String ? n.GetString() ?? string.Empty : string.Empty;
            var seats = row.TryGetProperty("VehicleSeatNum", out var s) && s.TryGetInt32(out var seatCount) ? seatCount : 0;
            result[id] = new VehicleCatalogEntry4229938(id, Str(row, "VehicleName"), Str(row, "GeneralModel"), seats, Str(row, "VehicleSpoonName"));
        }
        return result;
    }
}
