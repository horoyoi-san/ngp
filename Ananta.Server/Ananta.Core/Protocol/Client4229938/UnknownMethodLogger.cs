using Ananta.Server.Configuration;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Durable log of every RPC method the server has no semantic handler for yet.
/// One line per call in logs/unknown-methods.log so future work can replay shapes
/// (method id + name, body length, hex prefix). Return behavior of callers is unchanged.
/// </summary>
internal static class UnknownMethodLogger
{
    private static readonly object SyncRoot = new();
    private static string? _logPath;

    /// <summary>Maximum body bytes rendered as hex per line (full length is always recorded).</summary>
    internal const int MaxHexBytesPerLine = 256;

    internal static void Log(string scope, string kind, uint methodId, byte[] body)
    {
        try
        {
            var path = LogPath;
            var name = Ananta.SDK.Logging.RpcMethodNames.Display(methodId);
            var stamp = DateTimeOffset.UtcNow.ToString("o");
            var shown = Math.Min(body.Length, MaxHexBytesPerLine);
            var hex = shown == 0 ? "-" : Convert.ToHexString(body, 0, shown);
            if (body.Length > shown)
                hex += "...";
            var line = $"{stamp} {kind} {name} id={methodId} bytes={body.Length} hex={hex}{Environment.NewLine}";
            lock (SyncRoot)
                File.AppendAllText(path, line);
        }
        catch
        {
            // Logging must never break the game session.
        }
    }

    private static string LogPath
    {
        get
        {
            if (_logPath is not null)
                return _logPath;
            lock (SyncRoot)
            {
                if (_logPath is not null)
                    return _logPath;
                string dir;
                try
                {
                    dir = PrivateServerConfigStore.ResolveProjectPath(
                        PrivateServerConfigStore.Current.Logging.Directory);
                }
                catch
                {
                    dir = Path.Combine(AppContext.BaseDirectory, "logs");
                }
                Directory.CreateDirectory(dir);
                _logPath = Path.Combine(dir, "unknown-methods.log");
                return _logPath;
            }
        }
    }

    /// <summary>Reads the last N lines for the admin panel tail viewer.</summary>
    internal static string[] Tail(int maxLines)
    {
        try
        {
            var path = LogPath;
            if (!File.Exists(path))
                return [];
            // Log is append-only and small; read all and slice the tail.
            var lines = File.ReadAllLines(path);
            return lines.Length <= maxLines ? lines : lines[^maxLines..];
        }
        catch
        {
            return [];
        }
    }
}
