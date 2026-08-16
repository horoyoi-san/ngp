namespace AnantaTestGameServer;

/// <summary>
/// Orchestrates server startup sequence.
/// Delegates to Server.Start() in Ananta.Network which handles:
/// Logger, ConfigManager, DestructibleObjectManager, SceneItemPlacementLoader,
/// NotifyManager handler registration, TCP listeners, GM tool, GameTick, LoginDispatch.
/// </summary>
public class ServerBootstrap
{
    public void Start()
    {
        var server = new Server();
        server.Start();
    }
}
