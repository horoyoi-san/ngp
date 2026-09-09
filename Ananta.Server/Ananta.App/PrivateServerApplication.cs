using Ananta.SDK.Logging;
using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.Configuration;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Handlers.LoginGate;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.Network;

namespace Ananta.Server.App;

/// <summary>
/// Wires configuration, RPC routers and TCP listeners together.
/// Game behavior lives in Ananta.Handlers; protocol encoding lives in Ananta.Core/Protocol/Client4229938.
/// </summary>
internal sealed class PrivateServerApplication(PrivateServerConfig config)
{
    internal async Task RunAsync(CancellationToken cancellationToken)
    {
        var gateSessions = new GateSessionHub();
        var loginRouter = new LoginGateRouter(gateSessions).Build();
        var gameRouter = new GameRouter(gateSessions).Build();
        var loginPortA = config.Network.LoginPorts[0];
        var loginPortB = config.Network.LoginPorts[1];
        var bindHost = config.Network.BindHost;

        var servers = new[]
        {
            CreateServer("login-0", bindHost, loginPortA, loginRouter),
            CreateServer("login-1", bindHost, loginPortB, loginRouter),
            CreateServer("game", bindHost, config.Network.GamePort, gameRouter),
        };

        // Bootstrap diagnostics stay in console-latest/archive; runtime output becomes visible here.
        RuntimeLogs.EndBootstrapQuietMode();
        Console.WriteLine($"[READY] นี่คือเวอร์ชั่น DEV ที่ไม่ได้รับคุณภาพจากเกม Ananta GAY | client={config.Client.Version} | pid={Profile.PlayerPid} | login={config.Network.AdvertisedHost}:{loginPortA},{loginPortB} | game=:{config.Network.GamePort}");

        var serverTasks = servers.Select(server => server.RunAsync(cancellationToken));
        await Task.WhenAll(serverTasks);
    }

    private static TcpServer CreateServer(string name, string host, int port, RpcRouter router, GameSessionHub? gameSessions = null)
        => new(name, host, port, router,
            async (session, frame, token) =>
            {
                gameSessions?.Touch(session);
                await RpcFrameDispatcher.DispatchAsync(router, session, frame, token);
            });
}
