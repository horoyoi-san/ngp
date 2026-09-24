using Ananta.SDK.Rpc;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{

    async Task PublishSkillBindings(
        RpcContext ctx,
        ulong unitId,
        CombatWeaponDefinition weapon,
        CombatStyleDefinition style)
    {
        await ctx.NotifyAsync(MethodId.SyncChangeCommonSkill, CombatCodec.CommonBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeHeavyAttack, CombatCodec.HeavyAttackBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeDodgeSkill, CombatCodec.DodgeBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeControlSkill, CombatCodec.ControlBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeActiveSkill, CombatCodec.ActiveBinding(unitId, weapon, style));
        await ctx.NotifyAsync(MethodId.SyncChangeUniqueSkill, CombatCodec.UniqueBinding(unitId, weapon, style));
    }

    async Task PublishCombatResources(RpcContext ctx, ulong unitId)
    {
        foreach (var (resourceId, maximum) in CombatCodec.AllResourceMaximums)
        {
            await ctx.NotifyAsync(MethodId.SyncFightResource,
                CombatCodec.FightResource(unitId, resourceId, maximum));
            await ctx.NotifyAsync(MethodId.SyncFightResourceFreeState,
                CombatCodec.FightResourceFreeState(unitId, resourceId, true));
        }
    }

    private static IEnumerable<KeyValuePair<uint, uint>> SpiritFightStyleOverrides(
        WorldEntryState state,
        uint templateId)
        => state.SpiritStyleOverrides
            .Where(x => x.Key.SpiritId == templateId)
            .Select(x => new KeyValuePair<uint, uint>(x.Key.FightStyleTypeId, x.Value));

    private static uint PublishedWeaponFightStyleId(WorldEntryState state, CombatWeaponDefinition weapon)
    {
        
        
        
        
        return ResolveWeaponStyle(state, weapon).Id;
    }

    async Task PublishMinimalActorPresentation4229938(
        RpcContext ctx,
        ulong unitId,
        uint templateId,
        string reason)
    {
        var state = GetWorldState(ctx);
        var weapon = CombatCodec.DefaultWeapon(templateId);
        var style = ResolveWeaponStyle(state, weapon);

        state.ActiveWeaponInstanceId = weapon.InstanceId;
        state.ActiveFightStyleId = style.Id;
        state.LastWeaponBySpirit[templateId] = weapon.InstanceId;

        
        
        
        await ctx.NotifyAsync(MethodId.SyncSetSpiritFashions,
            RuntimePayloadFactory.CharacterFashions(templateId));
        await PublishWeaponSnapshot(ctx, unitId, templateId, weapon.InstanceId);
        await ctx.NotifyAsync(MethodId.SyncSpiritLastUsedWeapon,
            CombatCodec.SpiritLastUsedWeapon(templateId, weapon.InstanceId));
        await ctx.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction,
            CombatCodec.SpiritSwitchWeapon(unitId, weapon.InstanceId));

        ctx.Session.Log.Info($"[ACTOR-MIN] presentation unit={unitId} template={templateId} weapon={weapon.TemplateId}/{weapon.InstanceId} style={style.Id} reason={reason} combatModules=false skills=false");
    }

    async Task PublishWeaponSnapshot(
        RpcContext ctx,
        ulong unitId,
        uint templateId,
        ulong currentWeaponInstanceId)
    {
        
        
        
        
        var state = GetWorldState(ctx);
        if (!state.AccountArmoryPublished)
        {
            
            
            
            state.AccountArmoryPublished = true;
            var actorArmoryCount = ClientConfigRepository.Characters()
                .SelectMany(character => CombatCodec.Loadout(character.TemplateId).Slots)
                .Where(weapon => weapon is not null && weapon.InstanceId != 0)
                .Select(weapon => weapon!.InstanceId)
                .Distinct()
                .Count();
            ctx.Session.Log.Info($"[ARMORY-MIN] retained login actor-reference subset count={actorArmoryCount} fullAccount={CombatCatalogRepository.AccountWeapons.Count} incrementalAddReplay=false");
        }

        var snapshot = CombatCodec.SpiritWeaponSnapshot(
            unitId,
            templateId,
            currentWeaponInstanceId,
            WeaponSlotDefinitions(state, templateId));
        foreach (var weapon in snapshot.WeaponSlots)
        {
            if (weapon is null)
                continue;
            if (CombatCodec.Weapon(templateId, weapon.InstanceId) is { } definition)
            {
                weapon.FightStyleId = PublishedWeaponFightStyleId(state, definition);
                weapon.MagazineAmmo = EnsureMagazine4229938(state, definition);
                weapon.Durability = CurrentDurability4229938(state, definition, weapon.MagazineAmmo);
                weapon.BulletDatas.BulletId = EnsureBullet4229938(state, definition);
                if (definition.SeparateBullets && weapon.BulletDatas.BulletId != 0)
                    _ = EnsureReserve4229938(state, weapon.BulletDatas.BulletId);
            }
        }
        await ctx.NotifyAsync(MethodId.SyncSpiritWeaponDetail, snapshot);
        
        
        
        foreach (var detail in snapshot.WeaponSlots.Where(x => x is not null).Select(x => x!))
        {
            await ctx.NotifyAsync(MethodId.SyncWeaponFightStyleChange,
                new GameMethods.SyncWeaponFightStyleChange
                {
                    weaponInstanceId = detail.InstanceId,
                    fightStyleId = detail.FightStyleId
                });
        }

        
        
        
        
        
        
        
        
        
        foreach (var stateId in TransientHudStateIds)
            await ctx.NotifyAsync(MethodId.SyncRemoveUnitState,
                WorldCodec.RemoveUnitState(unitId, stateId));
    }

    
    
    
    
    
    private static readonly uint[] TransientHudStateIds = [3, 4, 5, 6, 9, 18, 22, 23, 27];

    async Task PublishSafeRuntimeBuffSnapshot4229938(RpcContext ctx, ulong unitId, uint templateId, string phase)
    {
        var state = GetWorldState(ctx);
        var buffs = WebTraversal.CapabilityBuffIds(templateId);
        var firstInstanceId = state.NextBuffInstanceId;
        await ctx.NotifyAsync(MethodId.SyncUnitBuffList,
            WorldCodec.UnitBuffList(unitId, buffs, firstInstanceId));
        state.NextBuffInstanceId += (uint)buffs.Count;

        
        
        
        
        ctx.Session.Log.Info($"[BUFFS-MIN] {phase} unit={unitId} template={templateId} count={buffs.Count} firstInstance={firstInstanceId} bulk=false safeWebOnly=true legacyCatalogLoaded=false");
    }

    async Task PublishInitialCapabilityBuffs(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.InitialCapabilityBuffsPublished)
            return;

        state.InitialCapabilityBuffsPublished = true;

        
        
        
        
        
        
        
        var buffs = WebTraversal.CapabilityBuffIds(Profile.InitialSpiritTemplateId);
        var firstInstanceId = state.NextBuffInstanceId;
        await ctx.NotifyAsync(MethodId.SyncUnitBuffList,
            WorldCodec.UnitBuffList(Profile.InitialUnitId, buffs, firstInstanceId));
        state.NextBuffInstanceId += (uint)buffs.Count;
        ctx.Session.Log.Info($"[CAPABILITY] initial unit={Profile.InitialUnitId} template={Profile.InitialSpiritTemplateId} count={buffs.Count} loadingSafe=true allBuffsDeferred=true");
    }

}
