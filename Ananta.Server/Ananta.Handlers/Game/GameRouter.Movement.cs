using Ananta.SDK.Rpc;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    async Task OnMovementReport(RpcContext ctx, IEnumerable<SceneMethods.LogicAgentSyncData>? samples)
    {
        var state = GetWorldState(ctx);

        
        
        if (samples is not null)
        {
            foreach (var item in samples)
            {
                var isActive = item.AgentId == state.ActiveSpiritUnitId;
                var isPendingTarget = state.PendingSwitchUnitId != 0 && item.AgentId == state.PendingSwitchUnitId;
                var isPendingOld = state.PendingSwitchOldUnitId != 0 && item.AgentId == state.PendingSwitchOldUnitId;
                if (!isActive && !isPendingTarget && !isPendingOld)
                    continue;

                var p = item.Position;
                var r = item.Rotation;
                if (float.IsFinite(p.X) && float.IsFinite(p.Y) && float.IsFinite(p.Z) &&
                    float.IsFinite(r.X) && float.IsFinite(r.Y) && float.IsFinite(r.Z))
                {
                    state.LastReportedPlayerPosition = new Vec3(p.X, p.Y, p.Z);
                    state.LastReportedPlayerRotation = new Vec3(r.X, r.Y, r.Z);
                    state.HasLastReportedPlayerTransform = true;

                    
                    
                    
                    
                    try
                    {
                        await PublishSceneContentAoiAsync(ctx.Session, p.X, p.Z, force: false, ctx.CancellationToken);
                    }
                    catch (OperationCanceledException) { }
                    catch (Exception ex)
                    {
                        ctx.Session.Log.Warn($"[SCENE-AOI] 下发失败（已忽略）: {ex.GetType().Name}: {ex.Message}");
                    }

                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
            }
        }

        if (state.FirstMovementSeen)
            return;

        
        
        
        if (!state.Ready)
        {
            ctx.Session.Log.Warn("[MOVE] movement arrived before world ready; pause-only stability release remains armed");
            return;
        }

        state.FirstMovementSeen = true;
        ctx.Session.Log.Info($"[MOVE] client-agent-traffic rpc={ctx.MethodId} bytes={ctx.Body.Length} liveTransform={state.HasLastReportedPlayerTransform} logicProjection={state.WorldEntryLogicProjectionPublishedGeneration} currentMetadata={state.WorldEntryCurrentMetadataPublishedGeneration}");

        
        
        
        
        var unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
        var templateId = state.ActiveSpiritTemplateId != 0 ? state.ActiveSpiritTemplateId : Profile.InitialSpiritTemplateId;

        if (!state.AllBuildBuffsPublished)
        {
            await PublishSafeRuntimeBuffSnapshot4229938(ctx, unitId, templateId, "first-gameplay-movement");
            state.AllBuildBuffsPublished = true;
        }

        
        await PublishGarageAsync(ctx);

        await ctx.NotifyAsync(MethodId.SyncGamePause, WorldCodec.GamePause(false));
        state.MovementCapabilityPublished = true;
        state.FreeRoamReleased = true;
        ctx.Session.Log.Info($"[GAMEPLAY-V7] first-movement post-load-buffs unit={unitId} template={templateId} actorPresentation=client-owned safeBuffs=true pause=false catalogBulk=false");
    }
}
