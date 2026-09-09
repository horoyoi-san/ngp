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
