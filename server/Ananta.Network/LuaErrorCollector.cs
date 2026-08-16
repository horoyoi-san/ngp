using AnantaTestGameServer.Messages;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UX.RPC.Protocol;

namespace AnantaTestGameServer
{
    public static class LuaErrorCollector
    {
        public static bool Enabled { get; set; } = false;

        private static readonly List<LuaErrorEntry> s_errors = new();
        private static readonly object s_lock = new();
        private const int MaxEntries = 500;

        public class LuaErrorEntry
        {
            public DateTime Timestamp { get; set; }
            public int MethodId { get; set; }
            public string MethodName { get; set; }
            public ulong Pid { get; set; }
            public string Message { get; set; }
            public string HexDump { get; set; }
        }

        public static void LogLuaRpc(Connection conn, UxRpcMessage msg)
        {
            if (!Enabled) return;

            string methodName = "UNKNOWN";
            try
            {
                methodName = Enum.GetName(typeof(MethodId), msg.RpcMethodId) ?? $"RAW_{msg.RpcMethodId}";
            }
            catch { methodName = $"RAW_{msg.RpcMethodId}"; }

            string hex = msg.Args != null && msg.Args.Length > 0
                ? BitConverter.ToString(msg.Args).Replace("-", " ")
                : "(empty)";

            string message = $"[LuaRPC] PID={conn?.Pid ?? 0} Method={methodName}({msg.RpcMethodId}) Mode={msg.Mode} InvokeId={msg.RpcInvokeId} ArgsLen={msg.Args?.Length ?? 0}";

            if (msg.Mode == UxRpcPacketMode.Return)
            {
                uint retcode = msg.RpcRetcode;
                if (retcode != 0)
                    message += $" Retcode={retcode} **ERROR**";
            }

            var entry = new LuaErrorEntry
            {
                Timestamp = DateTime.Now,
                MethodId = msg.RpcMethodId,
                MethodName = methodName,
                Pid = conn?.Pid ?? 0UL,
                Message = message,
                HexDump = hex
            };

            lock (s_lock)
            {
                s_errors.Add(entry);
                if (s_errors.Count > MaxEntries)
                    s_errors.RemoveAt(0);
            }

            Console.WriteLine(message);
        }

        public static void LogLuaError(Connection conn, string source, string error, string stackTrace = "")
        {
            if (!Enabled) return;

            string message = $"[LuaError] PID={conn?.Pid ?? 0} Source={source} Error={error}";
            if (!string.IsNullOrEmpty(stackTrace))
                message += $" Stack={stackTrace}";

            var entry = new LuaErrorEntry
            {
                Timestamp = DateTime.Now,
                MethodId = 0,
                MethodName = source,
                Pid = conn?.Pid ?? 0UL,
                Message = message,
                HexDump = ""
            };

            lock (s_lock)
            {
                s_errors.Add(entry);
                if (s_errors.Count > MaxEntries)
                    s_errors.RemoveAt(0);
            }

            Console.WriteLine(message);
        }

        public static string GetReport()
        {
            lock (s_lock)
            {
                if (s_errors.Count == 0)
                    return "No Lua errors/RPCs collected.";

                var sb = new StringBuilder();
                sb.AppendLine($"Lua Error Collector — {s_errors.Count} entries (max {MaxEntries})");
                sb.AppendLine($"{"Timestamp",-20} {"PID",-8} {"Method",-40} {"Info"}");
                sb.AppendLine(new string('-', 120));

                foreach (var e in s_errors.TakeLast(100))
                {
                    sb.AppendLine($"{e.Timestamp:HH:mm:ss.fff}      {e.Pid,-8} {e.MethodName,-40} {e.Message}");
                }

                if (s_errors.Count > 100)
                    sb.AppendLine($"\n... and {s_errors.Count - 100} more entries.");

                return sb.ToString();
            }
        }

        public static string ExportToFile()
        {
            string dir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "logs");
            Directory.CreateDirectory(dir);
            string path = Path.Combine(dir, $"lua_errors_{DateTime.Now:yyyyMMdd_HHmmss}.txt");

            lock (s_lock)
            {
                var sb = new StringBuilder();
                sb.AppendLine($"Lua Error Collector Export — {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
                sb.AppendLine($"Total entries: {s_errors.Count}");
                sb.AppendLine();

                foreach (var e in s_errors)
                {
                    sb.AppendLine(e.Message);
                    if (!string.IsNullOrEmpty(e.HexDump) && e.HexDump != "(empty)")
                        sb.AppendLine($"  Hex: {e.HexDump}");
                }

                File.WriteAllText(path, sb.ToString());
            }

            return path;
        }

        public static void Clear()
        {
            lock (s_lock)
            {
                s_errors.Clear();
            }
        }
    }
}
