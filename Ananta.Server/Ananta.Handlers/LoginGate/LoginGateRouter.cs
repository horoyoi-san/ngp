using Ananta.SDK.Rpc;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.LoginGate;

internal sealed class LoginGateRouter
{
    private readonly GateSessionHub? _gateSessions;
    private static PrivateServerConfig Config => PrivateServerConfigStore.Current;

    internal LoginGateRouter(GateSessionHub? gateSessions = null)
        => _gateSessions = gateSessions;

    internal RpcRouter Build()
    {
        var router = new RpcRouter("login-gate");
        MethodId.RegisterKnownNames(router);
        AttributedHandlerRegistry.Register(router, this);
        return router;
    }

    [Handler(MethodId.CheckVersion, HandlerPacketKind.Invoke)]
    [Handler(MethodId.HasOnlinePlayer, HandlerPacketKind.Invoke)]
    private Task EmptySuccess(Connection conn, UxRpcMessage msg) => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskNewHotFixPatchLogin, HandlerPacketKind.Invoke)]
    private Task AskNewHotFixPatchLogin(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyAsync(msg, Config.Client.NoMoreHotfixPatchError);

    [Handler(MethodId.RequestPatchesCheckDataFromLogin, HandlerPacketKind.Invoke)]
    private Task RequestPatchesCheckDataFromLogin(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, LoginCodec.PatchCheck());

    [Handler(MethodId.RequestPatchesFromLogin, HandlerPacketKind.Invoke)]
    private Task RequestPatchesFromLogin(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, new List<uint>());

    [Handler(MethodId.AskUniSdkShareToken_Login, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskUniSdkShareToken_Gate, HandlerPacketKind.Invoke)]
    private Task AskUniSdkShareToken(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, Config.Player.ShareToken);

    [Handler(MethodId.RequestFpPassToken, HandlerPacketKind.Invoke)]
    private Task RequestFpPassToken(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, Config.Player.FpPassToken);

    [Handler(MethodId.CheckAccount, HandlerPacketKind.Invoke)]
    [Handler(MethodId.CheckAccountPassBy, HandlerPacketKind.Invoke)]
    [Handler(MethodId.CheckAccountOpenId, HandlerPacketKind.Invoke)]
    private Task CheckAccount(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, LoginCodec.CheckAccount());

    [Handler(MethodId.TryLogin, HandlerPacketKind.Invoke)]
    private async Task TryLogin(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        await conn.NotifyAsync(MethodId.SyncRoleList, Profile.PlayerPid);
    }

    [Handler(MethodId.RequestCreateRoleEx, HandlerPacketKind.Invoke)]
    private async Task RequestCreateRoleEx(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnAsync(msg, Profile.PlayerPid);
        await conn.NotifyAsync(MethodId.SyncRoleList, Profile.PlayerPid);
    }

    [Handler(MethodId.RequestEnterGame, HandlerPacketKind.Invoke)]
    [Handler(MethodId.DebugRequestEnterGame, HandlerPacketKind.Invoke)]
    private Task RequestEnterGame(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, LoginCodec.EnterGame(Config.Network.AdvertisedHost, Config.Network.LoginPorts[0]));

    [Handler(MethodId.AskCloseConnectionToGate, HandlerPacketKind.Invoke)]
    private Task GateAskCloseConnection(Connection conn, UxRpcMessage msg) => conn.ReturnAsync(msg, 0u);

    [Handler(MethodId.GetServerTime)]
    private async Task GateGetServerTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.IsInvoke)
        {
            await conn.ReturnEmptyOkAsync(msg);
            return;
        }

        var args = msg.GetArgs<GameMethods.GetServerTime>();
        await conn.NotifyAsync(MethodId.SendServerTime, LoginCodec.ServerTime(args.clientUnixTime));
    }

    [Handler(MethodId.GetFriendApplicationListToMe, HandlerPacketKind.Invoke)]
    [Handler(MethodId.GetAllChatGroupLatestMessage, HandlerPacketKind.Invoke)]
    [Handler(MethodId.GetSimplePlayerInfoByPidList, HandlerPacketKind.Invoke)]
    private Task GateEmptyList(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, new List<uint>());

    [Handler(MethodId.QuerySkey, HandlerPacketKind.Invoke)]
    private Task QuerySkey(Connection conn, UxRpcMessage msg) => conn.ReturnAsync(msg, Config.Player.Skey);

    [Handler(MethodId.ReportNetworkQuality, HandlerPacketKind.Notify)]
    private static void ReportNetworkQuality4229938(Connection conn, UxRpcMessage msg) { }

    [Handler(MethodId.DavinciCode, HandlerPacketKind.Notify)]
    private static void DavinciCode(Connection conn, UxRpcMessage msg) { }

    [Handler(MethodId.Login, HandlerPacketKind.Invoke)]
    private async Task GateLogin(Connection conn, UxRpcMessage msg)
    {
        
        
        _gateSessions?.Touch(conn.Session);
        conn.Log.Info("[GATE] authenticated session registered for IMasterToClient S2C");
        await conn.ReturnEmptyOkAsync(msg);
        await conn.NotifyAsync(MethodId.SendServerTime, LoginCodec.ServerTime());
        await PushGameSwitchesAsync(conn);
        await conn.NotifyAsync(MethodId.SyncPlayerGameServerInfo,
            LoginCodec.GameServerInfo(Config.Network.AdvertisedHost, Config.Network.GamePort));
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private async Task PushGameSwitchesAsync(Connection conn)
    {
        var settings = Config.Gameplay.GameSwitch;
        if (!settings.Enabled)
        {
            conn.Log.Warn("[SWITCH] gameplay.gameSwitch.enabled=false —— 不下发 GameSwitch，"
                + "客户端所有 C# 开关将保持 false（车/NPC/交通灯都可能不正常）");
            return;
        }

        var framing = GameSwitchCodec.ParseFraming(settings.Framing);
        var body = GameSwitchCodec.BuildPush(settings.Overrides, framing);
        
        
        
        await conn.NotifyRawAsync(MethodId.SyncGameSwitchToClient_3, body);
        conn.Log.Info(
            $"[SWITCH] SyncGameSwitchToClient(53940944) 已下发 {GameSwitchCatalog.Count} 个开关"
            + $"（开启 {GameSwitchCatalog.EnabledCount} / 关闭 {GameSwitchCatalog.Count - GameSwitchCatalog.EnabledCount}，"
            + $"帧格式 {framing}，{body.Length} 字节 —— 期望线上 body 等于此值，不能多 3）");
    }
}
