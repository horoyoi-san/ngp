using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

/// <summary>
/// English display names for items. SceneitemConfig carries the Chinese Name plus
/// __IDX__Name, which is the TranslationENConfig record id (verified: 142516 =
/// "Void Claw"). Falls back to the raw Name when no translation exists.
/// </summary>
internal static class WeaponNameTranslator4229938
{
    private static readonly Lazy<Dictionary<uint, string>> EnById = new(LoadEnglish);
    private static readonly Lazy<Dictionary<uint, uint>> IdxByOldWeaponId = new(LoadIdx);

    internal static string EnglishFor(uint oldWeaponId, string fallback)
    {
        try
        {
            if (oldWeaponId != 0
                && IdxByOldWeaponId.Value.TryGetValue(oldWeaponId, out var textId)
                && textId != 0
                && EnById.Value.TryGetValue(textId, out var en)
                && !string.IsNullOrWhiteSpace(en))
                return en;
        }
        catch
        {
            // Translation data is best-effort; never break gameplay.
        }
        return fallback;
    }

    private static string ClientConfigsRoot()
        => PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);

    private static Dictionary<uint, string> LoadEnglish()
    {
        var result = new Dictionary<uint, string>();
        using var doc = JsonDocument.Parse(File.ReadAllText(Path.Combine(ClientConfigsRoot(), "TranslationENConfig.json")));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            return result;
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var id) || !id.TryGetUInt32(out var textId) || textId == 0)
                continue;
            if (row.TryGetProperty("Text", out var text) && text.ValueKind == JsonValueKind.String)
            {
                var value = text.GetString();
                if (!string.IsNullOrWhiteSpace(value))
                    result[textId] = value;
            }
        }
        return result;
    }

    private static Dictionary<uint, uint> LoadIdx()
    {
        var result = new Dictionary<uint, uint>();
        using var doc = JsonDocument.Parse(File.ReadAllText(Path.Combine(ClientConfigsRoot(), "SceneitemConfig.json")));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            return result;
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("OldWeaponId", out var oldId) || !oldId.TryGetUInt32(out var weaponId) || weaponId == 0)
                continue;
            if (row.TryGetProperty("__IDX__Name", out var idx) && idx.TryGetUInt32(out var textId) && textId != 0
                && textId != 4294967293u)
                result[weaponId] = textId;
        }
        return result;
    }
}
