using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Admin weapon grant: push SyncArmoryAddWeapon for any account-catalog weapon by
/// template id. Instance ids are deterministic (accountInstanceByTemplate), so the
/// existing AskLoadWeaponToSlot wheel flow picks the granted weapon up with no
/// further server work — equip happens in-game via the armory UI.
/// </summary>
internal sealed partial class GameRouter
{
    internal static async Task<(bool Ok, string Message)> GrantWeaponAsync(TcpSession session, uint templateId)
    {
        var def = CombatCatalogRepository.AccountWeapons.FirstOrDefault(w => w.TemplateId == templateId);
        if (def is null)
            return (false, $"weapon template {templateId} is not in the account armory catalog");
        try
        {
            await session.NotifyAsync(MethodId.SyncArmoryAddWeapon,
                UxSerializer.Serialize(RuntimePayloadFactory.WeaponData(def)), CancellationToken.None);
            session.Log.Info($"[WEAPON] grant template={templateId} name={def.Name} instance={def.InstanceId}");
            return (true, $"granted {def.Name} (template {templateId}, instance {def.InstanceId}) — equip it from the armory/weapon wheel in game");
        }
        catch (Exception ex)
        {
            return (false, $"grant failed: {ex.Message}");
        }
    }

    internal static IReadOnlyList<(uint TemplateId, string Name, ulong InstanceId)> WeaponCatalog()
        => CombatCatalogRepository.AccountWeapons
            .OrderBy(w => w.TemplateId)
            .Select(w => (w.TemplateId, w.Name, w.InstanceId))
            .ToList();
}
