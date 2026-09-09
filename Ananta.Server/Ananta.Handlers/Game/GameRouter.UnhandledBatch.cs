using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Batch implementation of top unhandled methods from unknown-methods.log:
/// camera telemetry (silent no-ops), vehicle driving/radio/horn/top-speed/nitro set,
/// indoor/building/safe-area transitions, and a second neutral UI/economy batch.
/// </summary>
internal sealed partial class GameRouter
{
    // --- Camera telemetry: pure client-side state, zero server value. Silent accept. ---

    [Handler(MethodId.AskPlayerCameraMove, HandlerPacketKind.Notify)]
    private Task CamMove(Connection conn, UxRpcMessage msg) => Task.CompletedTask;

    [Handler(MethodId.AskUpdatePlayerCameraRotation, HandlerPacketKind.Notify)]
    private Task CamRot(Connection conn, UxRpcMessage msg) => Task.CompletedTask;

    [Handler(MethodId.AskUpdatePlayerCameraFOV, HandlerPacketKind.Notify)]
    private Task CamFov(Connection conn, UxRpcMessage msg) => Task.CompletedTask;

    [Handler(MethodId.AskUpdatePlayerCameraAspectRatio, HandlerPacketKind.Notify)]
    private Task CamAspect(Connection conn, UxRpcMessage msg) => Task.CompletedTask;

    // --- Vehicle driving telemetry ---

    [Handler(MethodId.ReportDrivingVehicle, HandlerPacketKind.Notify)]
    private Task ReportDrivingVehicle(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.ReportDrivingVehicleArgs4229938>(out var args) && args is not null)
        {
            var runtime = GetVehicleRuntime(msg.Context);
            lock (runtime.SyncRoot)
            {
                if (runtime.Vehicles.TryGetValue(args.vehicleId, out var record))
                {
                    record.DistanceDriven += args.deltaDistance;
                    if (record.IsDriving != args.isDriving)
                    {
                        record.IsDriving = args.isDriving;
                        conn.Log.Info($"[VEHICLE] driving vehicle={args.vehicleId} on={args.isDriving} odo={record.DistanceDriven:F0}m");
                    }
                }
            }
        }
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskVehicleNitroValue, HandlerPacketKind.Notify)]
    private Task AskVehicleNitroValue(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskVehicleNitroValueArgs4229938>(out var args) && args is not null)
        {
            var runtime = GetVehicleRuntime(msg.Context);
            lock (runtime.SyncRoot)
            {
                if (runtime.Vehicles.TryGetValue(args.vehicleId, out var record))
                    record.LastNitroValue = args.value;
            }
        }
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskVehicleNitro)]
    private async Task AskVehicleNitro(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskVehicleNitroArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[VEHICLE] nitro vehicle={args.VehicleId} value={args.NitrogenValue:F1} begin={args.BeginOrEnd}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskModifyVehicleTopSpeed, HandlerPacketKind.Notify)]
    private Task AskModifyVehicleTopSpeed(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskModifyVehicleTopSpeedArgs4229938>(out var args) && args is not null)
        {
            var runtime = GetVehicleRuntime(msg.Context);
            lock (runtime.SyncRoot)
            {
                if (runtime.Vehicles.TryGetValue(args.vehicleId, out var record))
                {
                    record.TopSpeed = args.topSpeed;
                    record.HasTopSpeed = args.beginOrEnd;
                }
            }
            conn.Log.Info($"[VEHICLE] topspeed vehicle={args.vehicleId} v={args.topSpeed:F1} active={args.beginOrEnd}");
        }
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskVehicleHorn, HandlerPacketKind.Notify)]
    private Task AskVehicleHorn(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskVehicleHornArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[VEHICLE] horn entity={args.entityId} play={args.play}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskVehicleContactDamage, HandlerPacketKind.Notify)]
    private Task AskVehicleContactDamage(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskVehicleContactDamageArgs4229938>(out var args) && args?.data is not null)
            conn.Log.Info($"[VEHICLE] contact vehicle={args.vehicleId} mass={args.data.VehicleMass:F0} layer={args.data.Layer} other={args.data.OtherVehicleEntityId}");
        else
            conn.Log.Warn($"[VEHICLE] AskVehicleContactDamage undecodable bytes={msg.Body.Length}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskVehicleInteractConfig, HandlerPacketKind.Notify)]
    private Task AskVehicleInteractConfig(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[VEHICLE] interact-config bytes={msg.Body.Length} hex={Convert.ToHexString(msg.Body, 0, Math.Min(msg.Body.Length, 48))}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskUpdateVehicleDestructibleParts, HandlerPacketKind.Notify)]
    private Task AskUpdateVehicleDestructibleParts(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[VEHICLE] destructible-parts bytes={msg.Body.Length} hex={Convert.ToHexString(msg.Body, 0, Math.Min(msg.Body.Length, 48))}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskGetVehicleRadioContent)]
    private async Task AskGetVehicleRadioContent(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskGetVehicleRadioContentArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[VEHICLE] radio content radio={args.radioId} song={args.songIdx}");
        if (DefaultReturnCatalog4229938.TryGet(msg.MethodId, out var body, out var shape))
        {
            conn.Log.Info($"[VEHICLE] radio -> typed-default {shape}");
            await msg.Context.ReturnAsync(body);
            return;
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    // --- Indoor / building / safe-area transitions (logged accepts; sector control later) ---

    [Handler(MethodId.SyncChangeSafeArea, HandlerPacketKind.Notify)]
    private Task SyncChangeSafeArea(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.SyncChangeSafeAreaArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[SCENE] safe-area region={args.regionId}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.SyncChangeBuilding)]
    private async Task SyncChangeBuilding(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.SyncChangeBuildingArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[SCENE] building={args.buildingId} floor={args.floorId}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.SyncChangeIndoor)]
    private async Task SyncChangeIndoor(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.SyncChangeIndoorArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[SCENE] indoor config={args.indoorConfigId} bound={args.boundId}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    // --- Neutral UI/economy batch 2: exact typed-default replies, info-level logging ---
    [Handler(MethodId.GetMailHeadList, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskAkxSessionList, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskGetAllMetroInfos, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskMomentsPostSimpleInfos, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskPanelOpenOrClose, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskQueryPlayerUnlockNameEffect, HandlerPacketKind.Invoke)]
    [Handler(MethodId.GetPersonalInfo, HandlerPacketKind.Invoke)]
    private Task KnownNeutralInvokeBatch2(Connection conn, UxRpcMessage msg)
    {
        if (DefaultReturnCatalog4229938.TryGet(msg.MethodId, out var body, out var shape))
        {
            conn.Log.Info($"[RPC4229938] neutral {Ananta.SDK.Logging.RpcMethodNames.Display(msg.MethodId)} -> {shape} {body.Length}b");
            return msg.Context.ReturnAsync(body);
        }
        return conn.ReturnEmptyOkAsync(msg);
    }

    // --- Skill/combat accepts: logged, protocol-correct empty replies (authoritative later) ---
    [Handler(MethodId.AskInterruptSkillExecute2)]
    [Handler(MethodId.AskSkillExecute3)]
    [Handler(MethodId.AskSkillExecuteEnd2)]
    [Handler(MethodId.AskSkillAddState)]
    [Handler(MethodId.AskSkillOpenShield)]
    [Handler(MethodId.AskSkillCloseShield)]
    [Handler(MethodId.AskSkillTimeCurve)]
    [Handler(MethodId.ReportSkillAnimationEnd)]
    [Handler(MethodId.AskSkillSpawnItem)]
    [Handler(MethodId.AskSwitchSpiritComplete)]
    [Handler(MethodId.AskSpoonClientAttack)]
    [Handler(MethodId.AskVehicleSkillDamage)]
    [Handler(MethodId.AskSkillDestructibleCreateGadget)]
    [Handler(MethodId.AskSkillDestructibleCreateVehicle)]
    private async Task SkillNeutralAccepts(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[COMBAT] accept {Ananta.SDK.Logging.RpcMethodNames.Display(msg.MethodId)} bytes={msg.Body.Length}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    // --- Destructibles / weapon red dots / discards / hangup (fresh log batch) ---

    [Handler(MethodId.AskNotifyDestructibleHits)]
    private async Task AskNotifyDestructibleHits(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskNotifyDestructibleHitsArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[DESTRUCTIBLE] hits targets={args.hits.Count}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskOperateDestructibleObject)]
    private async Task AskOperateDestructibleObject(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskOperateDestructibleObjectArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[DESTRUCTIBLE] operate id={args.id} op={args.operation}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskMoveDestructibleObjects, HandlerPacketKind.Notify)]
    private Task AskMoveDestructibleObjects(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskMoveDestructibleObjectsArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[DESTRUCTIBLE] move count={args.ids.Count}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskBreakDestructibleObjects, HandlerPacketKind.Notify)]
    private Task AskBreakDestructibleObjects(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskBreakDestructibleObjectsArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[DESTRUCTIBLE] break breaker={args.breaker} count={args.brokenInfos.Count}");
        else
            conn.Log.Warn($"[DESTRUCTIBLE] AskBreakDestructibleObjects undecodable bytes={msg.Body.Length}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskReadWeaponRedDots, HandlerPacketKind.Notify)]
    private Task AskReadWeaponRedDots(Connection conn, UxRpcMessage msg) => Task.CompletedTask;

    [Handler(MethodId.AskDiscardWeaponByInstanceId)]
    private async Task AskDiscardWeaponByInstanceId(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskDiscardWeaponByInstanceIdArgs4229938>(out var args) && args is not null)
        {
            var state = GetWorldState(msg.Context);
            var slots = WeaponSlotIds(state, args.spiritId);
            var index = slots.IndexOf(args.weaponInstanceId);
            if (index >= 0 && IsEditableWeaponSlot(index))
            {
                slots[index] = 0;
                conn.Log.Info($"[ARMORY] discard instance={args.weaponInstanceId} spirit={args.spiritId} slot={index} dropout={args.isDropOut}");
                await PublishWeaponSlotsAfterMutation(msg.Context, args.spiritId, $"discard:{args.weaponInstanceId}");
            }
            else
            {
                conn.Log.Warn($"[ARMORY] discard rejected instance={args.weaponInstanceId} spirit={args.spiritId}");
            }
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskDiscardWeapon, HandlerPacketKind.Notify)]
    private async Task AskDiscardWeapon(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskDiscardWeaponArgs4229938>(out var args) && args is not null)
        {
            var state = GetWorldState(msg.Context);
            await OnDepositSpiritWeapon(msg.Context, state.ActiveSpiritTemplateId, args.index);
            conn.Log.Info($"[ARMORY] discard-index slot={args.index}");
        }
    }

    [Handler(MethodId.RequestPlayerStartHangup)]
    private async Task RequestPlayerStartHangup(Connection conn, UxRpcMessage msg)
    {
        GetWorldState(msg.Context).IsHangup = true;
        conn.Log.Info("[HANGUP] start");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.RequestPlayerStopHangup)]
    private async Task RequestPlayerStopHangup(Connection conn, UxRpcMessage msg)
    {
        GetWorldState(msg.Context).IsHangup = false;
        conn.Log.Info("[HANGUP] stop");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskBreakSkillTimeCurve, HandlerPacketKind.Notify)]
    private Task AskBreakSkillTimeCurve(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskBreakSkillTimeCurveArgs4229938>(out var args) && args is not null)
            conn.Log.Info($"[COMBAT] break-curve releaser={args.releaser} id={args.id} index={args.index}");
        return Task.CompletedTask;
    }
}
