using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.Handlers.LoginGate;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Build 4229938 private-server surface: world entry, direct character switching,
/// combat, traversal/buffs and movement. Everything else falls back to typed-neutral RPC replies.
/// </summary>
internal sealed partial class GameRouter
{
    private const string WorldStateKey = "client4229938-world";
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

        // Time/sync basics.
        MethodId.GetServerTimeGame,

        // Scene ("raid") switching.
        MethodId.AskPublicSwitchToPublicScene,
        MethodId.AskEnterRaidByMapEntrance,

        // Teleport (inbound requests; pushes need no registration).
        MethodId.AskTeleport,
        MethodId.ReportPreTeleportFinish,
        MethodId.ReportPostTeleportFinish,
        MethodId.Teleport,

        // Vehicles (simple shapes; complex-return vehicle RPCs stay on the
        // typed-default fallback + unknown-methods.log for now).
        MethodId.GmAddVehicle,
        MethodId.AskVehicleShopSpawnVehicle,
        MethodId.VehicleDriveStateChange,
        MethodId.AskGetUnlockedVehicles,
        MethodId.AskSummonVehicle,
        MethodId.AskPlayerStartEnterOrExitVehicle,
        MethodId.AskPlayerFinishEnterOrExitVehicle,
        MethodId.AskVehicleMove,
        MethodId.AskClaimVehicleSeat,
        MethodId.SyncStoryCoreClientInfo,
        MethodId.AskInteractCmd,

        // Formerly-unhandled batch (explicit compatibility handlers).
        MethodId.AskTradeGetMarketList,
        MethodId.AskTradeGetHistoryPage,
        MethodId.AskPlayerRankingSummary,
        MethodId.AskPopularityPhoneFirstOpened,
        MethodId.AskPopularityUIOpened,
        MethodId.SyncOpenInspireHub,
        MethodId.AskQueryInspireHubAllGamePlayRecommendData,
        MethodId.AskQueryInspireHubAllGamePlayRankData,
        MethodId.AskLinkInfos,
        MethodId.GetLastMode,
        MethodId.AskSwitchLinkMode,
        MethodId.OnParkourStateChange,
        MethodId.AskPlayerCameraMove,
        MethodId.AskUpdatePlayerCameraRotation,
        MethodId.AskUpdatePlayerCameraFOV,
        MethodId.AskUpdatePlayerCameraAspectRatio,
        MethodId.ReportDrivingVehicle,
        MethodId.AskVehicleNitroValue,
        MethodId.AskVehicleNitro,
        MethodId.AskModifyVehicleTopSpeed,
        MethodId.AskVehicleHorn,
        MethodId.AskVehicleContactDamage,
        MethodId.AskVehicleInteractConfig,
        MethodId.AskUpdateVehicleDestructibleParts,
        MethodId.AskGetVehicleRadioContent,
        MethodId.SyncChangeSafeArea,
        MethodId.SyncChangeBuilding,
        MethodId.SyncChangeIndoor,
        MethodId.GetMailHeadList,
        MethodId.AskAkxSessionList,
        MethodId.AskGetAllMetroInfos,
        MethodId.AskMomentsPostSimpleInfos,
        MethodId.AskPanelOpenOrClose,
        MethodId.AskQueryPlayerUnlockNameEffect,
        MethodId.GetPersonalInfo,

        // Skill/combat accepts (logged empty replies; authoritative damage later).
        MethodId.AskInterruptSkillExecute2,
        MethodId.AskSkillExecute3,
        MethodId.AskSkillExecuteEnd2,
        MethodId.AskSkillAddState,
        MethodId.AskSkillOpenShield,
        MethodId.AskSkillCloseShield,
        MethodId.AskSkillTimeCurve,
        MethodId.ReportSkillAnimationEnd,
        MethodId.AskSkillSpawnItem,
        MethodId.AskSwitchSpiritComplete,
        MethodId.AskSpoonClientAttack,
        MethodId.AskVehicleSkillDamage,
        MethodId.AskSkillDestructibleCreateGadget,
        MethodId.AskSkillDestructibleCreateVehicle,

        // Time + weather.
        MethodId.AskPassingTime,
        MethodId.ChangePersonalTimeSetting,
        MethodId.AddPersonalTimeSetting,
        MethodId.GmSetWeather,
        MethodId.GmSetWeatherParam,
        MethodId.GmSetTime,
        MethodId.GmFixRaidTime,
        MethodId.GmPassingTime,

        // Destructibles / red dots / discards / hangup / curves.
        MethodId.AskNotifyDestructibleHits,
        MethodId.AskOperateDestructibleObject,
        MethodId.AskMoveDestructibleObjects,
        MethodId.AskBreakDestructibleObjects,
        MethodId.AskReadWeaponRedDots,
        MethodId.AskDiscardWeaponByInstanceId,
        MethodId.AskDiscardWeapon,
        MethodId.RequestPlayerStartHangup,
        MethodId.RequestPlayerStopHangup,
        MethodId.AskBreakSkillTimeCurve,
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
