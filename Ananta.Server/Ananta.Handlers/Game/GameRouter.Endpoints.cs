using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>Only RPC endpoints used by the maintained 4229938 private-server feature set.</summary>
internal sealed partial class GameRouter
{
    [Handler(MethodId.LoginGame, HandlerPacketKind.Notify)]
    private Task LoginGame(Connection conn, UxRpcMessage msg)
        => SendInitialGameState(msg.Context);

    [Handler(MethodId.RequestGameSceneData, HandlerPacketKind.Notify)]
    private Task RequestGameSceneData(Connection conn, UxRpcMessage msg)
        => SendEnterSceneIfNeeded(msg.Context);

    [Handler(MethodId.GetServerTimeGame)]
    private async Task GetServerTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.IsInvoke)
        {
            await conn.ReturnEmptyOkAsync(msg);
            return;
        }
        var args = msg.GetArgs<GameMethods.GetServerTime>();
        await conn.NotifyAsync(MethodId.SendServerTimeGame, LoginCodec.ServerTime(args.clientUnixTime));
    }

    [Handler(MethodId.AskAllSpiritPanelData, HandlerPacketKind.Invoke)]
    private Task AskAllSpiritPanelData(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, RuntimePayloadFactory.MinimalAllSpiritPanelData4229938());

    [Handler(MethodId.GetSpriteToken, HandlerPacketKind.Invoke)]
    private Task GetSpriteToken4229938(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, new GameMethods.SpriteToken4229938
        {
            Token = string.Empty,
            ExpireTimeStamp = 0
        });

    [Handler(MethodId.CheckPSOPermissions, HandlerPacketKind.Invoke)]
    private Task CheckPsoPermissions(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, false);

    [Handler(MethodId.AskSetGamePause, HandlerPacketKind.Invoke)]
    private async Task AskSetGamePause(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSetGamePause>();
        await conn.ReturnEmptyOkAsync(msg);
        await conn.NotifyAsync(MethodId.SyncGamePause, new SceneMethods.SyncGamePause { pause = args.value });
    }

    [Handler(MethodId.AskLoadSceneCompleted, HandlerPacketKind.Notify)]
    private Task AskLoadSceneCompleted(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskLoadSceneCompleted>();
        return OnLoadSceneCompleted(msg.Context, args.sceneId, args.sessionId);
    }

    [Handler(MethodId.AskLoadGameResCompleted, HandlerPacketKind.Notify)]
    private Task AskLoadGameResCompleted(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskLoadGameResCompleted>();
        return OnLoadGameResourcesCompleted(msg.Context, args.sceneId);
    }

    [Handler(MethodId.AskLoadingFinished, HandlerPacketKind.Invoke)]
    private async Task AskLoadingFinished(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskLoadingFinished>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnLoadingFinished(msg.Context, args.sceneId, args.sessionId);
    }

    [Handler(MethodId.AskLoadedInSameScene, HandlerPacketKind.Notify)]
    private Task AskLoadedInSameScene(Connection conn, UxRpcMessage msg)
        => OnLoadedInSameScene(msg.Context);

    [Handler(MethodId.AskSwitchSpirit)]
    private async Task AskSwitchSpirit(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSwitchSpirit>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnSwitchSpirit(msg.Context, args.spiritId);
    }

    [Handler(MethodId.AskSwitchWeapon, HandlerPacketKind.Notify)]
    private Task AskSwitchWeapon(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSwitchWeapon>();
        return OnSwitchWeapon(msg.Context, args.index);
    }

    [Handler(MethodId.AskSwitchFightStyle, HandlerPacketKind.Invoke)]
    private async Task AskSwitchFightStyle(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSwitchFightStyle>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnSwitchFightStyle(msg.Context, args.spiritId, args.fightStyleTypeId, args.fightStyleId);
    }

    [Handler(MethodId.AskSetWeaponFightStyle, HandlerPacketKind.Invoke)]
    private async Task AskSetWeaponFightStyle(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetWeaponFightStyle>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnSetWeaponFightStyle(msg.Context, args.weaponInstanceId, args.fightStyleId);
    }

    [Handler(MethodId.AskLoadWeaponToSlot, HandlerPacketKind.Invoke)]
    private async Task AskLoadWeaponToSlot(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskLoadWeaponToSlot>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnLoadWeaponToSlot(msg.Context, args.spiritId, args.weaponId, args.slotIndex);
    }

    [Handler(MethodId.AskDepositSpiritWeapon, HandlerPacketKind.Invoke)]
    private async Task AskDepositSpiritWeapon(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskDepositSpiritWeapon>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnDepositSpiritWeapon(msg.Context, args.spiritId, args.slotIndex);
    }

    [Handler(MethodId.AskExchangeWeaponSlot, HandlerPacketKind.Invoke)]
    private async Task AskExchangeWeaponSlot(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskExchangeWeaponSlot>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnExchangeWeaponSlot(msg.Context, args.fromSpirit, args.fromIndex, args.toSpirit, args.toIndex);
    }

    [Handler(MethodId.AskAddClientBuff)]
    private async Task AskAddClientBuff(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskAddClientBuff>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnClientBuffAdd(msg.Context, args.unitId, args.buffId);
    }

    [Handler(MethodId.AskRemoveClientBuff)]
    private async Task AskRemoveClientBuff(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskRemoveClientBuff>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnClientBuffRemove(msg.Context, args.unitId, args.buffId);
    }

    [Handler(MethodId.AskEnterFeiSuoCrouch, HandlerPacketKind.Notify)]
    private Task AskEnterFeiSuoCrouch(Connection conn, UxRpcMessage msg)
        => OnEnterFeiSuoCrouch(msg.Context);

    [Handler(MethodId.AskFeiSuoSuccess, HandlerPacketKind.Invoke)]
    private async Task AskFeiSuoSuccess(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskFeiSuoSuccess>();
        await OnFeiSuoSuccess(msg.Context, args.feiSuoId);
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskLeaveFeiSuoCrouch, HandlerPacketKind.Notify)]
    private Task AskLeaveFeiSuoCrouch(Connection conn, UxRpcMessage msg)
        => OnLeaveFeiSuoCrouch(msg.Context);

    [Handler(MethodId.AskClientUseCommonSkill, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskUseSkill, HandlerPacketKind.Invoke)]
    private Task AskUseSkill(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskUseSkill>();
        return OnClientUseSkill(msg.Context, args.data);
    }

    [Handler(MethodId.AskSkillUseWeaponDurability, HandlerPacketKind.Notify)]
    private Task AskSkillUseWeaponDurability(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSkillUseWeaponDurability>();
        return OnSkillUseWeaponDurability(msg.Context, args.skillid, args.triggerindex);
    }

    [Handler(MethodId.AskWeaponEquipBullets, HandlerPacketKind.Invoke)]
    private async Task AskWeaponEquipBullets(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskWeaponEquipBullets>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnWeaponEquipBullets(msg.Context, args.weaponinstanceid, args.bulletid);
    }

    [Handler(MethodId.ReportSkillEnd, HandlerPacketKind.Notify)]
    private Task ReportSkillEnd(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.ReportSkillEnd>();
        return OnReportSkillEnd(msg.Context, args);
    }

    [Handler(MethodId.AskMultipleSkillHit2, HandlerPacketKind.Notify)]
    private Task AskMultipleSkillHit2(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskMultipleSkillHit2>();
        return OnSkillHit(msg.Context, args.skillHitData);
    }

    [Handler(MethodId.AskInterruptSkillExecute, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskInterruptSkillExecuteStiff, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSkillExecuteEnd, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSkillExecute, HandlerPacketKind.Invoke)]
    private static Task AcceptCombatInvoke(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskSkillDestructibleCreate, HandlerPacketKind.Invoke)]
    private static Task AskSkillDestructibleCreate(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, 0UL);

    [Handler(MethodId.AskReportLogicAgentSyncData)]
    [Handler(MethodId.AskUnitMoveActionSimple, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskUnitMoveActionSimpleWithGround, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskUnitMoveActionWithGround, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskUnitMoveAction, HandlerPacketKind.Notify)]
    private async Task MovementReport(Connection conn, UxRpcMessage msg)
    {
        IEnumerable<SceneMethods.LogicAgentSyncData>? samples = msg.MethodId switch
        {
            MethodId.AskReportLogicAgentSyncData => msg.GetArgs<SceneMethods.AskReportLogicAgentSyncData>().list,
            MethodId.AskUnitMoveActionSimple => msg.GetArgs<SceneMethods.AskUnitMoveActionSimple>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            MethodId.AskUnitMoveActionSimpleWithGround => msg.GetArgs<SceneMethods.AskUnitMoveActionSimpleWithGround>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            MethodId.AskUnitMoveAction => msg.GetArgs<SceneMethods.AskUnitMoveAction>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            MethodId.AskUnitMoveActionWithGround => msg.GetArgs<SceneMethods.AskUnitMoveActionWithGround>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            _ => null
        };

        await conn.ReturnEmptyOkAsync(msg);
        await OnMovementReport(msg.Context, samples);
    }
}
