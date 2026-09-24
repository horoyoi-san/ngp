using Ananta.Server.Protocol.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.ClientData.Client4229938;

internal static class CombatCatalogResolver
{
    internal static Task<Auto.WeaponData> WeaponDataAsync(uint templateId, uint spiritId)
        => Task.FromResult(WeaponData(templateId, spiritId));

    internal static Auto.WeaponData WeaponData(uint templateId, uint spiritId)
    {
        var authored = CombatCatalogRepository.AccountWeapons
            .Where(w => w.TemplateId == templateId)
            .OrderBy(w => w.SpiritTemplateId == spiritId ? 0 : 1)
            .FirstOrDefault();

        if (authored is not null)
            return RuntimePayloadFactory.WeaponData(authored);

        var styleId = StyleFor(templateId);
        return new Auto.WeaponData
        {
            TemplateId = templateId,
            Durability = -1,
            InstanceId = 0,
            EventId = 0,
            ReceivedTimeStamp = 0,
            OperatorFlags = 0,
            SpecialLabel = null,
            WeaponFlags = new Auto.WeaponDataFlags(),
            SceneItemHp = 1f,
            StackCount = 1,
            BulletDatas = new Auto.WeaponBulletDatas { BulletId = 0 },
            Decorations = [],
            FightStyleId = styleId,
            MagazineAmmo = 0,
            BindPid = 0,
            IsPlayerLocked = false,
            EnchantSlots = [],
            NonDirectionalEnchantCount = 0,
            DirectionalEnchantCountSinceLastNonDir = 0,
            LockedDirectionalEnhancementId = 0,
        };
    }

    
    private static uint StyleFor(uint templateId)
    {
        var entry = GameCatalog.Weapons.FirstOrDefault(w => w.TemplateId == templateId);
        if (entry is null || entry.FightSkillType == 0)
            return 0;

        foreach (var styleId in CombatCatalogRepository.UnlockedStyleIds)
        {
            var style = CombatCatalogRepository.Style(styleId);
            if (style is not null && style.FightSkillTypeId == entry.FightSkillType)
                return style.Id;
        }
        return 0;
    }
}
