using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    
    
    
    private static readonly HashSet<uint> GrantedWeaponTemplates = [];
    private static readonly object GrantSync = new();

    private static void ResetGrantState()
    {
        lock (GrantSync)
        {
            GrantedWeaponTemplates.Clear();
        }
    }

    

    
    internal static async Task<string> SetMoneyAsync(TcpSession session, double money, double gold, double bindingGold, CancellationToken token = default)
    {
        var body = new GameMethods.SyncMoney4229938 { money = money, gold = gold, bindingGold = bindingGold };
        await session.NotifyAsync(MethodId.SyncMoney, UxSerializer.Serialize(body), token);
        session.Log.Info($"[ECONOMY] SyncMoney money={money} gold={gold} bindingGold={bindingGold}");
        return $"money={money} gold={gold} bindingGold={bindingGold}";
    }

    

    
    
    
    
    
    
    
    
    internal static async Task<string> GrantItemAsync(TcpSession session, uint templateId, uint count, CancellationToken token = default)
    {
        if (templateId == 0)
            return "templateId must not be zero";
        if (count == 0)
            return "count must not be zero";

        var hadBefore = SessionState.Current.Backpack.TryGetValue(templateId, out var existing);
        var total = (hadBefore ? existing : 0u) + count;
        SessionState.Update(saved => saved.Backpack[templateId] = total);

        var uniqueId = RuntimePayloadFactory.BackpackItemUniqueId(templateId);
        var body = new GameMethods.SyncBackpackItemChanged4229938();
        if (hadBefore)
            body.updateItemList.Add(RuntimePayloadFactory.PackItem(templateId, total, uniqueId));
        else
            body.addItemList.Add(RuntimePayloadFactory.PackItem(templateId, total, uniqueId));

        await session.NotifyAsync(MethodId.SyncBackpackItemChanged, UxSerializer.Serialize(body), token);
        var message = hadBefore ? $"updated item {templateId} -> {total}" : $"added item {templateId} x{count}";
        session.Log.Info($"[ECONOMY] SyncBackpackItemChanged {message} (saved)");
        return message;
    }

    
    
    
    
    
    
    internal static async Task<string> RemoveItemAsync(
        TcpSession session,
        uint templateId,
        uint count = 0,
        bool all = false,
        CancellationToken token = default)
    {
        if (templateId == 0)
            return "templateId must not be zero";

        var existing = SessionState.Current.Backpack.TryGetValue(templateId, out var have) ? have : 0u;
        if (existing == 0)
            return $"item {templateId} is not in the backpack";

        var remove = all || count == 0 ? existing : Math.Min(existing, count);
        var remaining = existing - remove;
        SessionState.Update(saved =>
        {
            if (remaining == 0)
                saved.Backpack.Remove(templateId);
            else
                saved.Backpack[templateId] = remaining;
        });

        var uniqueId = RuntimePayloadFactory.BackpackItemUniqueId(templateId);
        var body = new GameMethods.SyncBackpackItemChanged4229938();
        if (remaining == 0)
            body.deleteItemList.Add(RuntimePayloadFactory.PackItem(templateId, 0, uniqueId));
        else
            body.updateItemList.Add(RuntimePayloadFactory.PackItem(templateId, remaining, uniqueId));

        await session.NotifyAsync(MethodId.SyncBackpackItemChanged, UxSerializer.Serialize(body), token);
        var message = remaining == 0
            ? $"removed item {templateId} (was {existing})"
            : $"item {templateId} {existing} -> {remaining}";
        session.Log.Info($"[ECONOMY] SyncBackpackItemChanged {message} (saved)");
        return message;
    }

    
    internal static async Task<int> GrantItemsAsync(TcpSession session, IEnumerable<(uint TemplateId, uint Count)> items, CancellationToken token = default)
    {
        var granted = 0;
        foreach (var (templateId, count) in items)
        {
            if (templateId == 0 || count == 0)
                continue;
            await GrantItemAsync(session, templateId, count, token);
            granted++;
        }
        session.Log.Info($"[ECONOMY] 批量发放物品 {granted} 种");
        return granted;
    }

    

    
    internal static async Task<string> GrantWeaponAsync(TcpSession session, uint templateId, CancellationToken token = default)
    {
        if (templateId == 0)
            return "templateId must not be zero";

        var definition = CombatCatalogRepository.AccountWeaponByTemplate(templateId);
        if (definition is null)
            return $"weapon template {templateId} is not in the armory catalog (SceneitemConfig)";

        lock (GrantSync)
        {
            if (!GrantedWeaponTemplates.Add(templateId))
                return $"weapon {templateId} already granted this session";
        }

        var body = new GameMethods.SyncArmoryAddWeapon4229938
        {
            weapon = RuntimePayloadFactory.WeaponData(definition),
        };
        await session.NotifyAsync(MethodId.SyncArmoryAddWeapon, UxSerializer.Serialize(body), token);

        session.Log.Info($"[ECONOMY] SyncArmoryAddWeapon template={templateId} instance={definition.InstanceId} name='{definition.Name}' style={definition.Style.Id}");
        return $"granted weapon {templateId} ({definition.Name}) instance={definition.InstanceId}";
    }

    
    internal static async Task<string> GrantAllWeaponsAsync(TcpSession session, CancellationToken token = default)
    {
        var granted = 0;
        var skipped = 0;
        foreach (var definition in CombatCatalogRepository.AccountWeapons)
        {
            lock (GrantSync)
            {
                if (!GrantedWeaponTemplates.Add(definition.TemplateId))
                {
                    skipped++;
                    continue;
                }
            }

            var body = new GameMethods.SyncArmoryAddWeapon4229938
            {
                weapon = RuntimePayloadFactory.WeaponData(definition),
            };
            await session.NotifyAsync(MethodId.SyncArmoryAddWeapon, UxSerializer.Serialize(body), token);
            granted++;
        }

        session.Log.Info($"[ECONOMY] SyncArmoryAddWeapon bulk granted={granted} skipped={skipped} catalog={CombatCatalogRepository.AccountWeapons.Count}");
        return $"granted {granted} weapons (already granted: {skipped})";
    }

    
    internal static async Task<string> GrantWeaponsAsync(TcpSession session, IReadOnlyList<uint> templateIds, CancellationToken token = default)
    {
        var granted = 0;
        var skipped = 0;
        foreach (var templateId in templateIds)
        {
            var message = await GrantWeaponAsync(session, templateId, token);
            if (message.StartsWith("granted", StringComparison.Ordinal)) granted++;
            else skipped++;
        }
        return $"granted {granted} weapons (skipped: {skipped})";
    }

    
    internal static IReadOnlyList<uint> ArmoryTemplateIds(bool onlyCurrentSpirit, uint spiritId)
        => CombatCatalogRepository.ArmoryWeapons
            .Where(w => !onlyCurrentSpirit || w.OwnerSpiritId == 0 || w.OwnerSpiritId == spiritId)
            .Select(w => w.TemplateId)
            .Distinct()
            .OrderBy(x => x)
            .ToList();

    

    
    
    
    
    
    internal static string PersistFashionIds(TcpSession session, IEnumerable<uint> addIds)
    {
        var added = addIds.Where(x => x != 0).Distinct().ToArray();
        if (added.Length == 0)
            return "nothing to persist";

        try
        {
            var path = PrivateServerConfigStore.ConfigPath;
            var node = System.Text.Json.Nodes.JsonNode.Parse(File.ReadAllText(path));
            if (node?["gameplay"]?["fashions"] is not System.Text.Json.Nodes.JsonObject fashions)
                return "persist=failed (no gameplay.fashions)";

            var current = (fashions["unlockedFashionIds"] as System.Text.Json.Nodes.JsonArray ?? [])
                .Select(x => x?.GetValue<uint>() ?? 0)
                .Where(x => x != 0)
                .ToList();

            var next = current.Concat(added).Distinct().OrderBy(x => x).ToArray();
            fashions["unlockedFashionIds"] = new System.Text.Json.Nodes.JsonArray(
                next.Select(x => System.Text.Json.Nodes.JsonValue.Create(x)).ToArray());

            File.WriteAllText(path, node.ToJsonString(new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
            return $"persisted fashions={next.Length}";
        }
        catch (Exception ex)
        {
            session.Log.Warn($"[PERSIST] fashions failed: {ex.Message}");
            return "persist=failed (see log)";
        }
    }

    
    internal static async Task<string> GrantFashionsAsync(TcpSession session, IReadOnlyList<uint> fashionIds, CancellationToken token = default)
    {
        var ids = fashionIds.Where(x => x != 0).Distinct().ToList();
        if (ids.Count == 0)
            return "no fashion ids";

        var body = new GameMethods.SyncAddFashionList4229938();
        foreach (var id in ids)
            body.fashionInfoList.Add(FashionInfoWire(id));

        await session.NotifyAsync(MethodId.SyncAddFashionList, UxSerializer.Serialize(body), token);
        var persisted = PersistFashionIds(session, ids);
        session.Log.Info($"[FASHION] 发放时装 {ids.Count} 件 | {persisted}");
        return $"granted {ids.Count} fashions | {persisted}";
    }

    
    internal static IReadOnlyList<uint> AmmoTemplateIds()
        => CombatCatalogRepository.AmmoTemplateIds.ToList();
}
