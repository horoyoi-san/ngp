using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class EconomyConfigRepository
{
    private static readonly Lazy<Data> Cache = new(Load);

    
    internal static void Warmup()
        => _ = Cache.Value;

    internal static bool TryMallCommodity(uint id, out MallCommodity commodity)
        => Cache.Value.Mall.TryGetValue(id, out commodity!);

    internal static bool TryDrop(uint id, out DropRow drop)
        => Cache.Value.Drops.TryGetValue(id, out drop!);

    internal static bool TryPool(uint id, out GachaPool pool)
        => Cache.Value.Pools.TryGetValue(id, out pool!);

    internal static bool TryTierRule(uint id, out GachaTierRule rule)
        => Cache.Value.TierRules.TryGetValue(id, out rule!);

    internal static IReadOnlyList<GachaContent> PoolContents(uint poolId)
        => Cache.Value.ContentsByPool.TryGetValue(poolId, out var contents) ? contents : [];

    
    internal sealed record MallCommodity(
        uint Id,
        uint MallId,
        uint Type,
        uint BindId,
        uint ConsumeItemId,
        double Price,
        double DiscountPrice,
        uint DropId,
        uint LimitNum,
        IReadOnlyList<uint> CommodityBindIds)
    {
        internal double UnitPrice => DiscountPrice > 0 ? DiscountPrice : Price;
    }

    
    
    
    
    
    internal sealed record DropRow(
        uint Id,
        double Money,
        double BindingGold,
        IReadOnlyList<(uint Id, uint Count)> Guaranteed,
        IReadOnlyList<(uint Id, uint Min, uint Max)> Ranged,
        IReadOnlyList<(uint Id, double Weight)> Weighted)
    {
        internal bool IsEmpty => Guaranteed.Count == 0 && Ranged.Count == 0 && Weighted.Count == 0
                                 && Money == 0 && BindingGold == 0;
    }

    internal sealed record GachaPool(
        uint Id,
        bool IsDrop,
        uint MoneyId,
        uint CommodityId,
        uint GrandTierRuleId,
        IReadOnlyList<(uint DrawCount, uint Cost)> Costs)
    {
        
        internal double CostFor(uint drawCount)
        {
            foreach (var (count, cost) in Costs)
            {
                if (count == drawCount)
                    return cost;
            }

            foreach (var (count, cost) in Costs)
            {
                if (count == 1)
                    return cost * drawCount;
            }

            return Costs.Count > 0 ? Costs[0].Cost : 0;
        }
    }

    internal sealed record GachaContent(
        uint Id,
        uint PoolId,
        uint TierRarity,
        uint DropId,
        double Weight,
        uint Quantity,
        uint Quality,
        uint DuplicateReturnDropId,
        uint DuplicateReturnCount)
    {
        
        internal bool IsGrandPrize => TierRarity >= 4 || Quality >= 5;
    }

    
    
    
    
    
    
    
    internal sealed record GachaTierRule(
        uint Id,
        uint RuleType,
        uint PityThreshold,
        uint RampStartDraw,
        uint BaseProbability,
        uint ProbabilityIncrement,
        IReadOnlyList<uint> GrandPrizeProbability);

    private sealed class Data
    {
        internal Dictionary<uint, MallCommodity> Mall { get; init; } = [];
        internal Dictionary<uint, DropRow> Drops { get; init; } = [];
        internal Dictionary<uint, GachaPool> Pools { get; init; } = [];
        internal Dictionary<uint, GachaTierRule> TierRules { get; init; } = [];
        internal Dictionary<uint, List<GachaContent>> ContentsByPool { get; init; } = [];
    }

    private static Data Load()
    {
        var cfg = PrivateServerConfigStore.Current;
        var root = PrivateServerConfigStore.ResolveProjectPath(cfg.Paths.ClientConfigs);
        var warnings = new List<string>();

        var mall = new Dictionary<uint, MallCommodity>();
        foreach (var row in ReadRecords(Path.Combine(root, "MallCommodityConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "BelongMallId", out var mallId);
            TryUInt32(row, "Type", out var type);
            TryUInt32(row, "BindId", out var bindId);
            TryUInt32(row, "ConsumeItemId", out var consumeItemId);
            TryDouble(row, "Price", out var price);
            TryDouble(row, "DiscountPrice", out var discountPrice);
            TryUInt32(row, "DropId", out var dropId);
            TryUInt32(row, "LimitNum", out var limitNum);

            mall[id] = new MallCommodity(
                id, mallId, type, bindId, consumeItemId, price, discountPrice, dropId, limitNum,
                ReadUInt32Array(row, "CommodityBindId"));
        }

        var drops = new Dictionary<uint, DropRow>();
        foreach (var row in ReadRecords(Path.Combine(root, "DropConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryDouble(row, "Money", out var money);
            TryDouble(row, "BindingGold", out var bindingGold);

            drops[id] = new DropRow(
                id, money, bindingGold, ReadItemList(row, "Item1"), ReadItemRangeList(row, "Item2"),
                ReadItemWeightList(row, "Item3"));
        }

        var pools = new Dictionary<uint, GachaPool>();
        foreach (var row in ReadRecords(Path.Combine(root, "GachaPoolConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "MoneyId", out var moneyId);
            TryUInt32(row, "CommodityId", out var commodityId);
            TryUInt32(row, "SS_TierRuleId", out var grandTierRuleId);

            pools[id] = new GachaPool(
                id, ReadBool(row, "isDrop"), moneyId, commodityId, grandTierRuleId, ReadCostList(row, "CostCount"));
        }

        var tierRules = new Dictionary<uint, GachaTierRule>();
        foreach (var row in ReadRecords(Path.Combine(root, "GachaPoolTierRuleConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "RuleType", out var ruleType);
            TryUInt32(row, "PityThreshold", out var pityThreshold);
            TryUInt32(row, "RampStartDraw", out var rampStartDraw);
            TryUInt32(row, "BaseProbability", out var baseProbability);
            TryUInt32(row, "ProbabilityIncrement", out var probabilityIncrement);
            tierRules[id] = new GachaTierRule(
                id, ruleType, pityThreshold, rampStartDraw, baseProbability, probabilityIncrement,
                ReadUInt32Array(row, "GrandPrizeProbability"));
        }

        var contentsByPool = new Dictionary<uint, List<GachaContent>>();
        foreach (var row in ReadRecords(Path.Combine(root, "GachaPoolContentConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;
            if (!TryUInt32(row, "PoolId", out var poolId) || poolId == 0)
                continue;

            TryUInt32(row, "PoolTierRarity", out var tierRarity);
            TryUInt32(row, "dropId", out var dropId);
            TryDouble(row, "weight", out var weight);
            TryUInt32(row, "Quantity", out var quantity);
            TryUInt32(row, "Quality", out var quality);
            TryUInt32(row, "duplicateReturnDropId", out var duplicateDropId);
            TryUInt32(row, "duplicateReturnCount", out var duplicateCount);

            if (!contentsByPool.TryGetValue(poolId, out var list))
            {
                list = [];
                contentsByPool[poolId] = list;
            }

            list.Add(new GachaContent(
                id, poolId, tierRarity, dropId, weight < 0 ? 0 : weight, quantity, quality,
                duplicateDropId, duplicateCount));
        }

        foreach (var message in warnings)
            Console.WriteLine($"[ECONOMY] {message}");

        Console.WriteLine(
            $"[ECONOMY] mall={mall.Count} drops={drops.Count} pools={pools.Count} " +
            $"gachaContents={contentsByPool.Values.Sum(x => x.Count)} tierRules={tierRules.Count} source={root}");

        return new Data
        {
            Mall = mall,
            Drops = drops,
            Pools = pools,
            TierRules = tierRules,
            ContentsByPool = contentsByPool,
        };
    }

    private static JsonElement[] ReadRecords(string path, List<string> warnings)
    {
        if (!File.Exists(path))
        {
            warnings.Add($"optional client config is missing: {path}");
            return [];
        }

        try
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            {
                warnings.Add($"client config has no 'records' array: {path}");
                return [];
            }

            return records.EnumerateArray().Select(x => x.Clone()).ToArray();
        }
        catch (Exception ex)
        {
            warnings.Add($"client config failed to parse ({ex.GetType().Name}: {ex.Message}): {path}");
            return [];
        }
    }

    
    private static bool TryProperty(JsonElement row, string name, out JsonElement value)
    {
        if (row.TryGetProperty(name, out value))
            return true;

        foreach (var property in row.EnumerateObject())
        {
            if (property.Name.AsSpan()[(property.Name.LastIndexOf('.') + 1)..].SequenceEqual(name))
            {
                value = property.Value;
                return true;
            }
        }

        value = default;
        return false;
    }

    private static bool TryUInt32(JsonElement row, string name, out uint result)
    {
        result = 0;
        return TryProperty(row, name, out var value) && value.TryGetUInt32(out result);
    }

    private static bool TryDouble(JsonElement row, string name, out double result)
    {
        result = 0;
        return TryProperty(row, name, out var value) && value.TryGetDouble(out result);
    }

    private static bool ReadBool(JsonElement row, string name)
        => TryProperty(row, name, out var value) && value.ValueKind == JsonValueKind.True;

    private static IReadOnlyList<uint> ReadUInt32Array(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        return value.EnumerateArray()
            .Where(x => x.TryGetUInt32(out _))
            .Select(x => x.GetUInt32())
            .ToArray();
    }

    
    private static IReadOnlyList<(uint Id, uint Count)> ReadItemList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, uint)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "id1", out var id) || id == 0)
                continue;

            TryUInt32(entry, "count", out var count);
            result.Add((id, count == 0 ? 1u : count));
        }

        return result;
    }

    
    private static IReadOnlyList<(uint Id, uint Min, uint Max)> ReadItemRangeList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, uint, uint)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "id2", out var id) || id == 0)
                continue;

            TryUInt32(entry, "min", out var min);
            TryUInt32(entry, "max", out var max);
            if (max < min)
                max = min;
            result.Add((id, min, max));
        }

        return result;
    }

    
    private static IReadOnlyList<(uint Id, double Weight)> ReadItemWeightList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, double)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "id3", out var id) || id == 0)
                continue;

            TryDouble(entry, "count", out var weight);
            if (weight <= 0)
                continue;
            result.Add((id, weight));
        }

        return result;
    }

    
    private static IReadOnlyList<(uint DrawCount, uint Cost)> ReadCostList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, uint)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "drawCount", out var drawCount) || drawCount == 0)
                continue;

            TryUInt32(entry, "cost", out var cost);
            result.Add((drawCount, cost));
        }

        return result;
    }
}
