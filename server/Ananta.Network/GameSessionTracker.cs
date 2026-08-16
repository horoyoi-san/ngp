using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer
{
    public static class GameSessionTracker
    {
        private static readonly List<SessionRecord> s_sessions = new();
        private static readonly object s_lock = new();
        private const int MaxSessionHistory = 100; // Prevent memory leak

        public class SessionRecord
        {
            public int SessionId { get; set; }
            public ulong Pid { get; set; }
            public string RemoteEndPoint { get; set; }
            public DateTime ConnectTime { get; set; }
            public DateTime? DisconnectTime { get; set; }
            public double DurationSeconds => DisconnectTime.HasValue
                ? (DisconnectTime.Value - ConnectTime).TotalSeconds
                : (DateTime.Now - ConnectTime).TotalSeconds;
            public string DisconnectReason { get; set; }
            public List<SessionEvent> Events { get; set; } = new();
        }

        public class SessionEvent
        {
            public DateTime Timestamp { get; set; }
            public string EventType { get; set; }
            public string Details { get; set; }
        }

        private static int s_nextSessionId = 1;
        private static readonly Dictionary<System.Net.Sockets.Socket, int> s_socketToSession = new();

        public static int OnConnected(Socket socket)
        {
            var record = new SessionRecord
            {
                SessionId = s_nextSessionId++,
                RemoteEndPoint = socket.RemoteEndPoint?.ToString() ?? "unknown",
                ConnectTime = DateTime.Now,
                DisconnectReason = "active",
            };

            record.Events.Add(new SessionEvent
            {
                Timestamp = record.ConnectTime,
                EventType = "CONNECT",
                Details = $"Client connected from {record.RemoteEndPoint}"
            });

            lock (s_lock)
            {
                s_sessions.Add(record);
                s_socketToSession[socket] = record.SessionId;

                // Trim old sessions to prevent memory leak
                if (s_sessions.Count > MaxSessionHistory)
                {
                    // Remove oldest closed sessions first
                    var toRemove = s_sessions.Where(s => s.DisconnectTime != null)
                        .OrderBy(s => s.DisconnectTime)
                        .Take(s_sessions.Count - MaxSessionHistory)
                        .ToList();

                    foreach (var session in toRemove)
                    {
                        s_sessions.Remove(session);
                        if (session.SessionId < s_nextSessionId)
                            s_nextSessionId = session.SessionId; // Keep IDs low
                    }
                }
            }

            Console.WriteLine($"[SessionTracker] Session #{record.SessionId} STARTED from {record.RemoteEndPoint}");
            return record.SessionId;
        }

        public static void OnDisconnected(Socket socket, string reason = "connection_lost")
        {
            lock (s_lock)
            {
                if (socket != null && s_socketToSession.TryGetValue(socket, out int sessionId))
                {
                    var record = s_sessions.Find(s => s.SessionId == sessionId);
                    if (record != null && record.DisconnectTime == null)
                    {
                        record.DisconnectTime = DateTime.Now;
                        record.DisconnectReason = reason;
                        record.Events.Add(new SessionEvent
                        {
                            Timestamp = record.DisconnectTime.Value,
                            EventType = "DISCONNECT",
                            Details = $"Client disconnected. Reason: {reason}. Duration: {record.DurationSeconds:F1}s"
                        });
                        Console.WriteLine($"[SessionTracker] Session #{sessionId} ENDED ({reason}) — duration: {record.DurationSeconds:F1}s");
                    }
                    s_socketToSession.Remove(socket);
                }
            }
        }

        public static void LogEvent(Socket socket, string eventType, string details)
        {
            lock (s_lock)
            {
                if (socket != null && s_socketToSession.TryGetValue(socket, out int sessionId))
                {
                    var record = s_sessions.Find(s => s.SessionId == sessionId);
                    if (record != null)
                    {
                        record.Events.Add(new SessionEvent
                        {
                            Timestamp = DateTime.Now,
                            EventType = eventType,
                            Details = details
                        });
                        Console.WriteLine($"[SessionTracker] Session #{sessionId} | {eventType} | {details}");
                    }
                }
            }
        }

        public static void SetPid(Socket socket, ulong pid)
        {
            lock (s_lock)
            {
                if (socket != null && s_socketToSession.TryGetValue(socket, out int sessionId))
                {
                    var record = s_sessions.Find(s => s.SessionId == sessionId);
                    if (record != null)
                    {
                        record.Pid = pid;
                        LogEvent(socket, "LOGIN", $"Player PID={pid} logged in");
                    }
                }
            }
        }

        public static string GetReport()
        {
            lock (s_lock)
            {
                if (s_sessions.Count == 0)
                    return "No session data recorded yet.";

                var sb = new StringBuilder();
                sb.AppendLine($"=== Game Session Report ===");
                sb.AppendLine($"Total sessions tracked: {s_sessions.Count}");
                sb.AppendLine($"Active sessions: {s_sessions.Count(s => s.DisconnectTime == null)}");
                sb.AppendLine();

                var active = s_sessions.Where(s => s.DisconnectTime == null).ToList();
                var closed = s_sessions.Where(s => s.DisconnectTime != null).OrderByDescending(s => s.DisconnectTime).Take(20).ToList();

                if (active.Count > 0)
                {
                    sb.AppendLine($"--- Active Sessions ({active.Count}) ---");
                    foreach (var s in active)
                    {
                        sb.AppendLine($"  [#{s.SessionId}] PID={s.Pid} | {s.RemoteEndPoint} | connected {s.ConnectTime:HH:mm:ss} | running {s.DurationSeconds:F0}s | events: {s.Events.Count}");
                    }
                    sb.AppendLine();
                }

                if (closed.Count > 0)
                {
                    sb.AppendLine($"--- Recent Closed Sessions (last {closed.Count}) ---");
                    foreach (var s in closed)
                    {
                        sb.AppendLine($"  [#{s.SessionId}] PID={s.Pid} | {s.RemoteEndPoint}");
                        sb.AppendLine($"    Connect:    {s.ConnectTime:yyyy-MM-dd HH:mm:ss}");
                        sb.AppendLine($"    Disconnect: {s.DisconnectTime:yyyy-MM-dd HH:mm:ss}");
                        sb.AppendLine($"    Duration:   {s.DurationSeconds:F1}s");
                        sb.AppendLine($"    Reason:     {s.DisconnectReason}");
                        sb.AppendLine($"    Events ({s.Events.Count}):");
                        foreach (var e in s.Events.Take(10))
                        {
                            sb.AppendLine($"      [{e.Timestamp:HH:mm:ss}] {e.EventType} — {e.Details}");
                        }
                        if (s.Events.Count > 10)
                            sb.AppendLine($"      ... and {s.Events.Count - 10} more events");
                        sb.AppendLine();
                    }
                }

                return sb.ToString();
            }
        }

        public static string ExportToFile()
        {
            string report = GetReport();
            string fileName = $"session_report_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
            string filePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);

            lock (s_lock)
            {
                var sb = new StringBuilder();
                sb.AppendLine(report);
                sb.AppendLine();
                sb.AppendLine("=== Full Event Log ===");
                foreach (var session in s_sessions)
                {
                    sb.AppendLine($"Session #{session.SessionId} — {session.RemoteEndPoint} — {session.ConnectTime:yyyy-MM-dd HH:mm:ss} to {session.DisconnectTime?.ToString("yyyy-MM-dd HH:mm:ss") ?? "ACTIVE"}");
                    foreach (var e in session.Events)
                    {
                        sb.AppendLine($"  [{e.Timestamp:yyyy-MM-dd HH:mm:ss.fff}] {e.EventType} | {e.Details}");
                    }
                    sb.AppendLine();
                }
                File.WriteAllText(filePath, sb.ToString());
            }

            return filePath;
        }

        public static void Clear()
        {
            lock (s_lock)
            {
                s_sessions.Clear();
                s_socketToSession.Clear();
            }
            Console.WriteLine("[SessionTracker] All session data cleared.");
        }

        public static int ActiveCount
        {
            get { lock (s_lock) { return s_sessions.Count(s => s.DisconnectTime == null); } }
        }

        public static int TotalCount
        {
            get { lock (s_lock) { return s_sessions.Count; } }
        }

        public static SessionRecord GetSession(int index)
        {
            lock (s_lock)
            {
                if (index < 0 || index >= s_sessions.Count) return null;
                return s_sessions[index];
            }
        }
    }
}
