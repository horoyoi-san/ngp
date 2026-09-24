using Ananta.SDK.Logging;
using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.Configuration;
using Ananta.Server.Handlers.Game;
using Ananta.Server.State;
using Ananta.Server.Handlers.LoginGate;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.Network;

namespace Ananta.Server.App;

internal sealed class PrivateServerApplication(PrivateServerConfig config)
{
    internal async Task RunAsync(CancellationToken cancellationToken)
    {
        var projectRoot = Path.GetDirectoryName(PrivateServerConfigStore.ResolveProjectPath(config.Logging.Directory)) ?? ".";
        AccountStore.Initialize(Path.GetFullPath(Path.Combine(projectRoot, "data", "accounts")));

        
        
        

        var gateSessions = new GateSessionHub();
        var gameSessions = new GameSessionHub();
        var loginRouter = new LoginGateRouter(gateSessions).Build();
        var gameRouter = new GameRouter(gateSessions).Build();
        var loginPortA = config.Network.LoginPorts[0];
        var loginPortB = config.Network.LoginPorts[1];
        var bindHost = config.Network.BindHost;

        var servers = new[]
        {
            CreateServer("login-0", bindHost, loginPortA, loginRouter),
            CreateServer("login-1", bindHost, loginPortB, loginRouter),
            CreateServer("game", bindHost, config.Network.GamePort, gameRouter, gameSessions),
        };

        
        using var debugApi = config.Debug.Enabled ? new DebugApiServer(config, gameSessions) : null;
        var webInfo = "web=off";
        if (debugApi is not null)
        {
            try
            {
                debugApi.Start();
                webInfo = $"web=http://{config.Debug.Host}:{config.Debug.Port}/";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DEBUG-API] disabled for this run: {ex.Message}");
            }
        }

        
        RuntimeLogs.EndBootstrapQuietMode();
        
        var banner = config.Ui.UidLabel.Enabled && !string.IsNullOrWhiteSpace(config.Ui.UidLabel.Text)
            ? config.Ui.UidLabel.Text
            : "Ananta Private Server";
        Console.WriteLine($"[READY] {banner} | client={config.Client.Version} | pid={Profile.PlayerPid} | login={config.Network.AdvertisedHost}:{loginPortA},{loginPortB} | game=:{config.Network.GamePort}");
        var savedColor = Console.ForegroundColor;
        try
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine(webInfo == "web=off" ? "[Debug Panel] off" : $"[Debug Panel] http://{config.Debug.Host}:{config.Debug.Port}/");
        }
        finally { Console.ForegroundColor = savedColor; }

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
