using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Metro system manager — server-side simulation of metro trains.
    ///
    /// Handles:
    /// - Station timing (arrival, door open/close, departure) based on path data
    /// - NPC passenger binding/unbinding (SyncBindNpcToMetro, SyncUnbindNpcToMetro)
    /// - Dynamic metro lifecycle (SyncDestroyMetroInfos for trains going out of service)
    /// - Periodic SyncRunningMetroInfos push (every 5s)
    /// - SyncSubwayFare when player boards
    /// - SyncHideMetroStates for hide area updates
    /// - SyncAetherAIMetroNpcAdd for mid-session passenger spawns
    ///
    /// Integrates with GameTickService (called every 2s tick).
    /// Uses Connection.BuildRunningMetros() which now integrates with MetroPathSystem
    /// for waypoint-based paths with CatmullRom interpolation, sub-lines, and vertical paths.
    /// </summary>
    public static class MetroManager
    {
        // ======================== PATH DATA (STATIC) ========================

        /// <summary>
        /// Station timing data — when in the cycle the train arrives, and how long it waits.
        /// ArrivalTime is seconds into the cycle. WaitDuration is how long doors stay open.
        /// The last station's arrival + wait should ≈ cycle time (loops back to first).
        /// </summary>
        public class StationTiming
        {
            public int StationIndex;
            public string Name;
            public float ArrivalTime;     // seconds into cycle when train arrives
            public float WaitDuration;    // seconds doors stay open at station

            public StationTiming(int idx, string name, float arrival, float wait)
            {
                StationIndex = idx;
                Name = name;
                ArrivalTime = arrival;
                WaitDuration = wait;
            }
        }

        /// <summary>
        /// Metro line definition: cycle time + ordered station list.
        /// </summary>
        public class MetroLineData
        {
            public uint LineId;
            public string DisplayName;
            public float CycleSeconds;
            public List<StationTiming> Stations;
        }

        // 4 confirmed lines from vfc_387 bundle.
        // Original cycle times matching client expectations:
        //   L1/L2 = 300s (5min), L3/L4 = 240s (4min)
        static readonly MetroLineData[] LineDefinitions = new[]
        {
            // L1: Harbor/Bayshore (港湾线, S_OrangeLine) — 300s cycle, 8 stations
            new MetroLineData { LineId = 1, DisplayName = "港湾线 (Harbor)", CycleSeconds = 300, Stations = new() {
                new(0, "港湾起点",   0f,   25f), new(1, "海港站",    38f,  22f),
                new(2, "码头站",     70f,  22f), new(3, "滨海站",    102f, 22f),
                new(4, "灯塔站",     134f, 22f), new(5, "渔港站",    166f, 22f),
                new(6, "跨海站",     198f, 22f), new(7, "港湾终点",  244f, 25f),
            }},

            // L2: Central (中央线, S_GreenLine) — 300s cycle, 8 stations
            new MetroLineData { LineId = 2, DisplayName = "中央线 (Central)", CycleSeconds = 300, Stations = new() {
                new(0, "中央起点",   0f,   25f), new(1, "商业区",    38f,  22f),
                new(2, "公园站",     70f,  22f), new(3, "市政厅",    102f, 22f),
                new(4, "文化宫",     134f, 22f), new(5, "医院站",    166f, 22f),
                new(6, "学校站",     198f, 22f), new(7, "中央终点",  244f, 25f),
            }},

            // L3: East City (东城线, S_BlueEast) — 240s cycle, 7 stations
            new MetroLineData { LineId = 3, DisplayName = "东城线 (EastCity)", CycleSeconds = 240, Stations = new() {
                new(0, "东城起点",   0f,   25f), new(1, "科技园",    38f,  22f),
                new(2, "工业园",     72f,  22f), new(3, "新城站",    106f, 22f),
                new(4, "体育中心",   140f, 22f), new(5, "展览中心",  174f, 22f),
                new(6, "东城终点",   208f, 25f),
            }},

            // L4: Feisuo (飞索线, DynamicFeisuoLine) — 240s cycle, 6 stations
            new MetroLineData { LineId = 4, DisplayName = "飞索线 (Feisuo)", CycleSeconds = 240, Stations = new() {
                new(0, "飞索起点",   0f,   25f), new(1, "山谷站",    42f,  22f),
                new(2, "悬崖站",     82f,  22f), new(3, "瀑布站",    122f, 22f),
                new(4, "森林站",     162f, 22f), new(5, "飞索终点",  208f, 25f),
            }},
        };

        static readonly Dictionary<uint, MetroLineData> LinesByLineId;
        static readonly Random _rng = new Random();

        static MetroManager()
        {
            LinesByLineId = new Dictionary<uint, MetroLineData>();
            foreach (var line in LineDefinitions)
                LinesByLineId[line.LineId] = line;
        }

        // ======================== PER-TRAIN STATE ========================

        /// <summary>
        /// Tracks the simulation state for a single active train: station progress,
        /// door state, NPC passengers, and timing.
        /// </summary>
        class TrainSimState
        {
            public int TrainId;
            public uint LineId;
            public int TrainIndex;        // position within the line (0..N-1)
            public int CurrentStationIdx; // which station the train is at (or heading towards)
            public bool AtStation;        // true = doors open/waiting; false = in transit
            public float StationArrivalTime; // cycle-time when train arrived at current station
            public List<MetroPassenger> Passengers = new();
            public long LastStationChangeTick; // Environment.TickCount64 for transition cooldown
        }

        /// <summary>
        /// An NPC passenger bound to a train carriage.
        /// </summary>
        class MetroPassenger
        {
            public ulong NpcId;
            public uint FormworkId;
            public byte CarriageIndex;
            public int DestStationIdx; // station where this NPC will alight
        }

        // Per-connection active train states. Key = train ID.
        static readonly Dictionary<ulong, Dictionary<int, TrainSimState>> _connTrains = new();

        const int SyncIntervalMs = 3000;        // push SyncRunningMetroInfos every 3s (client animates locally)
        const int NpcTickIntervalMs = 15000;     // NPC passenger changes every 15s
        const int StationTransitionCooldownMs = 2000; // minimum ms between station transitions
        const float FareAmount = 2.0f;           // subway fare per ride
        const uint CrowdFormworkBase = 40968601u;
        const ulong PassengerIdBase = 4100000000000ul;
        static long _nextPassengerId = 0;

        // ======================== PUBLIC API ========================

        /// <summary>
        /// Get path data for a metro line. Returns null if line is not defined.
        /// </summary>
        public static MetroLineData GetLineData(uint lineId)
        {
            LinesByLineId.TryGetValue(lineId, out var data);
            return data;
        }

        /// <summary>
        /// Get all defined metro lines.
        /// </summary>
        public static IReadOnlyList<MetroLineData> GetAllLines() => LineDefinitions;

        /// <summary>
        /// Determine which station a train is at (or heading towards) given its elapsed time.
        /// Returns -1 if between stations or line data not found.
        /// </summary>
        public static int GetCurrentStation(uint lineId, float elapsedTime)
        {
            if (!LinesByLineId.TryGetValue(lineId, out var line)) return -1;
            var stations = line.Stations;
            if (stations.Count == 0) return -1;

            for (int i = stations.Count - 1; i >= 0; i--)
            {
                if (elapsedTime >= stations[i].ArrivalTime)
                {
                    // Check if still within dwell window
                    if (elapsedTime < stations[i].ArrivalTime + stations[i].WaitDuration)
                        return i; // at station
                    return -1; // departed, heading to next
                }
            }
            return -1;
        }

        /// <summary>
        /// Get the next station index after the given one (wraps around).
        /// </summary>
        public static int GetNextStation(uint lineId, int currentStationIdx)
        {
            if (!LinesByLineId.TryGetValue(lineId, out var line)) return 0;
            return (currentStationIdx + 1) % line.Stations.Count;
        }

        /// <summary>
        /// Check if a train is currently at a station (doors open).
        /// </summary>
        public static bool IsAtStation(uint lineId, float elapsedTime)
        {
            return GetCurrentStation(lineId, elapsedTime) >= 0;
        }

        /// <summary>
        /// Estimate time until next station arrival (seconds). Returns -1 if unknown.
        /// </summary>
        public static float TimeToNextStation(uint lineId, float elapsedTime)
        {
            if (!LinesByLineId.TryGetValue(lineId, out var line)) return -1;
            var stations = line.Stations;
            if (stations.Count == 0) return -1;

            for (int i = 0; i < stations.Count; i++)
            {
                if (stations[i].ArrivalTime > elapsedTime)
                    return stations[i].ArrivalTime - elapsedTime;
            }
            // Wrap around: next station is the first one in the next cycle
            return (line.CycleSeconds - elapsedTime) + stations[0].ArrivalTime;
        }

        /// <summary>
        /// Called when player boards a metro. Updates state and sends SyncSubwayFare.
        /// </summary>
        public static void OnPlayerBoardMetro(Connection conn, ulong metroId, int carriageIndex)
        {
            conn.CurrentMetroId = metroId;
            conn.CurrentMetroCarriage = carriageIndex;

            // Resolve line ID from train state
            if (_connTrains.TryGetValue(conn.Pid, out var trains) &&
                trains.TryGetValue((int)metroId, out var ts))
            {
                conn.CurrentMetroLineId = ts.LineId;
            }

            // Send subway fare notification
            SendNotify(conn, MethodId.SyncSubwayFare, new SyncSubwayFare()
            {
                fare = FareAmount,
                lineId = conn.CurrentMetroLineId,
            });

            Console.WriteLine($"[Metro] Player boarded: metro={metroId} carriage={carriageIndex} line={conn.CurrentMetroLineId}");
        }

        /// <summary>
        /// Called when player leaves a metro. Clears state.
        /// </summary>
        public static void OnPlayerLeaveMetro(Connection conn, ulong metroId)
        {
            ulong prev = conn.CurrentMetroId;
            conn.CurrentMetroId = 0;
            conn.CurrentMetroCarriage = -1;
            conn.CurrentMetroLineId = 0;
            Console.WriteLine($"[Metro] Player left: metro={prev}");
        }

        /// <summary>
        /// Called when client reports entering a station. Logs and updates state.
        /// </summary>
        public static void OnMetroEnterStation(Connection conn, ulong metroId, uint lineId, int stationIdx)
        {
            conn.CurrentMetroLineId = lineId;
            if (_connTrains.TryGetValue(conn.Pid, out var trains) &&
                trains.TryGetValue((int)metroId, out var ts))
            {
                ts.AtStation = true;
                ts.CurrentStationIdx = stationIdx;
            }
            Console.WriteLine($"[Metro] Enter station: metro={metroId} line={lineId} station={stationIdx}");
        }

        /// <summary>
        /// Called when client reports exiting a station. Logs and updates state.
        /// </summary>
        public static void OnMetroExitStation(Connection conn, ulong metroId, uint lineId, int stationIdx)
        {
            conn.CurrentMetroLineId = lineId;
            if (_connTrains.TryGetValue(conn.Pid, out var trains) &&
                trains.TryGetValue((int)metroId, out var ts))
            {
                ts.AtStation = false;
            }
            Console.WriteLine($"[Metro] Exit station: metro={metroId} line={lineId} station={stationIdx}");
        }

        // ======================== TICK (called by GameTickService) ========================

        public static void Tick(Connection conn)
        {
            if (!conn.MetroSimulationEnabled) return;
            if (conn.ActiveMetroLines.Count == 0) return;

            long now = Environment.TickCount64;

            // 1. Sync/rebuild train simulation states
            SyncTrainStates(conn);

            // 2. Simulate station transitions for trains not currently observed by client
            SimulateStationTransitions(conn, now);

            // 3. NPC passenger management (periodic)
            if (now - conn.LastMetroNpcTick > NpcTickIntervalMs)
            {
                conn.LastMetroNpcTick = now;
                UpdatePassengers(conn, now);
            }

            // 4. Periodic sync push
            if (now - conn.LastMetroSyncTime > SyncIntervalMs)
            {
                conn.LastMetroSyncTime = now;
                conn.PushMetroResync();
            }

            // 5. Debug logging for metro state
            if (now % 10000 < 2000) // Every ~10s
            {
                var runningMetros = conn.BuildRunningMetros();
                if (runningMetros.Count > 0)
                {
                    Console.WriteLine($"[Metro] Active trains: {runningMetros.Count}, Last sync: {now - conn.LastMetroSyncTime}ms ago");
                }
            }
        }

        // ======================== TRAIN STATE SYNC ========================

        /// <summary>
        /// Reconcile the train simulation states with the current BuildRunningMetros() output.
        /// Adds new trains, removes trains that are no longer active.
        /// </summary>
        static void SyncTrainStates(Connection conn)
        {
            if (!_connTrains.TryGetValue(conn.Pid, out var trains))
            {
                trains = new Dictionary<int, TrainSimState>();
                _connTrains[conn.Pid] = trains;
            }

            var runningMetros = conn.BuildRunningMetros();
            var activeIds = new HashSet<int>();

            foreach (var metro in runningMetros)
            {
                activeIds.Add(metro.Id);
                if (!trains.ContainsKey(metro.Id))
                {
                    // New train appeared (enabled via GM or initial state)
                    int trainIndex = activeIds.Count(t =>
                    {
                        if (trains.TryGetValue(t, out var ts2)) return ts2.LineId == metro.LineId;
                        return false;
                    });

                    trains[metro.Id] = new TrainSimState
                    {
                        TrainId = metro.Id,
                        LineId = metro.LineId,
                        TrainIndex = trainIndex,
                        CurrentStationIdx = 0,
                        AtStation = false,
                        StationArrivalTime = 0,
                        LastStationChangeTick = Environment.TickCount64,
                    };
                }
            }

            // Remove trains that are no longer active (line disabled or train count reduced)
            var removedIds = trains.Keys.Where(id => !activeIds.Contains(id)).ToList();
            if (removedIds.Count > 0)
            {
                // Unbind all passengers on removed trains
                foreach (var id in removedIds)
                {
                    if (trains.TryGetValue(id, out var ts))
                    {
                        foreach (var p in ts.Passengers)
                            SendUnbindNpc(conn, p.NpcId, (ulong)id);
                    }
                }

                // Send SyncDestroyMetroInfos for removed trains
                SendNotify(conn, MethodId.SyncDestroyMetroInfos, new SyncDestroyMetroInfos
                {
                    MetroIds = removedIds.ToList()
                });

                foreach (var id in removedIds)
                    trains.Remove(id);

                Console.WriteLine($"[Metro] Destroyed {removedIds.Count} train(s): {string.Join(",", removedIds)}");
            }
        }

        // ======================== STATION TRANSITIONS ========================

        /// <summary>
        /// For each active train, check if it has crossed into a new station based on
        /// its ElapsedTime. Only triggers transitions when the client hasn't already
        /// reported the event (to avoid double-firing).
        /// </summary>
        static void SimulateStationTransitions(Connection conn, long now)
        {
            if (!_connTrains.TryGetValue(conn.Pid, out var trains)) return;

            var runningMetros = conn.BuildRunningMetros();
            var metroMap = runningMetros.ToDictionary(m => m.Id, m => m);

            foreach (var kvp in trains)
            {
                var trainId = kvp.Key;
                var trainState = kvp.Value;

                if (!metroMap.TryGetValue(trainId, out var metroInfo)) continue;
                if (!LinesByLineId.TryGetValue(trainState.LineId, out var lineData)) continue;
                if (lineData.Stations.Count == 0) continue;

                // Cooldown to prevent rapid transitions
                if (now - trainState.LastStationChangeTick < StationTransitionCooldownMs) continue;

                float elapsed = metroInfo.ElapsedTime;
                int stationAtTime = GetCurrentStation(trainState.LineId, elapsed);

                if (stationAtTime >= 0 && !trainState.AtStation)
                {
                    // Train arrived at a new station
                    trainState.AtStation = true;
                    trainState.CurrentStationIdx = stationAtTime;
                    trainState.StationArrivalTime = elapsed;
                    trainState.LastStationChangeTick = now;

                    // Only notify player if they're on this metro
                    if (conn.CurrentMetroId == (ulong)trainId)
                    {
                        DebugLogger.Log($"[Metro] Train #{trainId} arrived at station {stationAtTime} ({lineData.Stations[stationAtTime].Name})");
                    }
                }
                else if (stationAtTime < 0 && trainState.AtStation)
                {
                    // Train departed station
                    trainState.AtStation = false;
                    int nextStation = GetNextStation(trainState.LineId, trainState.CurrentStationIdx);
                    trainState.CurrentStationIdx = nextStation;
                    trainState.LastStationChangeTick = now;

                    if (conn.CurrentMetroId == (ulong)trainId)
                    {
                        DebugLogger.Log($"[Metro] Train #{trainId} departed, heading to station {nextStation}");
                    }
                }
            }
        }

        // ======================== NPC PASSENGER MANAGEMENT ========================

        /// <summary>
        /// Simulate passengers boarding and alighting at stations. Only trains
        /// currently at a station (doors open) can exchange passengers.
        /// </summary>
        static void UpdatePassengers(Connection conn, long now)
        {
            if (!_connTrains.TryGetValue(conn.Pid, out var trains)) return;

            // Find trains at stations with doors open
            var atStations = trains.Values.Where(t =>
                t.AtStation && LinesByLineId.ContainsKey(t.LineId)).ToList();

            if (atStations.Count == 0) return;

            // Pick a random train at a station for passenger activity
            var train = atStations[_rng.Next(atStations.Count)];
            if (!LinesByLineId.TryGetValue(train.LineId, out var lineData)) return;

            // Decide: add or remove passengers
            if (train.Passengers.Count > 0 && _rng.NextDouble() < 0.3)
            {
                // Unbind a random passenger (they reached their destination)
                int idx = _rng.Next(train.Passengers.Count);
                var passenger = train.Passengers[idx];
                SendUnbindNpc(conn, passenger.NpcId, (ulong)train.TrainId);
                train.Passengers.RemoveAt(idx);
            }
            else if (train.Passengers.Count < 6)
            {
                // Add 1-2 new passengers
                int toAdd = _rng.Next(1, 3);
                for (int i = 0; i < toAdd; i++)
                {
                    ulong npcId = PassengerIdBase + (ulong)Interlocked.Increment(ref _nextPassengerId);
                    byte carriage = (byte)_rng.Next(0, 2);
                    int destStation = _rng.Next(lineData.Stations.Count);
                    uint formworkId = CrowdFormworkBase + (uint)(_rng.Next(72));

                    var passenger = new MetroPassenger
                    {
                        NpcId = npcId,
                        FormworkId = formworkId,
                        CarriageIndex = carriage,
                        DestStationIdx = destStation,
                    };
                    train.Passengers.Add(passenger);

                    // Send SyncAetherAIMetroNpcAdd (spawn the NPC)
                    SendNotify(conn, MethodId.SyncAetherAIMetroNpcAdd, new SyncAetherAIMetroNpcAdd
                    {
                        NpcFormworkId = formworkId,
                        MetroInstanceId = (ulong)train.TrainId,
                        MetroCarriageIndex = carriage,
                        PoiActionId = 0,
                        Id = npcId,
                        Position = new UXVector3 { X = 0, Y = 0, Z = 0 },
                        Facing = (float)(_rng.NextDouble() * Math.PI * 2),
                    });

                    // Send SyncBindNpcToMetro (attach NPC to carriage)
                    SendNotify(conn, MethodId.SyncBindNpcToMetro, new SyncBindNpcToMetro
                    {
                        NpcInstanceId = npcId,
                        MetroInstanceId = (ulong)train.TrainId,
                        MetroCarriageIndex = carriage,
                        LocalOffset = new UXVector3
                        {
                            X = (float)(_rng.NextDouble() * 4 - 2),
                            Y = 0,
                            Z = (float)(_rng.NextDouble() * 8 - 4)
                        },
                    });
                }
            }
        }

        /// <summary>
        /// Remove all passengers from all trains for a connection.
        /// Called when connection disconnects or metro simulation is disabled.
        /// </summary>
        public static void ClearAllPassengers(Connection conn)
        {
            if (!_connTrains.TryGetValue(conn.Pid, out var trains)) return;

            foreach (var train in trains.Values)
            {
                foreach (var p in train.Passengers)
                    SendUnbindNpc(conn, p.NpcId, (ulong)train.TrainId);
                train.Passengers.Clear();
            }
        }

        /// <summary>
        /// Force-remove all train states for a connection (e.g., on disconnect).
        /// </summary>
        public static void CleanupConnection(Connection conn)
        {
            ClearAllPassengers(conn);
            _connTrains.Remove(conn.Pid);
        }

        /// <summary>
        /// Force a full resync of train states (called after GM panel changes).
        /// Clears existing train state cache so next tick rebuilds from scratch.
        /// </summary>
        public static void ForceResync(Connection conn)
        {
            if (_connTrains.TryGetValue(conn.Pid, out var trains))
            {
                // Unbind all passengers before clearing
                foreach (var train in trains.Values)
                {
                    foreach (var p in train.Passengers)
                        SendUnbindNpc(conn, p.NpcId, (ulong)train.TrainId);
                }
                trains.Clear();
            }
            conn.LastMetroSyncTime = 0; // force immediate sync on next tick
            conn.PushMetroResync();
        }

        // ======================== DYNAMIC LIFECYCLE ========================

        /// <summary>
        /// Dynamically add a train to a line (e.g., rush hour extra).
        /// The train will appear in the next SyncRunningMetroInfos push.
        /// </summary>
        public static void RequestAddTrain(Connection conn, uint lineId, int extraTrainIndex)
        {
            // Increment the train count for this line
            int current = conn.MetroLineTrainCount.TryGetValue(lineId, out var n) ? n : conn.MetroTrainsPerLine;
            conn.MetroLineTrainCount[lineId] = current + 1;
            conn.PushMetroResync();
            Console.WriteLine($"[Metro] Added extra train to line {lineId} (now {current + 1} trains)");
        }

        /// <summary>
        /// Remove the last train from a line. Sends SyncDestroyMetroInfos.
        /// </summary>
        public static void RequestRemoveLastTrain(Connection conn, uint lineId)
        {
            int current = conn.MetroLineTrainCount.TryGetValue(lineId, out var n) ? n : conn.MetroTrainsPerLine;
            if (current <= 1) return; // keep at least 1 train

            conn.MetroLineTrainCount[lineId] = current - 1;

            // Find the train ID to destroy (the last one on this line)
            if (_connTrains.TryGetValue(conn.Pid, out var trains))
            {
                var lastTrain = trains.Values
                    .Where(t => t.LineId == lineId)
                    .OrderByDescending(t => t.TrainId)
                    .FirstOrDefault();

                if (lastTrain != null)
                {
                    // Unbind passengers
                    foreach (var p in lastTrain.Passengers)
                        SendUnbindNpc(conn, p.NpcId, (ulong)lastTrain.TrainId);

                    // Send destroy
                    SendNotify(conn, MethodId.SyncDestroyMetroInfos, new SyncDestroyMetroInfos
                    {
                        MetroIds = new List<int> { lastTrain.TrainId }
                    });

                    trains.Remove(lastTrain.TrainId);
                    Console.WriteLine($"[Metro] Removed last train #{lastTrain.TrainId} from line {lineId}");
                }
            }

            conn.PushMetroResync();
        }

        /// <summary>
        /// Send initial metro hide states after login/scene load.
        /// Sends an empty hide area list (no stealth zones active by default).
        /// </summary>
        public static void SendInitialHideStates(Connection conn)
        {
            SendNotify(conn, MethodId.SyncHideMetroStates, new SyncHideMetroStates
            {
                HideAreas = new List<MetroHideArea>()
            });
        }

        /// <summary>
        /// Build metro NPC init data for login (enhanced version of BuildMetroPassengers).
        /// Creates passengers distributed across all active lines' trains.
        /// </summary>
        public static List<ClientMetroNpcInitData> BuildInitialMetroNpcs(Connection conn)
        {
            var list = new List<ClientMetroNpcInitData>();
            var runningMetros = conn.BuildRunningMetros();
            var rng = new Random(42); // deterministic for consistent login state
            ulong idCounter = PassengerIdBase;

            foreach (var metro in runningMetros)
            {
                // 2 passengers per train (one per carriage)
                for (byte carriage = 0; carriage < 2; carriage++)
                {
                    list.Add(new ClientMetroNpcInitData
                    {
                        Id = idCounter++,
                        NpcFormworkId = CrowdFormworkBase + (uint)(rng.Next(72)),
                        MetroInstanceId = (ulong)metro.Id,
                        MetroCarriageIndex = carriage,
                        PoiActionId = 0,
                        Position = new UXVector3 { X = 0, Y = 0, Z = 0 },
                        Facing = 0f,
                    });
                }
            }

            return list;
        }

        // ======================== HELPERS ========================

        static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            if (conn == null || conn.ClientSocket == null || !conn.ClientSocket.Connected)
                return;

            try
            {
                var msg = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)methodId,
                };
                msg.SetArgs(methodId, args);
                conn.SendPacket(msg);
            }
            catch (ObjectDisposedException)
            {
                // Socket already disposed during disconnect, ignore
            }
            catch (SocketException)
            {
                // Socket already closed during disconnect, ignore
            }
        }

        static void SendUnbindNpc(Connection conn, ulong npcId, ulong metroId)
        {
            SendNotify(conn, MethodId.SyncUnbindNpcToMetro, new SyncUnbindNpcToMetro
            {
                NpcInstanceId = npcId,
                MetroInstanceId = metroId,
            });
        }

        static void SendBindNpc(Connection conn, ulong npcId, ulong metroId, byte carriage, UXVector3 offset)
        {
            SendNotify(conn, MethodId.SyncBindNpcToMetro, new SyncBindNpcToMetro
            {
                NpcInstanceId = npcId,
                MetroInstanceId = metroId,
                MetroCarriageIndex = carriage,
                LocalOffset = offset,
            });
        }
    }
}
