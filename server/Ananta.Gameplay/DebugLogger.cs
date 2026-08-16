using System;
using System.IO;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Debug logger that writes to a separate file for monitoring.
    /// Logs are written to logs/debug.log
    /// </summary>
    public static class DebugLogger
    {
        private static readonly string LogPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "logs", "debug.log");
        private static readonly object _lock = new object();
        private static bool _enabled = true;

        static DebugLogger()
        {
            // Ensure logs directory exists
            var logDir = Path.GetDirectoryName(LogPath);
            if (!Directory.Exists(logDir))
            {
                Directory.CreateDirectory(logDir);
            }

            // Write initial log to confirm logger is working
            Log("DebugLogger initialized");
        }

        public static bool Enabled
        {
            get => _enabled;
            set => _enabled = value;
        }

        public static void Log(string message)
        {
            if (!_enabled) return;

            lock (_lock)
            {
                var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
                File.AppendAllText(LogPath, $"[{timestamp}] {message}\n");
            }
        }

        public static void Clear()
        {
            lock (_lock)
            {
                if (File.Exists(LogPath))
                {
                    File.WriteAllText(LogPath, "");
                }
            }
        }
    }
}
