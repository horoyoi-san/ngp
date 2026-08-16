using System;
using System.Collections.Generic;
using System.Threading;
using AnantaTestGameServer.Configs;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Background tick service that periodically updates game state.
    /// Runs on a dedicated background thread with a configurable interval.
    /// Currently dispatches to NpcBehaviorManager for NPC AI updates.
    /// </summary>
    public static class GameTickService
    {
        private static Timer _tickTimer;
        private static bool _running = false;

        /// <summary>
        /// Tick interval in milliseconds. Configurable via world_config.json.
        /// </summary>
        public static int TickIntervalMs = GameConfig.TickIntervalMs > 0 ? GameConfig.TickIntervalMs : 2000;

        /// <summary>
        /// Start the game tick loop. Safe to call multiple times (idempotent).
        /// </summary>
        public static void Start()
        {
            if (_running) return;
            _running = true;

            _tickTimer = new Timer(OnTick, null, TickIntervalMs, TickIntervalMs);
            Console.WriteLine($"[GameTick] Started (interval={TickIntervalMs}ms)");
        }

        /// <summary>
        /// Stop the game tick loop.
        /// </summary>
        public static void Stop()
        {
            _running = false;
            _tickTimer?.Dispose();
            _tickTimer = null;
            Console.WriteLine("[GameTick] Stopped");
        }

        static void OnTick(object state)
        {
            if (!_running) return;

            try
            {
                var server = AnantaTestGameServer.Server.Instance;
                if (server == null) return;

                // Snapshot connections to avoid holding lock during processing
                List<Connection> connections;
                lock (server.Connections)
                {
                    connections = new List<Connection>(server.Connections);
                }

                foreach (var conn in connections)
                {
                    try
                    {
                        // NPC behavior AI tick
                        NpcBehaviorManager.Tick(conn);

                        // Vehicle driving AI tick (traffic vehicles)
                        VehicleDrivingAI.Tick(conn);

                        // Metro system tick (station timing, NPC passengers, periodic sync)
                        MetroManager.Tick(conn);

                        // Vehicle sync tree tick (periodic full-state push, stale cleanup)
                        VehicleSyncManager.Tick(conn);

                        // Mass entity manager tick (crowd zones, intersections, surround zone)
                        MassEntityManager.Tick(conn);

                        // Urban crowd spawner tick (pedestrian density maintenance)
                        UrbanCrowdSpawner.Tick(conn);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[GameTick] Error ticking connection {conn.Pid}: {ex.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GameTick] Tick error: {ex.Message}");
            }
        }
    }
}
