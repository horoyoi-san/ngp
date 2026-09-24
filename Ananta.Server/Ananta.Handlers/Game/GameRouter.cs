using Ananta.SDK.Rpc;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.Handlers.LoginGate;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    internal const string WorldStateKey = "client4229938-world";
    private readonly GateSessionHub? _gateSessions;

    internal GameRouter(GateSessionHub? gateSessions = null) => _gateSessions = gateSessions;

    private static readonly HashSet<uint> Enabled4229938MethodIds = new()
    {
        
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

        
        MethodId.AskAllSpiritPanelData,
        MethodId.AskSwitchSpirit,

        
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

        
        MethodId.AskAddClientBuff,
        MethodId.AskRemoveClientBuff,
        MethodId.AskEnterFeiSuoCrouch,
        MethodId.AskFeiSuoSuccess,
        MethodId.AskLeaveFeiSuoCrouch,

        
        MethodId.AskReportLogicAgentSyncData,
        MethodId.AskUnitMoveActionSimple,
        MethodId.AskUnitMoveActionSimpleWithGround,
        MethodId.AskUnitMoveActionWithGround,
        MethodId.AskUnitMoveAction,

        
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

        
        
        
        
        MethodId.AskVehicleNavigationPathPoints,
        MethodId.AskVehicleNavigationPathPointsFromPos,
        MethodId.AskVehicleNavigationPathLength,
        MethodId.AskVehicleNavigationPathLengthList,
        MethodId.AskVehicleStartAutonomousDriving,
        MethodId.AskVehicleChangeAutonomousDrivingTarget,
        MethodId.AskVehicleCancelAutonomousDrivingTarget,
        MethodId.AskVehicleStopAutonomousDriving,

        
        MethodId.GmSpawnVehicle,
        MethodId.GmAddEnemyWithPosition,
        MethodId.GmAddEnemy,
        MethodId.GmAddEnemyByPlayer,
        MethodId.GmTeleportXYZ,

        
        
        
        MethodId.ReportPreSwitchSpiritFinish,
        
        MethodId.AskSwitchSpiritComplete,

        
        MethodId.AskPassingTime,
        MethodId.GmPassingTime,
        MethodId.GmSetTime,
        MethodId.GmFixRaidTime,
        MethodId.ChangePersonalTimeSetting,
        MethodId.AddPersonalTimeSetting,
        MethodId.GmSetWeather,
        MethodId.GmSetWeatherParam,

        
        
        MethodId.AskSetSpiritFashionsWithSource,
        MethodId.AskMallBuyCommodity,
        MethodId.AskBuyCommodity,
        MethodId.AskNpcShop,
        MethodId.AskNpcShopCommodityInfo,
        MethodId.AskGetVehicleRadioContent,
        MethodId.AskSwitchVehicleRadio,
        MethodId.AskGetAllMetroInfos,
        MethodId.AskQueryAllFavorNpcAgentPos,
        MethodId.AskSetMobileSkinPart,
        MethodId.AskInstallMobileApp,
        MethodId.AskUninstallMobileApp,
        
        
        
        MethodId.AskPhoneAppDownload,
        MethodId.AskDiscardWeaponByInstanceId,
        MethodId.AskActiveDynamicGo,
        MethodId.AskTeleport,

        
        
        
        MethodId.AskTakeJob,
        MethodId.AskStartJob,
        MethodId.AskFinishJob,
        MethodId.AskQuitJob,
        MethodId.AskActiveSpiritJobTalentLayer,
        MethodId.AskResetSpiritJobTalent,
        MethodId.AskConvertCommonSpiritTalentExp,

        
        
        
        
        MethodId.AskChangeHackerName,
        MethodId.AskReadHackerNewPost,
        MethodId.AskAcceptHackerPostTask,

        
        
        
        MethodId.AskHack,
        MethodId.AskHackVehicle,
        MethodId.AskVehicleStartHackerAutonomousDriving,
        MethodId.AskVehicleStopHackerAutonomousDriving,
        MethodId.AskHackerBetray,
        MethodId.ReportBeHacked,
        MethodId.ReportHackerTetrisCreation,
        MethodId.AskStartHackerTetris,
        MethodId.AskFinishHackerTetris,
        
        
        MethodId.AskHackingNpcPress,
        MethodId.AskHackingNpc,
        MethodId.AskFinishHackingKeyFrame,
        MethodId.AskInteractCmd,
        MethodId.AskInteractCmds,

        MethodId.AskPoliceDispatch,
        MethodId.AskPoliceStopHelicopterDispatch,
        MethodId.AskPoliceVehicleHorn,
        MethodId.AskPoliceDistanceMonitorTrigger,
        MethodId.AskTeleportToPoliceStation,
        MethodId.AskAcceptPoliceTask,
        MethodId.AskSkipPoliceTask,
        MethodId.AskGiveUpPoliceTask,
        MethodId.AskAbandonPoliceTask,
        MethodId.AddPoliceChargingProgress,
        MethodId.UsePoliceChargingProgress,
        MethodId.AskPoliceTrailTeleport,
        MethodId.AskRPSInterrogationSelectOption,
        MethodId.AskPoliceEffectiveExam,
        MethodId.AskPoliceTakeCaseReward,
        MethodId.AskReadPoliceFakeClueAgentInfoList,
        MethodId.AskPoliceFakeFileAcceptTaskEvent,
        MethodId.AskPoliceFakeFileTakeReward,

        MethodId.AskGetJobBoardInfo,

        MethodId.AskGetTruckJobOrders,
        MethodId.AskRefreshTruckOrder,
        MethodId.AskAcceptTruckJobOrder,
        MethodId.AskPreSettleTruckOrder,
        MethodId.AskSettleTruckOrder,
        MethodId.AskObsoleteTruckJobOrder,
        MethodId.AskAutoAcceptTruckJobOrder,
        MethodId.AskSetTruckJobDefaultVehicleId,
        MethodId.AskResetTruckOrderGoods,
        MethodId.AskStartTruckOrderGuide,
        MethodId.AskGetTruckSatisfactionAverage,
        MethodId.AskGetAcceptedOrderWraps,
        MethodId.AskGetFinishedOrderWraps,
        MethodId.AskQueryTruckPosInfo,
        MethodId.AskDoTruckNpcAction,
        MethodId.AskAddTruckOrderSpecialPointReward,
        MethodId.AskAddTruckOrderSpecialPointRewards,

        
        MethodId.AskActivateNpcProfile,
        MethodId.AskTakeNpcProfileTrustReward,
        MethodId.AskTakeNpcProfileMaxTrustReward,
        MethodId.AskTakeNpcProfileProgressReward,
        MethodId.AskTakeNpcProfileProgressRewardWithWeb,

        
        MethodId.SyncActiveWildEnemyGroup,

        
        
        MethodId.AskAcceptTask,
        MethodId.AskAcceptAndSetCurrentTask,
        MethodId.AskSubmitTask,
        MethodId.AskFinishTaskCounter,
        MethodId.AskChangeTaskCounterValue,
        MethodId.AskSetTaskCounterValue,
        MethodId.AskUpdatePlayerScenarioInfo,
        MethodId.AskFinishGuide,
        MethodId.AskDoGuide,
        MethodId.AskStartGuideByCondition,
        MethodId.FinishTaskTitleGuideUnlock,
        MethodId.ForceAcceptTask,
        MethodId.ForceSubmitTask,
        MethodId.RemoveCurrentTask,
        MethodId.GmAcceptTask,
        MethodId.SyncTaskTitleGuideUnlock,

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        MethodId.AskMomentsPostSimpleInfos,
        MethodId.AskMomentsPostInfos,
        MethodId.AskMomentsUnreadMessage,
        MethodId.AskMomentsHaveUnreadMessage,
        MethodId.AskMomentsMarkRead,
        MethodId.AskMomentsLikePost,
        MethodId.AskMomentsSendCommentWithId,
        MethodId.AskMomentsTapPostWithCount,

        
        MethodId.AskServerGraffitoUrl,
    };

    internal RpcRouter Build()
    {
        var router = new RpcRouter("game");
        MethodId.RegisterKnownNames(router);
        var registered = AttributedHandlerRegistry.RegisterSelected(router, this, Enabled4229938MethodIds);

        
        
        Console.WriteLine(
            $"[ROUTER] game 注册 {registered} 个处理器 | 骇入自检: "
            + $"AskHackingNpcPress={router.HasInvokeHandler(MethodId.AskHackingNpcPress)} "
            + $"AskHackingNpc={router.HasInvokeHandler(MethodId.AskHackingNpc)} "
            + $"AskFinishHackingKeyFrame={router.HasInvokeHandler(MethodId.AskFinishHackingKeyFrame)} "
            + $"AskHack={router.HasInvokeHandler(MethodId.AskHack)} "
            + $"| EnableHack={PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackTargetsEnabled} "
            + $"电池={PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerBatteryCurrent}"
            + $"/{PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerBatteryTotal}");

        
        
        
        Console.WriteLine(
            "[ROUTER] 社交自检: "
            + $"AskMomentsPostSimpleInfos={router.HasInvokeHandler(MethodId.AskMomentsPostSimpleInfos)} "
            + $"AskMomentsPostInfos={router.HasInvokeHandler(MethodId.AskMomentsPostInfos)} "
            + $"AskMomentsMarkRead={router.HasInvokeHandler(MethodId.AskMomentsMarkRead)} "
            + $"AskMomentsLikePost={router.HasInvokeHandler(MethodId.AskMomentsLikePost)} "
            + $"AskMomentsSendCommentWithId={router.HasInvokeHandler(MethodId.AskMomentsSendCommentWithId)} "
            + $"AskMomentsUnreadMessage={router.HasInvokeHandler(MethodId.AskMomentsUnreadMessage)} "
            + $"AskServerGraffitoUrl={router.HasInvokeHandler(MethodId.AskServerGraffitoUrl)} "
            + $"| enabled={PrivateServerConfigStore.Current.Gameplay.SocialApp.Enabled} "
            + $"graffito='{PrivateServerConfigStore.Current.Gameplay.SocialApp.GraffitoUrl}'");

        router.OnUnknownInvoke(DefaultUnknownInvoke4229938);
        router.OnUnknownNotify(DefaultUnknownNotify4229938);
        return router;
    }
}
