using System;
using System.Diagnostics;
using System.Threading;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Automatic Memory Manager - monitors memory usage and performs periodic cleanup.
    /// 
    /// Features:
    /// - Periodic garbage collection based on memory pressure
    /// - Automatic cache cleanup when memory is high
    /// - Memory usage monitoring and logging
    /// - Configurable thresholds and intervals
    /// </summary>
    public static class MemoryManager
    {
        private static Timer _monitorTimer;
        private static bool _running = false;

        // Memory thresholds (in MB)
        private const long LowMemoryThresholdMB = 500;   // 500MB - start light cleanup
        private const long MediumMemoryThresholdMB = 1000; // 1GB - start aggressive cleanup
        private const long HighMemoryThresholdMB = 1500;   // 1.5GB - force full GC

        // Monitoring intervals
        private const int MonitorIntervalMs = 30000; // Check every 30 seconds
        private const int AggressiveGCIntervalMs = 60000; // Force full GC every 60s if memory is high

        private static long _lastFullGCTime = 0;
        private static long _totalGCCalls = 0;
        private static long _totalMemoryFreed = 0;

        /// <summary>
        /// Start the memory manager. Safe to call multiple times.
        /// </summary>
        public static void Start()
        {
            if (_running) return;
            _running = true;

            _monitorTimer = new Timer(OnMonitorTick, null, MonitorIntervalMs, MonitorIntervalMs);
            Console.WriteLine("[MemoryManager] Started (monitoring every 30s, thresholds: 500MB/1GB/1.5GB)");
        }

        /// <summary>
        /// Stop the memory manager.
        /// </summary>
        public static void Stop()
        {
            _running = false;
            _monitorTimer?.Dispose();
            _monitorTimer = null;
            Console.WriteLine("[MemoryManager] Stopped");
        }

        static void OnMonitorTick(object state)
        {
            if (!_running) return;

            try
            {
                var currentMemory = GC.GetTotalMemory(false) / (1024 * 1024); // MB
                var memoryBefore = currentMemory;

                Console.WriteLine($"[MemoryManager] Current memory: {currentMemory}MB, GC calls: {_totalGCCalls}, Total freed: {_totalMemoryFreed}MB");

                // Determine cleanup level based on memory pressure
                if (currentMemory >= HighMemoryThresholdMB)
                {
                    Console.WriteLine($"[MemoryManager] HIGH memory pressure ({currentMemory}MB), forcing full GC");
                    PerformFullCleanup();
                }
                else if (currentMemory >= MediumMemoryThresholdMB)
                {
                    Console.WriteLine($"[MemoryManager] MEDIUM memory pressure ({currentMemory}MB), performing aggressive cleanup");
                    PerformAggressiveCleanup();
                }
                else if (currentMemory >= LowMemoryThresholdMB)
                {
                    Console.WriteLine($"[MemoryManager] LOW memory pressure ({currentMemory}MB), performing light cleanup");
                    PerformLightCleanup();
                }

                // Periodic full GC to prevent memory buildup (every 60s)
                long now = Environment.TickCount64;
                if (now - _lastFullGCTime > AggressiveGCIntervalMs)
                {
                    Console.WriteLine("[MemoryManager] Periodic full GC");
                    PerformFullCleanup();
                    _lastFullGCTime = now;
                }

                var memoryAfter = GC.GetTotalMemory(false) / (1024 * 1024);
                var freed = memoryBefore - memoryAfter;
                if (freed > 0)
                {
                    _totalMemoryFreed += freed;
                    Console.WriteLine($"[MemoryManager] Freed {freed}MB in this cycle");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[MemoryManager] Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Light cleanup - Gen 0 GC only, minimal impact.
        /// </summary>
        static void PerformLightCleanup()
        {
            GC.Collect(0, GCCollectionMode.Optimized);
            _totalGCCalls++;
        }

        /// <summary>
        /// Aggressive cleanup - Gen 0+1 GC, clears caches.
        /// </summary>
        static void PerformAggressiveCleanup()
        {
            GC.Collect(1, GCCollectionMode.Optimized);
            GC.WaitForPendingFinalizers();
            _totalGCCalls++;

            // Clear caches that might be holding memory
            ClearCaches();
        }

        /// <summary>
        /// Full cleanup - All generations, forces complete memory release.
        /// </summary>
        static void PerformFullCleanup()
        {
            GC.Collect(2, GCCollectionMode.Forced, true);
            GC.WaitForPendingFinalizers();
            GC.Collect(2, GCCollectionMode.Forced, true);
            _totalGCCalls++;

            // Clear all caches
            ClearCaches();
        }

        /// <summary>
        /// Clear various caches throughout the application.
        /// </summary>
        static void ClearCaches()
        {
            // Clear NPC caches if they exist
            try
            {
                var server = AnantaTestGameServer.Server.Instance;
                if (server != null)
                {
                    lock (server.Connections)
                    {
                        foreach (var conn in server.Connections)
                        {
                            conn.InvalidateNpcCache();
                        }
                    }
                }
            }
            catch { }

            // Clear RPC dump if enabled
            if (AnantaTestGameServer.RpcDumpService.Enabled)
            {
                AnantaTestGameServer.RpcDumpService.Clear();
            }

            // Clear Lua error collector if enabled
            if (AnantaTestGameServer.LuaErrorCollector.Enabled)
            {
                AnantaTestGameServer.LuaErrorCollector.Clear();
            }

            // Clear session tracker old sessions
            AnantaTestGameServer.GameSessionTracker.Clear();
        }

        /// <summary>
        /// Get current memory statistics.
        /// </summary>
        public static string GetMemoryStats()
        {
            var currentMemory = GC.GetTotalMemory(false) / (1024 * 1024);
            var processMemory = Process.GetCurrentProcess().WorkingSet64 / (1024 * 1024);
            
            return $"Memory: {currentMemory}MB (managed), {processMemory}MB (process) | " +
                   $"GC calls: {_totalGCCalls} | Total freed: {_totalMemoryFreed}MB | " +
                   $"Gen0: {GC.CollectionCount(0)}, Gen1: {GC.CollectionCount(1)}, Gen2: {GC.CollectionCount(2)}";
        }

        /// <summary>
        /// Force immediate memory cleanup (call manually if needed).
        /// </summary>
        public static void ForceCleanup()
        {
            Console.WriteLine("[MemoryManager] Manual cleanup requested");
            PerformFullCleanup();
        }
    }
}
