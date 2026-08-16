namespace AnantaTestGameServer;

/// <summary>
/// HTTP server for GM web panel (port 17666).
/// Migrated from Server.Routing.cs in the old project.
/// </summary>
public class GmHttpServer
{
    private readonly int _port;
    
    public GmHttpServer(int port = 17666)
    {
        _port = port;
    }
    
    public void Start()
    {
        // TODO: Migrate HTTP routing from Server.Routing.cs
        Console.WriteLine($"[GmHttpServer] GM panel available at http://localhost:{_port}");
    }
}
