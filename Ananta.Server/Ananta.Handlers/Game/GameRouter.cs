using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.Handlers.LoginGate;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Build 4229938 private-server surface: world entry, direct character switching,
/// combat, traversal/buffs, vehicles and movement. Everything else falls back to typed-neutral RPC replies.
/// </summary>
internal sealed partial class GameRouter
{
    internal const string WorldStateKey = "client4229938-world";
    private readonly GateSessionHub? _gateSessions;

    internal GameRouter(GateSessionHub? gateSessions = null) => _gateSessions = gateSessions;

    private static readonly HashSet<uint> Enabled4229938MethodIds = new()
    {
        // Login / world-entry barriers.
        MethodId.LoginGame,
        MethodId.RequestGameSceneData,
        MethodId.GetServerTimeGame,
        MethodId.GetSpriteToken,
        MethodId.CheckPSOPermissions,
        MethodId.AskSetGamePause,
        MethodId.AskLoadSceneCompleted,
        MethodId.AskLoadGameResCompleted,
        MethodId.AskLoadingFinished,
        MethodId.AskLoadedInSameScene,

        // Roster + direct character switching.
        MethodId.AskAllSpiritPanelData,
        MethodId.AskSwitchSpirit,

        // Combat / weapon sandbox.
        MethodId.AskSwitchWeapon,
        MethodId.AskSwitchFightStyle,
        MethodId.AskSetWeaponFightStyle,
        MethodId.AskLoadWeaponToSlot,
        MethodId.AskDepositSpiritWeapon,
        MethodId.AskExchangeWeaponSlot,
        MethodId.AskClientUseCommonSkill,
        MethodId.AskUseSkill,
        MethodId.AskSkillUseWeaponDurability,
        MethodId.AskWeaponEquipBullets,
        MethodId.ReportSkillEnd,
        MethodId.AskMultipleSkillHit2,
        MethodId.AskInterruptSkillExecute,
        MethodId.AskInterruptSkillExecuteStiff,
        MethodId.AskSkillExecuteEnd,
        MethodId.AskSkillExecute,
        MethodId.AskSkillDestructibleCreate,

        // Client-decided traversal/web buffs.
        MethodId.AskAddClientBuff,
        MethodId.AskRemoveClientBuff,
        MethodId.AskEnterFeiSuoCrouch,
        MethodId.AskFeiSuoSuccess,
        MethodId.AskLeaveFeiSuoCrouch,

        // Live transform tracking.
        MethodId.AskReportLogicAgentSyncData,
        MethodId.AskUnitMoveActionSimple,
        MethodId.AskUnitMoveActionSimpleWithGround,
        MethodId.AskUnitMoveActionWithGround,
        MethodId.AskUnitMoveAction,

        // Vehicles: summon + owned fleet + client-driven drive loop + S011 boarding story.
        MethodId.AskSummonVehicle,
        MethodId.AskGetUnlockedVehicles,
        MethodId.SyncStoryCoreClientInfo,
        MethodId.AskClaimVehicleSeat,
        MethodId.AskPlayerStartEnterOrExitVehicle,
        MethodId.AskPlayerFinishEnterOrExitVehicle,
        MethodId.AskVehicleMove,
        MethodId.AskVehicleStartMove,
        MethodId.AskVehicleStopMove,
        MethodId.AskVehicleHorn,
        MethodId.AskEnterVehicleIndoor,
        MethodId.AskExitVehicleIndoor,
        MethodId.ReportDrivingVehicle,
        MethodId.AskKillVehicle,
        MethodId.VehicleDriveStateChange,
        MethodId.AskChangeGoVehicleDriveState,
        MethodId.AskVehicleDeadEnd,
        MethodId.AskVehicleNitro,
        MethodId.AskVehicleStuck,
        MethodId.AskVehicleHit,
        MethodId.AskVehicleHitEnd,

        // GM console (ALT+F1): C2S invokes, server records real ids.
        MethodId.GmSpawnVehicle,
        MethodId.GmAddEnemyWithPosition,
        MethodId.GmAddEnemy,
        MethodId.GmAddEnemyByPlayer,
        MethodId.GmTeleportXYZ,

        // Time of day: client-driven UI (accept + remember) + debug-panel slider push.
        MethodId.AskPassingTime,
        MethodId.GmPassingTime,
        MethodId.GmSetTime,
        MethodId.GmFixRaidTime,
        MethodId.ChangePersonalTimeSetting,
        MethodId.AddPersonalTimeSetting,
        MethodId.GmSetWeather,
        MethodId.GmSetWeatherParam,
    };

    internal RpcRouter Build()
    {
        var router = new RpcRouter("game");
        MethodId.RegisterKnownNames(router);
        _ = AttributedHandlerRegistry.RegisterSelected(router, this, Enabled4229938MethodIds);
        router.OnUnknownInvoke(DefaultUnknownInvoke4229938);
        router.OnUnknownNotify(DefaultUnknownNotify4229938);
        return router;
    }
}
