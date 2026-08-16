using AnantaTestGameServer.Messages;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;

namespace AnantaTestGameServer
{
    public static class RpcDumpService
    {
        public static bool DebugMode { get; set; } = false;
        public static bool Enabled { get; set; } = false;

        private static readonly List<DumpedRpc> s_unhandledRpcs = new();
        private static readonly object s_lock = new();
        private const int MaxEntries = 500; // Prevent memory leak

        public class DumpedRpc
        {
            public DateTime Timestamp { get; set; }
            public int MethodId { get; set; }
            public string MethodName { get; set; }
            public UxRpcPacketMode Mode { get; set; }
            public int InvokeId { get; set; }
            public string HexDump { get; set; }
            public int PayloadLength { get; set; }
        }

        public static void LogUnhandledRpc(UxRpcMessage msg)
        {
            if (!Enabled) return;
            string hex = msg.Args != null && msg.Args.Length > 0
                ? BitConverter.ToString(msg.Args).Replace("-", " ")
                : "(empty)";

            string methodName = "UNKNOWN";
            try
            {
                methodName = Enum.GetName(typeof(MethodId), msg.RpcMethodId) ?? $"RAW_{msg.RpcMethodId}";
            }
            catch
            {
                methodName = $"RAW_{msg.RpcMethodId}";
            }

            var dumped = new DumpedRpc
            {
                Timestamp = DateTime.Now,
                MethodId = msg.RpcMethodId,
                MethodName = methodName,
                Mode = msg.Mode,
                InvokeId = msg.RpcInvokeId,
                HexDump = hex,
                PayloadLength = msg.Args?.Length ?? 0
            };

            lock (s_lock)
            {
                s_unhandledRpcs.Add(dumped);

                // Trim old entries to prevent memory leak
                if (s_unhandledRpcs.Count > MaxEntries)
                {
                    s_unhandledRpcs.RemoveAt(0);
                }
            }

            if (DebugMode)
            {
                Console.WriteLine($"[RpcDump] UNHANDLED #{s_unhandledRpcs.Count}: {methodName} (ID={msg.RpcMethodId}) Mode={msg.Mode} Len={dumped.PayloadLength}");
                if (DebugMode && msg.Args != null && msg.Args.Length > 0)
                {
                    string hexPreview = hex.Length > 120 ? hex.Substring(0, 120) + "..." : hex;
                    Console.WriteLine($"[RpcDump]   Args: {hexPreview}");
                }
            }
        }

        public static string GetDumpReport(bool includeHex = true)
        {
            lock (s_lock)
            {
                if (s_unhandledRpcs.Count == 0)
                    return "No unhandled RPCs captured yet.";

                var sb = new StringBuilder();
                sb.AppendLine($"=== RPC Dump Report === Total: {s_unhandledRpcs.Count} unhandled calls");
                sb.AppendLine($"Debug Mode: {(DebugMode ? "ON" : "OFF")}");
                sb.AppendLine();

                var grouped = s_unhandledRpcs
                    .GroupBy(r => r.MethodName)
                    .Select(g => new { Method = g.Key, Count = g.Count(), First = g.First() })
                    .OrderByDescending(g => g.Count)
                    .ToList();

                sb.AppendLine("--- Summary by Method ---");
                foreach (var g in grouped)
                {
                    sb.AppendLine($"  {g.Method,-55} (ID={g.First.MethodId,10}) x{g.Count,4}");
                }

                sb.AppendLine();
                sb.AppendLine("--- Full Log ---");
                for (int i = 0; i < s_unhandledRpcs.Count; i++)
                {
                    var r = s_unhandledRpcs[i];
                    sb.AppendLine($"[{i + 1}] {r.Timestamp:HH:mm:ss.fff} | {r.MethodName,-55} ID={r.MethodId,-10} Mode={r.Mode} InvokeId={r.InvokeId,-5} Len={r.PayloadLength,-4}");
                    if (includeHex && r.PayloadLength > 0)
                    {
                        string hex = r.HexDump;
                        int lines = (hex.Length + 47) / 48;
                        for (int li = 0; li < Math.Min(lines, 8); li++)
                        {
                            int start = li * 48;
                            int len = Math.Min(48, hex.Length - start);
                            sb.AppendLine($"      {hex.Substring(start, len)}");
                        }
                        if (lines > 8)
                            sb.AppendLine($"      ... ({lines - 8} more lines)");
                    }
                }

                return sb.ToString();
            }
        }

        public static string ExportToFile()
        {
            string report = GetDumpReport(includeHex: true);
            string fileName = $"rpc_dump_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
            string filePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
            File.WriteAllText(filePath, report);
            return filePath;
        }

        public static void Clear()
        {
            lock (s_lock)
            {
                s_unhandledRpcs.Clear();
            }
            Console.WriteLine("[RpcDump] Dump data cleared.");
        }

        public static int Count
        {
            get { lock (s_lock) { return s_unhandledRpcs.Count; } }
        }
    }
}
