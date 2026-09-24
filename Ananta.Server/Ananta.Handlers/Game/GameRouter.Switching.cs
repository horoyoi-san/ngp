using Ananta.SDK.Rpc;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    async Task OnSwitchSpirit(RpcContext ctx, uint requestedSpiritId)
    {
        var state = GetWorldState(ctx);
        if (!state.Ready)
        {
            ctx.Session.Log.Warn($"[SWITCH-MIN] ignored before world ready spirit={requestedSpiritId}");
            return;
        }

        if (state.PendingSwitchTemplateId != 0)
        {
            ctx.Session.Log.Warn($"[SWITCH-MIN] ignored while pending target={state.PendingSwitchTemplateId}");
            return;
        }

        var target = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == requestedSpiritId);
        if (target is null)
        {
            ctx.Session.Log.Warn($"[SWITCH-MIN] unknown requested spirit={requestedSpiritId}");
            return;
        }
        if (target.TemplateId == state.ActiveSpiritTemplateId)
            return;

        var hasLiveTransform = state.HasLastReportedPlayerTransform;
        var position = hasLiveTransform
            ? state.LastReportedPlayerPosition
            : state.WorldEntryCreateHeroPosition;
        var facing = hasLiveTransform && float.IsFinite(state.LastReportedPlayerRotation.Y)
            ? state.LastReportedPlayerRotation.Y
            : state.WorldEntryCreateHeroFacing;

        
        
        
        state.LastReportedPlayerPosition = position;
        state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
        state.HasLastReportedPlayerTransform = true;

        
        
        await SwitchSpiritDirectSameScene4229938(ctx, state, target.TemplateId, target.UnitId, position, facing);
    }

    async Task SwitchSpiritDirectSameScene4229938(
        RpcContext ctx, WorldEntryState state, uint templateId, ulong unitId, Vec3 switchPosition, float switchFacing)
    {
        var oldUnitId = state.ActiveSpiritUnitId;
        state.PendingSwitchTemplateId = templateId;
        state.PendingSwitchUnitId = unitId;
        state.PendingSwitchOldUnitId = oldUnitId;
        state.PendingSwitchShowId = 0;
        state.PendingSwitchPosition = switchPosition;
        state.PendingSwitchFacing = switchFacing;
        state.PendingSwitchControlTransferred = false;
        state.PendingSwitchLandingStarted = false;

        
        
        await ctx.NotifyAsync(MethodId.SyncLogicAgentEnter, WorldCodec.LogicAgentEnter(unitId));
        await ctx.NotifyAsync(MethodId.SyncManagedLogicAgent, WorldCodec.ManagedLogicAgent(unitId, Profile.PlayerPid, 0));
        await ctx.NotifyAsync(MethodId.SyncRaidBattleUnitSpirit,
            RuntimePayloadFactory.CharacterUnitProjection(templateId, switchPosition, switchFacing));
        await ctx.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
            WorldCodec.PositionAndFacing(unitId, switchPosition, switchFacing));
        await ctx.NotifyAsync(MethodId.SyncPlayerCurrentSpirit,
            WorldCodec.CurrentSpirit(Profile.PlayerPid, templateId, unitId, isAgentSwitch: false));
        
        
        await ctx.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
            WorldCodec.PositionAndFacing(unitId, switchPosition, switchFacing));

        state.LastReportedPlayerPosition = switchPosition;
        state.LastReportedPlayerRotation = new Vec3(0f, switchFacing, 0f);
        state.HasLastReportedPlayerTransform = true;
        state.ActiveSpiritTemplateId = templateId;
        state.ActiveSpiritUnitId = unitId;
        state.PendingSwitchControlTransferred = true;
        state.ActiveSkillId = 0;
        state.RestoreResourcesAfterActiveSkill = false;
        state.ActiveClientSkillInstanceId = 0;
        state.ActiveSkillStartedTicks = 0;

        
        
        
        await PublishMinimalActorPresentation4229938(ctx, unitId, templateId, "direct-switch");

        if (state.ActiveFeiSuoBuffInstanceId != 0)
        {
            var transientUnitId = state.ActiveFeiSuoBuffUnitId != 0 ? state.ActiveFeiSuoBuffUnitId : oldUnitId;
            await ctx.NotifyAsync(MethodId.SyncUnitRemoveBuff,
                WorldCodec.UnitRemoveBuff(transientUnitId, state.ActiveFeiSuoBuffInstanceId));
            state.ActiveFeiSuoBuffInstanceId = 0;
            state.ActiveFeiSuoBuffUnitId = 0;
        }
        await ClearClientWebLifecycleBuffs(ctx, oldUnitId, "minimal-direct-switch");
        await PublishSafeRuntimeBuffSnapshot4229938(ctx, unitId, templateId, "minimal-direct-switch");
        state.AllBuildBuffsPublished = true;

        if (oldUnitId != 0 && oldUnitId != unitId)
            await ctx.NotifyAsync(MethodId.SyncLogicAgentLeave, WorldCodec.LogicAgentLeave(oldUnitId));
        await ctx.NotifyAsync(MethodId.SyncGamePause, WorldCodec.GamePause(false));

        state.SwitchCount++;
        state.LastSwitchShowId = 0;
        state.PendingSwitchTemplateId = 0;
        state.PendingSwitchUnitId = 0;
        state.PendingSwitchOldUnitId = 0;
        state.PendingSwitchShowId = 0;
        state.PendingSwitchFacing = state.WorldEntryCreateHeroFacing;
        state.PendingSwitchControlTransferred = false;
        state.PendingSwitchLandingStarted = false;

        ctx.Session.Log.Info($"[SWITCH-MIN] direct count={state.SwitchCount} oldUnit={oldUnitId} target={templateId}/{unitId} authoredTimeline=false combatModules=false actorPresentation=true vehicles=false buffs=safe-web-only pos=({switchPosition.X:0.##},{switchPosition.Y:0.##},{switchPosition.Z:0.##}) facing={switchFacing:0.##}");
    }

}
