using System.Text.Json;
using System.Text.Json.Serialization;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class GameCatalog
{
    private static readonly JsonSerializerOptions Options = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
        NumberHandling = JsonNumberHandling.AllowReadingFromString,
    };

    private static readonly Lazy<Loaded> Cache = new(Load);

    private static Loaded Data => Cache.Value;

    internal static bool Available => Data.Catalog is not null;

    internal static string? Error => Data.Error;

    internal static string? Note => Data.Catalog?.Note;

    internal static IReadOnlyList<CatalogCharacter> Characters => Data.Catalog?.Characters ?? [];
    internal static IReadOnlyList<CatalogWeapon> Weapons => Data.Catalog?.Weapons ?? [];

    private static readonly Lazy<Dictionary<uint, CatalogWeapon>> WeaponByLegacy = new(() =>
        Weapons.GroupBy(w => w.TemplateId).ToDictionary(g => g.Key, g => g.First()));

    
    
    
    internal static string WeaponLabel(uint sceneitemTemplateId, uint legacyWeaponId, string? sceneitemName)
    {
        if (legacyWeaponId != 0 && WeaponByLegacy.Value.TryGetValue(legacyWeaponId, out var row))
            return Label(row.Zh, row.En);
        return sceneitemName ?? string.Empty;
    }
    internal static IReadOnlyList<CatalogFashion> Fashions => Data.Catalog?.Fashions ?? [];
    internal static IReadOnlyList<CatalogVehicle> Vehicles => Data.Catalog?.Vehicles ?? [];
    internal static IReadOnlyList<CatalogItem> Items => Data.Catalog?.Items ?? [];
    internal static IReadOnlyList<CatalogTask> Tasks => Data.Catalog?.Tasks ?? [];
    internal static IReadOnlyList<CatalogChapter> Chapters => Data.Catalog?.Chapters ?? [];
    internal static IReadOnlyList<CatalogMall> Mall => Data.Catalog?.Mall ?? [];
    internal static IReadOnlyList<CatalogVehicleType> VehicleTypes => Data.Catalog?.VehicleTypes ?? [];

    internal static IReadOnlyDictionary<string, int> Counts => Data.Catalog?.Counts ?? new Dictionary<string, int>();

    
    internal static string Label(string? zh, string? en)
        => !string.IsNullOrWhiteSpace(zh) ? zh! : (!string.IsNullOrWhiteSpace(en) ? en! : string.Empty);

    private static Loaded Load()
    {
        try
        {
            var configured = PrivateServerConfigStore.Current.Paths.ClientConfigs;
            var buildRoot = Path.GetDirectoryName(PrivateServerConfigStore.ResolveProjectPath(configured).TrimEnd('/', '\\'));
            var file = Path.Combine(buildRoot ?? ".", "Dict", "catalog.zh-CN.json");
            if (!File.Exists(file))
                return new Loaded(null, $"字典文件不存在：{file}（可运行 tools_build_catalog.py 生成）");

            using var doc = JsonDocument.Parse(File.ReadAllText(file));
            var catalog = doc.RootElement.Deserialize<CatalogFile>(Options);
            return new Loaded(catalog, null);
        }
        catch (Exception ex)
        {
            return new Loaded(null, ex.Message);
        }
    }

    private sealed record Loaded(CatalogFile? Catalog, string? Error);

    internal sealed class CatalogFile
    {
        public int Build { get; init; }
        public string? Note { get; init; }
        public Dictionary<string, int> Counts { get; init; } = new();
        public List<CatalogCharacter> Characters { get; init; } = [];
        public List<CatalogWeapon> Weapons { get; init; } = [];
        public List<CatalogFashion> Fashions { get; init; } = [];
        public List<CatalogVehicle> Vehicles { get; init; } = [];
        public List<CatalogVehicleType> VehicleTypes { get; init; } = [];
        public List<CatalogItem> Items { get; init; } = [];
        public List<CatalogTask> Tasks { get; init; } = [];
        public List<CatalogChapter> Chapters { get; init; } = [];
        public List<CatalogMall> Mall { get; init; } = [];
    }
}

internal sealed class CatalogCharacter
{
    public uint TemplateId { get; init; }
    public ulong UnitId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public uint IconId { get; init; }
}

internal sealed class CatalogWeapon
{
    public uint TemplateId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public uint Belong { get; init; }
    public int WeaponType { get; init; }
    public uint FightSkillType { get; init; }
}

internal sealed class CatalogFashion
{
    public uint FashionId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public uint SpiritId { get; init; }
    public int Part { get; init; }
    public int Quality { get; init; }
    public int Gender { get; init; }
    public bool IsDefault { get; init; }
    public bool IsShow { get; init; }
    public bool IsGet { get; init; }
}

internal sealed class CatalogVehicle
{
    public uint ConfigId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public string? Brand { get; init; }
    public string? BrandZh { get; init; }
    public int VehicleType { get; init; }
    public int Seats { get; init; }
    public int Quality { get; init; }
}

internal sealed class CatalogVehicleType
{
    public int Id { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
}

internal sealed class CatalogItem
{
    public uint TemplateId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public int SubType { get; init; }
    public int Quality { get; init; }
    public int Price { get; init; }
}

internal sealed class CatalogTask
{
    public uint TaskId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public uint Raid { get; init; }
    public uint Chapter { get; init; }
}

internal sealed class CatalogChapter
{
    public int Id { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
}

internal sealed class CatalogMall
{
    public uint CommodityId { get; init; }
    public string? En { get; init; }
    public string? Zh { get; init; }
    public uint MallId { get; init; }
    public uint BindId { get; init; }
    public uint ConsumeItemId { get; init; }
    public int Price { get; init; }
}
