using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    internal sealed class GachaDrawDetail4229938
    {
        public uint PoolContentId;
        public bool IsGrandPrize;
        public bool IsConverted;
        public bool IsNew;
    }

    
    internal sealed class SyncGachaDrawInfo4229938
    {
        [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
        public List<GachaDrawDetail4229938> drawDetails = [];

        public bool isGrandPrizeWithAllFillers;
    }

    
    private const int GachaProbabilityScale4229938 = 100000;

    [Handler(MethodId.AskDrawGacha, HandlerPacketKind.Invoke)]
    private async Task OnAskDrawGacha(Connection conn, UxRpcMessage msg)
    {
        
        await conn.ReturnEmptyOkAsync(msg);

        var state = GetWorldState(msg.Context);
        var body = msg.Body ?? [];

        
        var poolId = body.Length >= 4 ? BitConverter.ToUInt32(body, 0) : 0u;
        var drawCount = body.Length >= 8 ? BitConverter.ToUInt32(body, 4) : 0u;
        drawCount = Math.Clamp(drawCount == 0 ? 1u : drawCount, 1u, 10u);

        if (!EconomyConfigRepository.TryPool(poolId, out var pool))
        {
            conn.Log.Warn($"[GACHA] 未知奖池 {poolId}（body={Convert.ToHexString(body)}）");
            return;
        }

        var contents = EconomyConfigRepository.PoolContents(pool.Id);
        if (contents.Count == 0)
        {
            conn.Log.Warn($"[GACHA] 奖池 {pool.Id} 没有内容行，抽不出东西");
            return;
        }

        EconomyConfigRepository.GachaTierRule? tierRule = null;
        if (pool.GrandTierRuleId != 0
            && EconomyConfigRepository.TryTierRule(pool.GrandTierRuleId, out var foundRule))
            tierRule = foundRule;

        var details = new List<GachaDrawDetail4229938>((int)drawCount);
        var grants = new List<(uint TemplateId, uint Count, uint Quality, bool IsNew)>();
        var grandCount = 0;

        for (var draw = 0u; draw < drawCount; draw++)
        {
            uint drawsSinceGrand;
            lock (state.SyncRoot)
            {
                state.GachaDrawsSinceGrand.TryGetValue(pool.Id, out var previous);
                drawsSinceGrand = previous + 1;
            }

            var isGrand = RollGrandPrize4229938(tierRule, drawsSinceGrand);
            var content = PickGachaContent4229938(contents, isGrand)
                          ?? PickGachaContent4229938(contents, grandOnly: null);

            if (content is null)
            {
                lock (state.SyncRoot)
                    state.GachaDrawsSinceGrand[pool.Id] = drawsSinceGrand;
                continue;
            }

            isGrand = content.IsGrandPrize;
            lock (state.SyncRoot)
                state.GachaDrawsSinceGrand[pool.Id] = isGrand ? 0u : drawsSinceGrand;

            if (isGrand)
                grandCount++;

            var converted = false;
            var isNew = false;
            var dropId = content.DropId;
            var rolls = content.Quantity == 0 ? 1u : content.Quantity;

            if (TryPrizeTemplateId4229938(content.DropId, out var prizeTemplateId))
            {
                var owned = IsItemOwned4229938(state, prizeTemplateId);
                isNew = !owned;

                
                if (owned && content.DuplicateReturnDropId != 0 && content.DuplicateReturnCount != 0)
                {
                    converted = true;
                    dropId = content.DuplicateReturnDropId;
                    rolls = content.DuplicateReturnCount;
                }
            }

            if (dropId != 0 && EconomyConfigRepository.TryDrop(dropId, out var drop) && !drop.IsEmpty)
            {
                foreach (var (id, count) in drop.Guaranteed)
                    if (id != 0 && count != 0)
                        grants.Add((id, count * rolls, content.Quality, isNew));

                foreach (var (id, min, max) in drop.Ranged)
                {
                    if (id == 0) continue;
                    var lo = Math.Min(min, max);
                    var hi = Math.Max(min, max);
                    var count = lo == hi ? lo : (uint)Random.Shared.NextInt64(lo, hi + 1);
                    if (count != 0)
                        grants.Add((id, count * rolls, content.Quality, isNew));
                }

                if (drop.Weighted.Count > 0)
                {
                    var index = PickWeightedIndex4229938(
                        drop.Weighted.Count, i => drop.Weighted[i].Weight);
                    if (index >= 0)
                    {
                        var (id, weight) = drop.Weighted[index];
                        if (id != 0 && weight > 0)
                            grants.Add((id, rolls, content.Quality, isNew));
                    }
                }
            }
            else
            {
                conn.Log.Warn($"[GACHA] 内容行 {content.Id} 什么都不给（drop={dropId}）");
            }

            details.Add(new GachaDrawDetail4229938
            {
                PoolContentId = content.Id,
                IsGrandPrize = isGrand,
                IsConverted = converted,
                IsNew = isNew,
            });
        }

        
        var granted = await GrantGachaItemsAsync(conn, state, grants);

        if (details.Count > 0)
        {
            await conn.NotifyAsync(MethodId.IGameToClient_SyncGachaDrawInfo,
                UxSerializer.Serialize(new SyncGachaDrawInfo4229938
                {
                    drawDetails = details,
                    isGrandPrizeWithAllFillers = false,
                }));
        }

        conn.Log.Info(
            $"[GACHA] pool={pool.Id} count={drawCount} cost={pool.CostFor(drawCount)} "
            + $"grand={grandCount} 发放={granted} 明细={details.Count} "
            + $"rule={tierRule?.Id ?? 0} ruleType={tierRule?.RuleType ?? 0}");
    }

    
    
    
    
    private static bool RollGrandPrize4229938(
        EconomyConfigRepository.GachaTierRule? rule, uint drawsSinceGrand)
    {
        if (rule is null)
            return false;

        if (rule.PityThreshold > 0 && drawsSinceGrand >= rule.PityThreshold)
            return true;

        if (rule.RuleType != 1)
            return false;

        var probability = (double)rule.BaseProbability;
        if (rule.RampStartDraw > 0 && drawsSinceGrand > rule.RampStartDraw)
            probability += (double)(drawsSinceGrand - rule.RampStartDraw) * rule.ProbabilityIncrement;

        if (probability <= 0)
            return false;
        if (probability >= GachaProbabilityScale4229938)
            return true;

        return Random.Shared.Next(GachaProbabilityScale4229938) < probability;
    }

    
    
    
    private static EconomyConfigRepository.GachaContent? PickGachaContent4229938(
        IReadOnlyList<EconomyConfigRepository.GachaContent> contents, bool? grandOnly)
    {
        var candidates = new List<EconomyConfigRepository.GachaContent>();
        foreach (var content in contents)
        {
            if (content.Weight <= 0)
                continue;
            if (grandOnly is { } wanted && content.IsGrandPrize != wanted)
                continue;

            candidates.Add(content);
        }

        if (candidates.Count == 0)
            return null;

        var index = PickWeightedIndex4229938(candidates.Count, i => candidates[i].Weight);
        return index < 0 ? null : candidates[index];
    }

    
    private static bool TryPrizeTemplateId4229938(uint dropId, out uint templateId)
    {
        templateId = 0;
        if (dropId == 0 || !EconomyConfigRepository.TryDrop(dropId, out var drop))
            return false;

        if (drop.Guaranteed.Count > 0)
            templateId = drop.Guaranteed[0].Id;
        else if (drop.Ranged.Count > 0)
            templateId = drop.Ranged[0].Id;
        else if (drop.Weighted.Count > 0)
            templateId = drop.Weighted[0].Id;

        return templateId != 0;
    }

    private static bool IsItemOwned4229938(WorldEntryState state, uint templateId)
    {
        lock (state.SyncRoot)
            return state.BackpackItemCounts.TryGetValue(templateId, out var count) && count > 0;
    }

    
    private static int PickWeightedIndex4229938(int count, Func<int, double> weightAt)
    {
        var total = 0d;
        for (var i = 0; i < count; i++)
        {
            var w = weightAt(i);
            if (w > 0 && double.IsFinite(w))
                total += w;
        }

        if (total <= 0)
            return -1;

        var roll = Random.Shared.NextDouble() * total;
        for (var i = 0; i < count; i++)
        {
            var w = weightAt(i);
            if (w <= 0 || !double.IsFinite(w))
                continue;

            roll -= w;
            if (roll <= 0)
                return i;
        }

        return count - 1;
    }

    
    
    
    
    private static async Task<int> GrantGachaItemsAsync(
        Connection conn, WorldEntryState state, List<(uint TemplateId, uint Count, uint Quality, bool IsNew)> grants)
    {
        if (grants.Count == 0)
            return 0;

        var merged = new Dictionary<uint, uint>();
        foreach (var (templateId, count, _, _) in grants)
        {
            if (templateId == 0 || count == 0)
                continue;
            merged[templateId] = merged.TryGetValue(templateId, out var have) ? have + count : count;
        }

        if (merged.Count == 0)
            return 0;

        var update = new GameMethods.SyncBackpackItemChanged4229938();
        foreach (var (templateId, addCount) in merged)
        {
            uint next;
            lock (state.SyncRoot)
            {
                state.BackpackItemCounts.TryGetValue(templateId, out var current);
                next = current + addCount;
                state.BackpackItemCounts[templateId] = next;
            }

            update.updateItemList.Add(RuntimePayloadFactory.BackpackItem4229938(templateId, next));
        }

        await conn.NotifyAsync(MethodId.SyncBackpackItemChanged, UxSerializer.Serialize(update));
        return merged.Count;
    }
}
