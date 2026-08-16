using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Packets.Req;
using AnantaTestGameServer.Utils;
using AnantaTestGameServer.Game;
using AnantaTestGameServer.Game.State;
using Google.Protobuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;
using static AnantaTestGameServer.HandlerAttribute;

namespace AnantaTestGameServer
{
    public class GangMemberInfo
    {
        public uint TemplateId;
        public ulong InstanceId;
        public double NextReviveTimeStamp;
        public bool IsUnlock;
        public float HpPercent;
    }

    // Lightweight record of a vehicle spawned by the GM Vehicle panel.
    // Tracked per-connection so /gm/vehicle/list can show the live spawn history
    // (not just the static catalog of unlocked configIds).
    public class SpawnedVehicle
    {
        public ulong EntityId;
        public uint ConfigId;
        public float SpawnX, SpawnY, SpawnZ;
        public float Facing;
        public uint ColorConfigId;
        public DateTime SpawnTime;
        public bool IsDestroyed;
    }

    // In-memory chat message store per connection (stubs for chat/messaging system).
    public class ChatStore
    {
        public List<ChatMessage> P2PMessages = new();
        public List<ChatMessage> RoomMessages = new();
        public List<ChatMessage> TeamMessages = new();
        public Dictionary<ulong, List<ChatMessage>> ChatGroupMessages = new();
        public Dictionary<int, List<ChatMessage>> LinkMessages = new(); // keyed by LinkMode int
        public uint NextMessageId = 1;

        public ChatMessage CreateMessage(MessageChannel channel, ulong senderPid, ulong receiver, string content, bool isAudio)
        {
            return new ChatMessage()
            {
                MessageId = NextMessageId++,
                Channel = channel,
                Pid = senderPid,
                Receiver = receiver,
                Time = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds()),
                IsAudio = isAudio,
                Content = content,
                SystemMessageId = 0,
            };
        }

        public List<ChatMessage> GetMessagesAfter(List<ChatMessage> list, uint afterTimestamp)
        {
            if (list == null || list.Count == 0) return new();
            return list.Where(m => m.Time > afterTimestamp).ToList();
        }

        public List<ChatMessage> GetMessagesInRange(List<ChatMessage> list, uint startTs, uint endTs, uint count)
        {
            if (list == null || list.Count == 0) return new();
            var filtered = list.Where(m => m.Time >= startTs && m.Time <= endTs);
            if (count > 0) filtered = filtered.Take((int)count);
            return filtered.ToList();
        }

        public List<ChatMessage> GetLatestFromEach(Dictionary<ulong, List<ChatMessage>> dict, List<ulong> keys)
        {
            var result = new List<ChatMessage>();
            foreach (var key in keys)
            {
                if (dict.TryGetValue(key, out var msgs) && msgs.Count > 0)
                    result.Add(msgs.Last());
            }
            return result;
        }
    }

    public partial class Connection
    {
        public static List<SpiritInfo> GetDefaultSpirits()
        {
            return BuildDefaultSpirits();
        }

        public Socket ClientSocket;
        private Thread ReceiveThread;
        private List<byte> Buffer = new List<byte>();
        public RC4 rc4encrypt;
        public RC4 rc4Decrypt;
        public byte[] Rc4Key;
        public ulong Pid;
        public const uint TaffySpiritId = 15020992;
        public const uint TaffyMotoBuffId = 52606155;

        public ulong LastSpawnedVehicleId = 0;
        public ulong CurrentVehicleId = 0;
        public ulong LastDetectedVehicleId = 0;
        public int CurrentVehicleSeat = -1;
        public uint LastSpawnedVehicleConfigId = 81000004;
        public uint LastVehicleColorConfigId = 0;
        public UXVector3 LastVehicleSpawnPosition = new() { X = 1015, Y = 0, Z = 1998 };
        public float LastVehicleFacing = 45;
        public HashSet<uint> UnlockedVehicles = null;

        // Live tracking of all GM-spawned vehicles (for /gm/vehicle/list panel).
        // Entries are appended on SpawnVehicle() and marked IsDestroyed on GmDestroyVehicle().
        public List<SpawnedVehicle> SpawnedVehicles = new();
        private const int MaxSpawnedVehicleHistory = 200;

        // Saimo hack / Dila flight state
        public ulong SaimoHackNpcEntityId = 0uL;
        public bool SaimoAetherInitialized = false;

        public void RegisterSpawnedVehicle(SpawnedVehicle v)
        {
            SpawnedVehicles.Add(v);
            InvalidateVehicleCache();
            // Cap history so spamming Spawn doesn't blow memory
            if (SpawnedVehicles.Count > MaxSpawnedVehicleHistory)
            {
                int trim = SpawnedVehicles.Count - MaxSpawnedVehicleHistory;
                SpawnedVehicles.RemoveRange(0, trim);
            }
        }

        public void MarkVehicleDestroyed(ulong entityId)
        {
            for (int i = SpawnedVehicles.Count - 1; i >= 0; i--)
            {
                if (SpawnedVehicles[i].EntityId == entityId)
                {
                    SpawnedVehicles[i].IsDestroyed = true;
                    InvalidateVehicleCache();
                    return;
                }
            }
        }

        // Returns only the vehicles that are still alive (not destroyed).
        public List<SpawnedVehicle> GetLiveVehicles()
        {
            // Return cached list to avoid repeated allocations
            // This reduces GC pressure and memory fragmentation
            if (_liveVehiclesCache == null)
            {
                _liveVehiclesCache = SpawnedVehicles.Where(v => !v.IsDestroyed).ToList();
            }
            return _liveVehiclesCache;
        }

        public void PurgeDestroyedVehicles()
        {
            SpawnedVehicles.RemoveAll(v => v.IsDestroyed);
            InvalidateVehicleCache();
        }

        // --- NPC AI tracking (for NpcBehaviorManager) ---
        public enum NpcState : byte
        {
            Idle = 0,
            PatrolWalking = 1,
            Wandering = 2,
            Fleeing = 3,
            Dead = 4,
            // --- Extended states ---
            Interacting = 5,       // Talking/trading with player or another NPC
            Sitting = 6,           // Sitting on bench/chair (static pose)
            Talking = 7,           // Conversing (dialogue active)
            Shopping = 8,          // Browsing a shop/vendor
            Unconscious = 9,       // Downed but alive (can be revived)
            GettingInVehicle = 10, // Entering a vehicle (transition)
            GettingOutVehicle = 11,// Exiting a vehicle (transition)
            Driving = 12,          // Driving a vehicle (bound to vehicle entity)
            Passenger = 13,        // Riding as passenger
            Dancing = 14,          // Playing dance animation
            Sleeping = 15,         // Sleeping (night schedule)
            Working = 16,          // Performing work animation
            Eating = 17,           // Eating at a location
            Examined = 18,         // Being examined by police
            Stunned = 19,          // Temporarily stunned (combat effect)
            Celebrating = 20       // Celebration animation
        }

        public class SpawnedNpc
        {
            public ulong EntityId;
            public uint FormworkId;
            public float PosX, PosY, PosZ;
            public float Facing;
            public NpcState CurrentState = NpcState.Idle;
            public NpcState PreviousState = NpcState.Idle;
            public DateTime StateEnteredAt = DateTime.UtcNow;
            // Origin point — NPC wanders within a radius of this position
            public float OriginX, OriginZ;
            // Crowd NPCs: waypoint patrol loop
            public List<ClientZoneGraphPathPoint> Waypoints;
            public int CurrentWaypointIndex = 0;
            public float DesiredSpeed = 1.5f;
            // Is this a static NPC (fixed position) or crowd (walking)?
            public bool IsStatic = false;
            public bool IsDestroyed = false;
            // For memory optimization: hide NPCs below ground instead of destroying
            public bool IsHidden = false;
            public float OriginalPosY = 0f;
            // Behavior tree instance (assigned by BTFactory on spawn)
            public BehaviorTreeEngine.BTTree BehaviorTree;
            // Per-NPC blackboard for AI state (emotions, police, schedule, dialogue, etc.)
            public BehaviorTreeEngine.Blackboard Board = new();
            // Movement mode — current locomotion state (for MovementScheduler)
            public MovementMode CurrentMovementMode = MovementMode.Idle;
            // Goal planner — current active goal
            public NpcGoal CurrentGoal = NpcGoal.None;
            // Vehicle interaction — bound vehicle entity ID (0 = not in vehicle)
            public ulong BoundVehicleEntityId = 0;
            public int VehicleSeatIndex = -1;
            // Interaction target — entity ID of NPC/player being interacted with
            public ulong InteractionTargetId = 0;
        }

        // Movement FSM states (mirrors DLL MovementStateType)
        public enum MovementMode : byte
        {
            Idle = 0,    // Standing still
            Walk = 1,    // Normal walking (~1.5 m/s)
            Run = 2,     // Running (~3.0 m/s)
            Flee = 3,    // Panicked running (~4.0 m/s)
            Turn = 4     // Rotating in place (no displacement)
        }

        // NPC Goals for GOAP system
        public enum NpcGoal : byte
        {
            None = 0,
            ReturnToOrigin = 1,
            Patrol = 2,
            Flee = 3,
            Explore = 4,
            Idle = 5,
            Interact = 6
        }

        public List<SpawnedNpc> SpawnedNpcs = new();
        private const int MaxSpawnedNpcHistory = 500;

        // Traffic vehicles tracked by VehicleDrivingAI
        public List<VehicleDrivingAI.TrafficVehicle> TrafficVehicles = new();

        public void RegisterSpawnedNpc(SpawnedNpc npc)
        {
            SpawnedNpcs.Add(npc);
            InvalidateNpcCache();
            if (SpawnedNpcs.Count > MaxSpawnedNpcHistory)
            {
                int trim = SpawnedNpcs.Count - MaxSpawnedNpcHistory;
                SpawnedNpcs.RemoveRange(0, trim);
            }
        }

        public SpawnedNpc GetNpcById(ulong entityId)
        {
            for (int i = SpawnedNpcs.Count - 1; i >= 0; i--)
            {
                if (SpawnedNpcs[i].EntityId == entityId)
                    return SpawnedNpcs[i];
            }
            return null;
        }

        public void MarkNpcHidden(ulong entityId, bool hidden)
        {
            var npc = GetNpcById(entityId);
            if (npc != null)
            {
                npc.IsHidden = hidden;
                InvalidateNpcCache();
            }
        }

        public void MarkNpcDestroyed(ulong entityId)
        {
            var npc = GetNpcById(entityId);
            if (npc != null) npc.IsDestroyed = true;
            InvalidateNpcCache();
        }

        public List<SpawnedNpc> GetLiveNpcs()
        {
            // Return cached list to avoid repeated allocations
            // This reduces GC pressure and memory fragmentation
            if (_liveNpcsCache == null)
            {
                _liveNpcsCache = SpawnedNpcs.Where(n => !n.IsDestroyed).ToList();
            }
            return _liveNpcsCache;
        }

        private List<SpawnedNpc>? _liveNpcsCache = null;

        public void InvalidateNpcCache()
        {
            _liveNpcsCache = null;
        }

        public void PurgeDestroyedNpcs()
        {
            SpawnedNpcs.RemoveAll(n => n.IsDestroyed);
            InvalidateNpcCache();
        }

        public void ClearAllNpcs()
        {
            SpawnedNpcs.Clear();
            InvalidateNpcCache();
        }

        // --- Metro state ---
        public ulong CurrentMetroId = 0;           // 0 = not on metro
        public int CurrentMetroCarriage = -1;      // carriage index the player occupies
        public uint CurrentMetroLineId = 0;        // line of the metro currently boarded

        // --- Metro GM control (what the server broadcasts to this client) ---
        public HashSet<uint> ActiveMetroLines = new() { 1u, 2u, 3u, 4u };  // default 4 lines
        public int MetroTrainsPerLine = 2;                                    // 2 trains/line for more activity

        // Per-line editable settings (overrides MetroTrainsPerLine when present).
        // Default values matching original client expectations:
        //   L1=Harbor/300s, L2=Central/300s, L3=EastCity/240s, L4=Feisuo/240s
        public Dictionary<uint, float> MetroLineCycleSeconds = new()
        {
            { 1u, 300f }, { 2u, 300f }, { 3u, 240f }, { 4u, 240f },
        };
        public Dictionary<uint, int> MetroLineTrainCount = new()
        {
            // Empty by default - uses MetroTrainsPerLine (2 trains/line)
            // Can be set per-line via GM Transit panel if needed
        };
        // Per-line phase offset (seconds) — shifts the entire line's train distribution.
        public Dictionary<uint, float> MetroLineOffsetSeconds = new();
        // Per-train manual IsFinal override keyed by "{lineId}_{trainIndex}". If not present,
        // falls back to "last train in line is final".
        public Dictionary<string, bool> MetroTrainFinalOverride = new();

        // --- MetroManager integration (used by GameTickService → MetroManager.Tick) ---
        public bool MetroSimulationEnabled = true;   // master toggle for metro AI simulation
        public long LastMetroSyncTime = 0;            // TickCount64 of last SyncRunningMetroInfos push
        public long LastMetroNpcTick = 0;             // TickCount64 of last NPC passenger update

        // --- VehicleSyncManager integration ---
        public long LastVehicleFullSyncTime = 0;     // TickCount64 of last full vehicle state push

        // Build the list of running metros currently active for this connection.
        // Uses per-line cycle/trains/offset/final-override from the GM Transit panel.
        // Used by AskGetAllMetroInfos handler and the GM resync action.
        public List<MetroClientInfo> BuildRunningMetros()
        {
            // Use cached list with short TTL (1 second) to avoid repeated allocations
            // Metro positions change over time, so cache is short-lived
            long now = Environment.TickCount64;
            if (_metrosCache != null && (now - _metrosCacheTime) < 1000)
            {
                return _metrosCache;
            }

            float uptime = (float)now / 1000f;
            var list = new List<MetroClientInfo>();
            
            // Use new MetroPathSystem for waypoint-based paths
            var allLineIds = Game.Metro.MetroPathSystem.GetAllLineIds();
            
            foreach (var lineId in ActiveMetroLines.OrderBy(x => x))
            {
                var path = Game.Metro.MetroPathSystem.GetLinePath(lineId);
                if (path == null) continue;
                
                float cycle = MetroLineCycleSeconds.TryGetValue(lineId, out var c) ? c : path.CycleSeconds;
                if (cycle <= 0) cycle = path.CycleSeconds;
                int trains = MetroLineTrainCount.TryGetValue(lineId, out var n) ? n : MetroTrainsPerLine;
                if (trains <= 0) continue;
                float phaseOffset = MetroLineOffsetSeconds.TryGetValue(lineId, out var ph) ? ph : 0f;

                for (int t = 0; t < trains; t++)
                {
                    // Distribute trains evenly along the path
                    float offset = (cycle / Math.Max(1, trains)) * t + phaseOffset;
                    string key = $"{lineId}_{t}";
                    bool defaultFinal = (t == trains - 1);
                    bool isFinal = MetroTrainFinalOverride.TryGetValue(key, out var f) ? f : defaultFinal;
                    float elapsed = (uptime + offset) % cycle;
                    
                    // Calculate progress (0-1) along the path
                    float progress = elapsed / cycle;
                    
                    // Get position from waypoint-based path system
                    UXVector3 position = path.GetPositionAtProgress(progress);
                    float facing = path.GetFacingAtProgress(progress);
                    float speed = path.GetSpeedAtProgress(progress);

                    list.Add(new MetroClientInfo
                    {
                        Id = (int)(lineId * 100 + (uint)t),  // stable ID: lineId*100 + trainIndex
                        LineId = lineId,
                        ElapsedTime = elapsed,
                        IsFinalTrain = isFinal,
                        Position = position,
                        Facing = facing,
                        Speed = speed,
                    });
                }
                
                // Also include sub-lines (bidirectional, branching)
                foreach (var subLine in Game.Metro.MetroPathSystem.GetSubLines(lineId))
                {
                    int subTrains = MetroLineTrainCount.TryGetValue(subLine.SubLineId, out var st) ? st : 1;
                    if (subTrains <= 0) continue;
                    
                    for (int t = 0; t < subTrains; t++)
                    {
                        float offset = (cycle / Math.Max(1, subTrains)) * t + phaseOffset;
                        float elapsed = (uptime + offset) % cycle;
                        float progress = elapsed / cycle;
                        
                        UXVector3 position = subLine.Path.GetPositionAtProgress(progress);
                        float facing = subLine.Path.GetFacingAtProgress(progress);
                        float speed = subLine.Path.GetSpeedAtProgress(progress);

                        list.Add(new MetroClientInfo
                        {
                            Id = (int)(subLine.SubLineId * 100 + (uint)t),
                            LineId = subLine.SubLineId,
                            ElapsedTime = elapsed,
                            IsFinalTrain = t == subTrains - 1,
                            Position = position,
                            Facing = facing,
                            Speed = speed,
                        });
                    }
                }
            }
            _metrosCache = list;
            _metrosCacheTime = now;
            return list;
        }

        private List<MetroClientInfo>? _metrosCache = null;
        private long _metrosCacheTime = 0;

        private List<SpawnedVehicle>? _liveVehiclesCache = null;

        public void InvalidateVehicleCache()
        {
            _liveVehiclesCache = null;
        }

        public void InvalidateMetroCache()
        {
            _metrosCache = null;
        }

        // Push a SyncRunningMetroInfos notify to this connection so the transit map
        // updates immediately. Called after any GM toggle/resync action.
        public void PushMetroResync()
        {
            InvalidateMetroCache();
            var metros = BuildRunningMetros();
            UxRpcMessage notify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRunningMetroInfos,
            };
            notify.SetArgs(MethodId.SyncRunningMetroInfos, new SyncRunningMetroInfos() { metroInfos = metros });
            SendPacket(notify);
        }
        public float LastCameraFacing = 45;
        public bool GmVehicleControlActive = false;
                public bool SkipNextVehicleSpawn = false; // Set during spirit switch to prevent vehicle duplication
                public bool WeaponsSynced = false; // Prevents GetServerTimeGame from resetting weapons every time sync
                public bool HasLastKnownPlayerPosition = false;
        public bool GmWeaponDurabilityFree = false;
        public UXVector3 LastKnownPlayerPosition = new()
        {
            X = 1000,
            Y = 0,
            Z = 2000
        };

        // Position tracking for speed calculation
        public UXVector3 PreviousPlayerPosition = new()
        {
            X = 1000,
            Y = 0,
            Z = 2000
        };
        public long LastPositionUpdateTime = 0; // TickCount64

        // ── UrbanCrowdSpawner state ──
        public bool CrowdAetherInited = false;
        public float LastCrowdStreamX = float.NaN;
        public float LastCrowdStreamZ = float.NaN;
        public Dictionary<uint, List<ulong>> CrowdAreas = new();

        // ── AOI Grid state (AOIGridManager) ──
        public HashSet<(int X, int Z)> LoadedDestructibleCells = new();
        public HashSet<(int X, int Z)> LoadedSceneItemCells = new();
        public int LastGridX = int.MinValue;
        public int LastGridZ = int.MinValue;
        public bool AOIInitialized = false;

        public List<ulong> LastSpawnedNpcIds = new();
        public uint? CurrentTaskId = null;
        public Dictionary<uint, List<int>> TaskCounterValues = new();
        public HashSet<uint> AcceptedTasks = new();
        public HashSet<uint> SubmittedTasks = new();
        public List<uint> FinishedChoiceTaskIds = new();
        
        // ── Police task system ──
        public uint? CurrentPoliceTaskId = null;
        public HashSet<uint> AcceptedPoliceTasks = new();
        public HashSet<uint> SubmittedPoliceTasks = new();
        public Dictionary<uint, List<int>> PoliceTaskCounterValues = new();
        
        // ── Washer mission system ──
        public uint? CurrentWasherMissionId = null;
        public HashSet<uint> AcceptedWasherMissions = new();
        public HashSet<uint> FinishedWasherMissions = new();
        public Dictionary<uint, float> WasherMissionProgress = new();
        
        // ── Hacker post task system ──
        // HackerAcceptedPostIds already defined elsewhere in Connection.cs
        
        // ── Quest/SubQuest system ──
        public HashSet<uint> AcceptedQuests = new();
        public HashSet<uint> CompletedQuests = new();
        public HashSet<uint> UnlockedQuests = new();
        public HashSet<uint> CompletedSubQuests = new();
        public Dictionary<uint, HashSet<uint>> QuestSubQuests = new(); // questId -> subQuestIds
        public Dictionary<uint, List<int>> QuestCounterValues = new();
        
        // ── Investigator Gallery system ──
        public HashSet<uint> UnlockedInvestigatorGalleries = new();
        public Dictionary<uint, int> InvestigatorGalleryProgress = new(); // galleryId -> progress
        
        public Dictionary<uint, FactionInfo> FactionInfoDic = new()
        {
            {18000111, new FactionInfo() { Disposition = 50, DispositionLevel = 1, Influence = 100, InteractionCount = 0, GreetCount = 0 }},
            {18000112, new FactionInfo() { Disposition = 30, DispositionLevel = 1, Influence = 50, InteractionCount = 0, GreetCount = 0 }},
            {18000113, new FactionInfo() { Disposition = 40, DispositionLevel = 1, Influence = 75, InteractionCount = 0, GreetCount = 0 }},
        };
        public Dictionary<uint, uint> NpcTrustLevels = new();
        public Dictionary<uint, List<uint>> NpcWornFashions = new();
        public Dictionary<uint, uint> SpiritStoneEquipped = new();
        public Dictionary<uint, GangMemberInfo> GangMembers = new();
        public int GangBossCurrentBattleAgentCount = 3;
        public uint currentJob = 100;
        public uint currentSpirit = 15020967;
        public uint currentWeather = 3; // Default weather type ID
        public double timeOffset = 0; // Time offset in seconds from real time
        // Current in-game hour (0-23), calculated from UTC + offset
        public int CurrentHour => (int)((DateTime.UtcNow.Hour + timeOffset / 3600.0) % 24);
        // Blackboard for AI systems (EmotionSystem, PoliceAI, etc.)
        public BehaviorTreeEngine.Blackboard Blackboard = new();
        public PlayerPhoneInfo PhoneData = new PlayerPhoneInfo
        {
            DownLoadAppIds = new List<uint>(),
            SpiritPhoneInfos = new Dictionary<uint, PhoneInfos>(),
        };
        public int nextMoveId = 1;

        // --- Combat state ---
        public HashSet<ulong> ActiveSkills = new(); // Skill instance IDs currently executing
        public Dictionary<ulong, float> EnemyHpMap = new(); // enemyUnitId -> HP rate (0..1)
        public Dictionary<ulong, ulong> EnemyOwnerMap = new(); // enemyUnitId -> ownerPid
        public HashSet<ulong> DeadEnemies = new(); // enemies confirmed dead
        public ulong LastSkillHitTarget = 0;
        public uint LastSkillId = 0;
        public bool InCombat = false;
        public uint CommonSpiritTalentExp = 0;
        public Dictionary<uint, LiveHouseMusicRecord> LiveHouseRecords = new();
        public Dictionary<uint, HouseInfo> OwnedHouses = new();
        public ClientTruckOrderView TruckJobState;
        public Dictionary<uint, List<NpcChatInfo>> NpcChatMessages = new();
        public string HackerName = "Anonymous";
        public HashSet<uint> HackerReadPostIds = new();
        public HashSet<uint> HackerAcceptedPostIds = new();
        public Dictionary<string, string> SpiritCustomSuitSchemeNames = new();
        public Dictionary<uint, byte> SpiritHiddenParts = new();
        public Dictionary<uint, uint> SpiritFunctionSuitIds = new();
        public Dictionary<uint, uint> NpcFavors = new();
        public Dictionary<uint, TrustNpcInfo> NpcProfiles = new();
        public List<SpiritInfo> Spirits = new()
        {
             new SpiritInfo()
             {
                TemplateId=15020967,
                Id=100000000000,
                HpRate=1,

                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {
                        
                    },

                },
                SpiritAbilities = new()
                             {
                                 {1,new SpiritAbilityInfo(){
                                     TemplateId=1,
                                     Level=5,
                                        ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),
                                     Exp=1000
                                 }},
                                 {100,new SpiritAbilityInfo(){
                                     TemplateId=100,
                                     Level=5,
                                    ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {101,new SpiritAbilityInfo(){
                                     TemplateId=101,
                                     Level=1,
                                    ConfirmedLevel=1,

                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {102,new SpiritAbilityInfo(){
                                     TemplateId=102,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {200,new SpiritAbilityInfo(){
                                     TemplateId=200,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {300,new SpiritAbilityInfo(){
                                     TemplateId=300,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),

                                 }},
                             },
                             SpiritJobInfo = new()
                             {
                                  CurrentJob=100,

                                 AvailableJobs = new()
                                 {

                                 },
                                 HistoryJobs=new(),

                             },
                             PermanentAddAttributes = new()
                             {
                                 
                             },
                             InfoBadge = new()
                             {
                                 Badges = new(),
                                 HistoryBadges = new(),

                             },

                             MobileSkinInfo = new()
                             {
                                 Wallpaper=12003000,
                                 Decoration=12003001,
                                 Pendant=12003002
                             },

                              WeaponSlots = new()
                             {

                             },
                             SpiritBattleInfo = new()
                             {

                             },


                             TalentInfo = new()
                             {
                                 Level=1,
                                 TalentPoint=10,
                                 UnlockTalentInfoDict = new()
                                 {
                                     {601,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=601,
                                         Layer=0,

                                     } },
                                      {608,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=608,
                                         Layer=0,

                                     } }
                                 }
                             },
                             SpiritFightStyle = new()
                             {
                                 FightStyleInfo = new()
                                 {
                                    
                                 },

                             },
             },
             new SpiritInfo()
             {
                TemplateId=15020968,
                Id=100000000002,
                HpRate=1,

                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {
                        92,55,70,62,81,72
                    },

                },
                SpiritAbilities = new()
                             {
                                 {1,new SpiritAbilityInfo(){
                                     TemplateId=1,
                                     Level=5,
                                        ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),
                                     Exp=1000
                                 }},
                                 {100,new SpiritAbilityInfo(){
                                     TemplateId=100,
                                     Level=5,
                                    ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {101,new SpiritAbilityInfo(){
                                     TemplateId=101,
                                     Level=1,
                                    ConfirmedLevel=1,

                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {102,new SpiritAbilityInfo(){
                                     TemplateId=102,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {200,new SpiritAbilityInfo(){
                                     TemplateId=200,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {300,new SpiritAbilityInfo(){
                                     TemplateId=300,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),

                                 }},
                             },
                             SpiritJobInfo = new()
                             {
                                  CurrentJob=100,

                                 AvailableJobs = new()
                                 {

                                 },
                                 HistoryJobs=new(),

                             },
                             PermanentAddAttributes = new()
                             {

                             },
                             InfoBadge = new()
                             {
                                 Badges = new(),
                                 HistoryBadges = new(),

                             },

                             MobileSkinInfo = new()
                             {
                                 Wallpaper=12003000,
                                 Decoration=12003001,
                                 Pendant=12003002
                             },

                              WeaponSlots = new()
                             {

                             },
                             SpiritBattleInfo = new()
                             {

                             },


                             TalentInfo = new()
                             {
                                 Level=1,
                                 TalentPoint=10,
                                 UnlockTalentInfoDict = new()
                                 {
                                     {601,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=601,
                                         Layer=0,

                                     } },
                                      {608,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=608,
                                         Layer=0,

                                     } }
                                 }
                             },
                             SpiritFightStyle = new()
                             {
                                 FightStyleInfo = new()
                                 {

                                 },

                             },
             },
             new SpiritInfo()
             {
                TemplateId=15021021,
                Id=100000000001,
                HpRate=1,
                CurrentJobId=100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {
                       
                    },

                },
                SpiritAbilities = new()
                             {
                                 {1,new SpiritAbilityInfo(){
                                     TemplateId=1,
                                     Level=5,
                                        ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),
                                     Exp=1000
                                 }},
                                 {100,new SpiritAbilityInfo(){
                                     TemplateId=100,
                                     Level=5,
                                    ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {101,new SpiritAbilityInfo(){
                                     TemplateId=101,
                                     Level=1,
                                    ConfirmedLevel=1,

                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {102,new SpiritAbilityInfo(){
                                     TemplateId=102,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {200,new SpiritAbilityInfo(){
                                     TemplateId=200,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {300,new SpiritAbilityInfo(){
                                     TemplateId=300,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),

                                 }},
                             },
                             SpiritJobInfo = new()
                             {
                                  CurrentJob=100,

                                 AvailableJobs = new()
                                 {

                                 },
                                 HistoryJobs=new(),

                             },
                             PermanentAddAttributes = new(),
                             InfoBadge = new()
                             {
                                 Badges = new(),
                                 HistoryBadges = new(),

                             },

                             MobileSkinInfo = new()
                             {
                                 Wallpaper=12003000,
                                 Decoration=12003001,
                                 Pendant=12003002
                             },

                              WeaponSlots = new()
                             {

                             },
                             SpiritBattleInfo = new()
                             {

                             },


                             TalentInfo = new()
                             {
                                 Level=1,
                                 TalentPoint=10,
                                 UnlockTalentInfoDict = new()
                                 {
                                     {601,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=601,
                                         Layer=0,

                                     } },
                                      {608,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=608,
                                         Layer=0,

                                     } }
                                 }
                             },
                             SpiritFightStyle = new()
                             {
                                 FightStyleInfo = new()
                                 {

                                 },

                             },
             },
             new SpiritInfo()
             {
                TemplateId=15021016,
                Id=100000000004,
                HpRate=1,
                CurrentJobId=100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {

                    },

                },
                SpiritAbilities = new()
                             {
                                 {1,new SpiritAbilityInfo(){
                                     TemplateId=1,
                                     Level=5,
                                        ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),
                                     Exp=1000
                                 }},
                                 {100,new SpiritAbilityInfo(){
                                     TemplateId=100,
                                     Level=5,
                                    ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {101,new SpiritAbilityInfo(){
                                     TemplateId=101,
                                     Level=1,
                                    ConfirmedLevel=1,

                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {102,new SpiritAbilityInfo(){
                                     TemplateId=102,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {200,new SpiritAbilityInfo(){
                                     TemplateId=200,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {300,new SpiritAbilityInfo(){
                                     TemplateId=300,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),

                                 }},
                             },
                             SpiritJobInfo = new()
                             {
                                  CurrentJob=100,

                                 AvailableJobs = new()
                                 {

                                 },
                                 HistoryJobs=new(),

                             },
                             PermanentAddAttributes = new(),
                             InfoBadge = new()
                             {
                                 Badges = new(),
                                 HistoryBadges = new(),

                             },

                             MobileSkinInfo = new()
                             {
                                 Wallpaper=12003000,
                                 Decoration=12003001,
                                 Pendant=12003002
                             },

                              WeaponSlots = new()
                             {

                             },
                             SpiritBattleInfo = new()
                             {

                             },


                             TalentInfo = new()
                             {
                                 Level=1,
                                 TalentPoint=10,
                                 UnlockTalentInfoDict = new()
                                 {
                                     {601,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=601,
                                         Layer=0,

                                     } },
                                      {608,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=608,
                                         Layer=0,

                                     } }
                                 }
                             },
                             SpiritFightStyle = new()
                             {
                                 FightStyleInfo = new()
                                 {

                                 },

                             },
             },
             new SpiritInfo()
             {
                TemplateId=15021023,
                Id=100000000005,
                HpRate=1,
                CurrentJobId=100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {

                    },

                },
                SpiritAbilities = new()
                             {
                                 {1,new SpiritAbilityInfo(){
                                     TemplateId=1,
                                     Level=5,
                                        ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),
                                     Exp=1000
                                 }},
                                 {100,new SpiritAbilityInfo(){
                                     TemplateId=100,
                                     Level=5,
                                    ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {101,new SpiritAbilityInfo(){
                                     TemplateId=101,
                                     Level=1,
                                    ConfirmedLevel=1,

                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {102,new SpiritAbilityInfo(){
                                     TemplateId=102,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {200,new SpiritAbilityInfo(){
                                     TemplateId=200,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {300,new SpiritAbilityInfo(){
                                     TemplateId=300,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),

                                 }},
                             },
                             SpiritJobInfo = new()
                             {
                                  CurrentJob=100,

                                 AvailableJobs = new()
                                 {

                                 },
                                 HistoryJobs=new(),

                             },
                             PermanentAddAttributes = new(),
                             InfoBadge = new()
                             {
                                 Badges = new(),
                                 HistoryBadges = new(),

                             },

                             MobileSkinInfo = new()
                             {
                                 Wallpaper=12003000,
                                 Decoration=12003001,
                                 Pendant=12003002
                             },

                              WeaponSlots = new()
                             {

                             },
                             SpiritBattleInfo = new()
                             {

                             },


                             TalentInfo = new()
                             {
                                 Level=1,
                                 TalentPoint=10,
                                 UnlockTalentInfoDict = new()
                                 {
                                     {601,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=601,
                                         Layer=0,

                                     } },
                                      {608,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=608,
                                         Layer=0,

                                     } }
                                 }
                             },
                             SpiritFightStyle = new()
                             {
                                 FightStyleInfo = new()
                                 {

                                 },

                             },
             },
             new SpiritInfo()
             {
                TemplateId=15021024,
                Id=100000000006,
                HpRate=1,
                CurrentJobId=100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {

                    },

                },
                SpiritAbilities = new()
                             {
                                 {1,new SpiritAbilityInfo(){
                                     TemplateId=1,
                                     Level=5,
                                     ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),
                                     Exp=1000
                                 }},
                                 {100,new SpiritAbilityInfo(){
                                     TemplateId=100,
                                     Level=5,
                                     ConfirmedLevel=5,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {101,new SpiritAbilityInfo(){
                                     TemplateId=101,
                                     Level=1,
                                    ConfirmedLevel=1,

                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {102,new SpiritAbilityInfo(){
                                     TemplateId=102,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {200,new SpiritAbilityInfo(){
                                     TemplateId=200,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new()
                                 }},
                                 {300,new SpiritAbilityInfo(){
                                     TemplateId=300,
                                     Level=1,
                                    ConfirmedLevel=1,
                                     AbilityBuffConfigIdList=new(),
                                     BuffList=new(),

                                 }},
                             },
                             SpiritJobInfo = new()
                             {
                                  CurrentJob=100,

                                 AvailableJobs = new()
                                 {

                                 },
                                 HistoryJobs=new(),

                             },
                             PermanentAddAttributes = new(),
                             InfoBadge = new()
                             {
                                 Badges = new(),
                                 HistoryBadges = new(),

                             },

                             MobileSkinInfo = new()
                             {
                                 Wallpaper=12003000,
                                 Decoration=12003001,
                                 Pendant=12003002
                             },

                              WeaponSlots = new()
                             {

                             },
                             SpiritBattleInfo = new()
                             {

                             },


                             TalentInfo = new()
                             {
                                 Level=1,
                                 TalentPoint=10,
                                 UnlockTalentInfoDict = new()
                                 {
                                     {601,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=601,
                                         Layer=0,

                                     } },
                                      {608,new SpiritOrJobTalentNodeInfo()
                                     {
                                         TalentId=608,
                                         Layer=0,

                                     } }
                                 }
                             },
                             SpiritFightStyle = new()
                             {
                                 FightStyleInfo = new()
                                 {

                                 },

                             },
             },
             new SpiritInfo()
             {
                TemplateId=TaffySpiritId,
                Id=100000000007,
                HpRate=1,
                CurrentJobId=100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {
                        92,55,70,62,81,72
                    },
                },
                SpiritAbilities = new()
                {
                    {1,new SpiritAbilityInfo(){
                        TemplateId=1,
                        Level=5,
                        ConfirmedLevel=5,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new(),
                        Exp=1000
                    }},
                    {100,new SpiritAbilityInfo(){
                        TemplateId=100,
                        Level=5,
                        ConfirmedLevel=5,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new()
                    }},
                    {101,new SpiritAbilityInfo(){
                        TemplateId=101,
                        Level=1,
                        ConfirmedLevel=1,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new()
                    }},
                    {102,new SpiritAbilityInfo(){
                        TemplateId=102,
                        Level=1,
                        ConfirmedLevel=1,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new()
                    }},
                },
                SpiritJobInfo = new()
                {
                    CurrentJob=100,
                    AvailableJobs = new(),
                    HistoryJobs=new(),
                },
                PermanentAddAttributes = new(),
                InfoBadge = new()
                {
                    Badges = new(),
                    HistoryBadges = new(),
                },
                MobileSkinInfo = new()
                {
                    Wallpaper=12003000,
                    Decoration=12003001,
                    Pendant=12003002
                },
                WeaponSlots = new()
                {
                    new WeaponData()
                    {
                        TemplateId = 39020003,
                        InstanceId = 6000000000007,
                        Durability = 100,
                    }
                },
                SpiritBattleInfo = new()
                {
                },
                TalentInfo = new()
                {
                    Level=1,
                    TalentPoint=10,
                    UnlockTalentInfoDict = new()
                    {
                        {601,new SpiritOrJobTalentNodeInfo()
                        {
                            TalentId=601,
                            Layer=0,
                        } },
                        {608,new SpiritOrJobTalentNodeInfo()
                        {
                            TalentId=608,
                            Layer=0,
                        } }
                    }
                },
                SpiritFightStyle = new()
                {
                    FightStyleInfo = new()
                    {
                    },
                },
             },
             new SpiritInfo()
             {
                TemplateId=15021025,
                Id=100000000008,
                HpRate=1,
                CurrentJobId=100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new()
                    {
                        92,55,70,62,81,72
                    },
                },
                SpiritAbilities = new()
                {
                    {1,new SpiritAbilityInfo(){
                        TemplateId=1,
                        Level=5,
                        ConfirmedLevel=5,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new(),
                        Exp=1000
                    }},
                    {100,new SpiritAbilityInfo(){
                        TemplateId=100,
                        Level=5,
                        ConfirmedLevel=5,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new()
                    }},
                    {101,new SpiritAbilityInfo(){
                        TemplateId=101,
                        Level=1,
                        ConfirmedLevel=1,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new()
                    }},
                    {102,new SpiritAbilityInfo(){
                        TemplateId=102,
                        Level=1,
                        ConfirmedLevel=1,
                        AbilityBuffConfigIdList=new(),
                        BuffList=new()
                    }},
                },
                SpiritJobInfo = new()
                {
                    CurrentJob=100,
                    AvailableJobs = new(),
                    HistoryJobs=new(),
                },
                PermanentAddAttributes = new(),
                InfoBadge = new()
                {
                    Badges = new(),
                    HistoryBadges = new(),
                },
                MobileSkinInfo = new()
                {
                    Wallpaper=12003000,
                    Decoration=12003001,
                    Pendant=12003002
                },
                WeaponSlots = new()
                {
                    new WeaponData()
                    {
                        TemplateId = 39020006,
                        InstanceId = 6000000000008,
                        Durability = 100,
                    }
                },
                SpiritBattleInfo = new()
                {
                },
                TalentInfo = new()
                {
                    Level=1,
                    TalentPoint=10,
                    UnlockTalentInfoDict = new()
                    {
                        {1501,new SpiritOrJobTalentNodeInfo()
                        {
                            TalentId=1501,
                            Layer=0,
                        } },
                        {1508,new SpiritOrJobTalentNodeInfo()
                        {
                            TalentId=1508,
                            Layer=0,
                        } }
                    }
                },
                SpiritFightStyle = new()
                {
                    FightStyleInfo = new()
                    {
                    },
                },
             }
};

        public int WeaponIndex = 0;

        // Filled from WeaponStateFactory to avoid hardcoding inside Connection.cs
        public List<WeaponDetail> Weapons = new();

        // Inventory items
        public PlayerClientInfoItem PlayerItems = new()
        {
            Money = 100000,
            Gold = 10000,
            BindingGold = 0,
            FreeGold = 0,
            PackItems = new(),
            ItemDayCounts = new(),
            ItemShortcutDic = new(),
            ItemCountLimitInfoList = new(),
            GachaPoolCount = new(),
            DestructibleShortcut = 0,
            TodayGachaCount = 0,
            QuantumWalletStartTime = 0,
            PortalPosition = new()
        };

        // Fashion inventory
        public Dictionary<uint, FashionInfo> FashionInventory = new();
        public List<uint> FashionSuitInventory = new();

        // GM flags
        public bool GmInfiniteSkillCooldown = false;

        // --- Chat / Messaging state ---
        public ChatStore Chat = new();

        private static readonly uint[] JoinableFightSpiritIds =
        {
            15020967,  // M MC
            15020968,  // F MC
            15020989,  // Garm (Dog Girl)
            15020991,  // Bansy
            15020992,  // Taffy
            15020997,  // Dila
            15021016,  // Alan
            15021017,  // Mechanika
            15021020,  // Christina
            15021021,  // Richie
            15021023,  // Seymour
            15021024,  // Aileen
            15021025,  // Lykaia
            15021029,  // Mimika
            15021038,  // Enomi
            15021039,  // Shirayasu
            15021022,  // Ringo
            15022030   // Kesi
        };

        private static List<SpiritInfo> BuildDefaultSpirits()
        {
            return JoinableFightSpiritIds
                .Select((templateId, index) => CreateSpirit(templateId, 100000000000UL + (ulong)index))
                .ToList();
        }

        private static SpiritInfo CreateSpirit(uint templateId, ulong instanceId)
        {
            return new SpiritInfo()
            {
                TemplateId = templateId,
                Id = instanceId,
                HpRate = 1,
                CurrentJobId = 100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = templateId == 15020968 ? new() { 92, 55, 70, 62, 81, 72 } : new()
                },
                SpiritAbilities = BuildDefaultSpiritAbilities(),
                SpiritJobInfo = new()
                {
                    CurrentJob = 100,
                    AvailableJobs = new(),
                    HistoryJobs = new()
                },
                PermanentAddAttributes = new(),
                InfoBadge = new()
                {
                    Badges = new(),
                    HistoryBadges = new()
                },
                MobileSkinInfo = new()
                {
                    Wallpaper = 12003000,
                    Decoration = 12003001,
                    Pendant = 12003002
                },
                WeaponSlots = new(),
                SpiritBattleInfo = new(),
                TalentInfo = new()
                {
                    Level = 1,
                    TalentPoint = 10,
                    UnlockTalentInfoDict = new()
                    {
                        { 601, new SpiritOrJobTalentNodeInfo() { TalentId = 601, Layer = 0 } },
                        { 608, new SpiritOrJobTalentNodeInfo() { TalentId = 608, Layer = 0 } }
                    }
                },
                SpiritFightStyle = new()
                {
                    FightStyleInfo = new()
                }
            };
        }

        private static Dictionary<uint, SpiritAbilityInfo> BuildDefaultSpiritAbilities()
        {
            return new()
            {
                { 1, CreateSpiritAbility(1, 5, 1000) },
                { 100, CreateSpiritAbility(100, 5, 0) },
                { 101, CreateSpiritAbility(101, 1, 0) },
                { 102, CreateSpiritAbility(102, 1, 0) },
                { 200, CreateSpiritAbility(200, 1, 0) },
                { 300, CreateSpiritAbility(300, 1, 0) }
            };
        }

        private static SpiritAbilityInfo CreateSpiritAbility(uint templateId, uint level, uint exp)
        {
            return new SpiritAbilityInfo()
            {
                TemplateId = templateId,
                Level = level,
                ConfirmedLevel = level,
                Exp = exp,
                AbilityBuffConfigIdList = new(),
                BuffList = new()
            };
        }

        public SpiritInfo GetCurrentSpirit()
        {
            return Spirits.Find(s => s.TemplateId == currentSpirit) ?? Spirits.First();
        }
        public int SessionId { get; private set; }

        public Connection(Socket socket, int sessionId = 0)
        {
            this.ClientSocket = socket;
            this.SessionId = sessionId;
            Spirits = BuildDefaultSpirits();
            // Start with fists (拳头) as default weapon - use GM GmAddAllWeapons for all
            Weapons = new List<WeaponDetail>
            {
                new WeaponDetail()
                {
                    TemplateId = 98003184,
                    InstanceId = 6000000000005,
                    SpecialLabel = "",
                    WeaponFlags = new WeaponDataFlags()
                    {
                        IsTaskWheelWeapon = false,
                        ShowRedDot = false,
                        AdditionalEffectIds = new List<int>()
                    },
                    Durability = -1
                }
            };
            InitializeDefaultGangMembers();
            ReceiveThread = new Thread(ReceiveLoop);
            ReceiveThread.Start();
        }

        private void InitializeDefaultGangMembers()
        {
            var defaultAgents = new[]
            {
                1001001, 1001002, 1001003, 1001004, 1001005, 1001006, 1001007, 1001008
            };

            foreach (var agentId in defaultAgents)
            {
                GangMembers[(uint)agentId] = new GangMemberInfo
                {
                    TemplateId = (uint)agentId,
                    InstanceId = 0,
                    NextReviveTimeStamp = -1,
                    IsUnlock = true,
                    HpPercent = 1.0f
                };
            }
        }
        private void ReceiveLoop()
        {
            try
            {
                byte[] recvBuffer = new byte[4096*2];

                while (true)
                {
                    int received = ClientSocket.Receive(recvBuffer);
                    if (received <= 0)
                    {
                        GameSessionTracker.OnDisconnected(ClientSocket, "client_closed_connection");
                        Disconnect();
                        return;
                    }

                    // Aggiungi i nuovi byte al buffer
                    Buffer.AddRange(new ArraySegment<byte>(recvBuffer, 0, received));

                    // Processa i pacchetti completi
                    ProcessPackets();
                }
            }
            catch(Exception e)
            {
                GameSessionTracker.OnDisconnected(ClientSocket, $"crash: {e.GetType().Name} — {e.Message}");
                GameSessionTracker.LogEvent(ClientSocket, "CRASH", $"{e.GetType().Name}: {e.Message}\n{e.StackTrace}");
                Disconnect();
            }
        }
        private void ProcessPackets()
        {
            while (Buffer.Count >= 4) 
            {
                int length = BitConverter.ToInt32(Buffer.ToArray(), 0);

                if (Buffer.Count < 4 + length)
                    return; 

                byte[] packetData = Buffer.GetRange(5, length).ToArray();
                if (rc4encrypt != null)
                {
                    packetData = rc4Decrypt.Crypt(packetData);
                }
                UxMessageType type = (UxMessageType)Buffer.GetRange(4, 1).ToArray()[0];
                Buffer.RemoveRange(0, 5 + length);
                UxMessage packet = UxMessageFactory.Create(type, packetData);
                try
                {
                    
                    HandlePacket(packet);
                }
                catch(Exception e)
                {
                    Console.WriteLine(e.Message);
                    Console.WriteLine(e.StackTrace);
                    LuaErrorCollector.LogLuaError(this, "ProcessPackets", e.Message, e.StackTrace);
                }
                
            }
        }
        public void SendPacket(UxMessage mess)
        {
            
            mess.Build();
            Console.WriteLine("[Sent] " + mess.ToString());
            if (rc4encrypt != null && mess.Body!=null)
            {
                mess.Body = rc4encrypt.Crypt(mess.Body);
            }
            
            byte[] data = mess.ToBytes();
            ClientSocket.Send(data);
        }
        public static class UxMessageFactory
        {
            public static UxMessage Create(UxMessageType type, byte[] body)
            {
                UxMessage msg = type switch
                {
                    UxMessageType.C2SHandshake => new UxC2SHandshakeMessage(),
                    UxMessageType.S2CHandShake => new UxS2CHandShakeMessage(),
                    UxMessageType.Raw => new UxRpcMessage(),
                    UxMessageType.RPCBegin => new UxRpcMessage(),
                    UxMessageType.Heartbeat => new UxHeartbeatMessage(),
                    
                    _ => new UxMessage(type)
                };
                msg.Type = type;
                msg.Body = body;
               
                msg.Parse();
                return msg;
            }
        }
        public void HandlePacket(UxMessage packet)
        {
            Console.WriteLine("[Received] "+packet.ToString());
            if (packet.Type == UxMessageType.C2SHandshake)
            {
               
                UxC2SHandshakeMessage handshake = (UxC2SHandshakeMessage)packet;
                
                UxS2CHandShakeMessage rsp = new UxS2CHandShakeMessage()
                {
                    Encryption = false,
                    HeartbeatInterval = 1,
                    SessionId = 1,
                    
                };
                var Keys = UxS2CHandShakeMessage.GenerateSessionKeys(handshake.MagicNum, DateTime.UtcNow);
                rsp.Keys = Keys.AsSpan().Slice(0, 16).ToArray();
                if (rsp.Encryption)
                    this.Rc4Key = rsp.Keys;
                if(rsp.Encryption)
                    rc4Decrypt = new RC4(rsp.Keys);
                SendPacket(rsp);
                if (rsp.Encryption)
                    rc4encrypt = new RC4(rsp.Keys);
                
            }
            if (packet.Type == UxMessageType.Raw)
            {

                UxRpcMessage req = (UxRpcMessage)packet;
                HandlerDelegate Hdelegate = NotifyManager.GetHandler(req.RpcMethodId);
                if (Hdelegate != null)
                {
                    Hdelegate.Invoke(this, req);
                }
                else
                {
                    RpcDumpService.LogUnhandledRpc(req);
                    LuaErrorCollector.LogLuaRpc(this, req);

                    if (req.Mode == UxRpcPacketMode.Invoke)
                    {
                        UxRpcMessage rsp = new UxRpcMessage()
                        {
                            Mode = UxRpcPacketMode.Return,
                            RpcInvokeId = req.RpcInvokeId,
                            RpcMethodId = req.RpcMethodId,
                        };
                        SendPacket(rsp);
                    }
                }
            }
            if(packet.Type== UxMessageType.Heartbeat)
            {
                UxHeartbeatMessage req = (UxHeartbeatMessage)packet;
                UxHeartbeatMessage rsp = new UxHeartbeatMessage()
                {
                    ElapsedTicks=req.ElapsedTicks

                };
                SendPacket(rsp);
            }
        }
        public void Disconnect()
        {
            try
            {
                GameSessionTracker.OnDisconnected(ClientSocket, "disconnect_called");
                ClientSocket?.Shutdown(SocketShutdown.Both);
            }
            catch { }
            ClientSocket?.Close();

            Server.Instance.RemoveConnection(this);
            Game.MetroManager.CleanupConnection(this);
            Game.VehicleSyncManager.CleanupConnection(this);
            Game.MassEntityManager.CleanupConnection(this);
            Game.WorldPopulationBuilder.CleanupProgressiveSpawn(this);
            Game.PetSystem.CleanupConnection(this);
            Game.FuXiNpcAI.CleanupConnection(this);
            Game.CitySystems.CleanupConnection(this);
            Game.UrbanCrowdSpawner.CleanupConnection(this);
        }

        public void SyncAttributes()
        {
            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAttrs,
            };
            SyncUnitAttrs attrs = new SyncUnitAttrs()
            {
                entityId =GetCurrentSpirit().Id,
                values = new()
                {


                }
            };

            for (uint i = 1; i <= 97; i++)
            {
                attrs.values.Add(i, 1);
            }
            rsp1.SetArgs(MethodId.SyncUnitAttrs, attrs);
            SendPacket(rsp1);
        }
        public void SyncBuffs()
        {
            UxRpcMessage rsp9 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitBuffList, // ANKIRA: use SyncUnitBuffList not SyncAgentCharacter
            };
            var buffPayload = new SyncUnitBuffList()
            {
                entityId = GetCurrentSpirit().Id,
                buffList = new()
                {
                    new BuffViewData()
                    {
                        Id=52606154, //Superman
                        InstanceId=1003232,
                        Permanent=true,
                        Tier=1
                    },
                    new BuffViewData()
                    {
                        Id=52607001, //MultipleJump
                        InstanceId=1003234,
                        Permanent=true,
                        Tier=1
                    },
                    new BuffViewData()
                    {
                        Id=52900002, // LongSwing
                        InstanceId=1003236,
                        Permanent=true,
                        Tier=1
                    },
                    new BuffViewData()
                    {
                        Id=52606102, //CanSwing
                        InstanceId=1003238,
                        Permanent=true,
                        Tier=1
                    },
                    new BuffViewData()
                    {
                        Id=52840121, //CarBuff (ANKIRA correct ID)
                        InstanceId=1003242, // ANKIRA instance ID
                        Permanent=true,
                        Tier=1
                    }
                }
            };

            AppendDilaFlightBuffs(buffPayload.buffList, GetCurrentSpirit());

            // Saimo: add HackingAbility gate buffs so HasGlobalHackBuff() returns true
            // and the client enables the hack interaction button near hackable NPCs.
            if (currentSpirit == 15021023u)
            {
                buffPayload.buffList.Add(new BuffViewData { Id = 52606133u, InstanceId = 1003500u, ReleaserId = GetCurrentSpirit()?.Id ?? 0, Permanent = true, Tier = 1u });
                buffPayload.buffList.Add(new BuffViewData { Id = 52606134u, InstanceId = 1003501u, ReleaserId = GetCurrentSpirit()?.Id ?? 0, Permanent = true, Tier = 1u });
            }

            // Taffy Moto buff for Taffy spirit
            if (currentSpirit == TaffySpiritId)
            {
                buffPayload.buffList.Add(new BuffViewData { Id = TaffyMotoBuffId, InstanceId = 1003600u, ReleaserId = GetCurrentSpirit()?.Id ?? 0, Permanent = true, Tier = 1u });
            }

            rsp9.SetArgs(MethodId.SyncUnitBuffList, buffPayload);



            SendPacket(rsp9);
        }
        
        public void SyncWeapons()
        {
            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritWeaponDetail,
            };
            SpiritWeaponDetail data = new SpiritWeaponDetail()
            {
                SpiritTid = GetCurrentSpirit().TemplateId,
                SpiritUid = GetCurrentSpirit().Id,
                CurrentTempWeapon = null,

                CurrentWeaponUid = 6000000000003,
                WeaponSlots = Weapons,  // Main inventory
                TempWeaponSlots = new()
                {
                    WeaponSlots = Weapons,  // Weapon wheel
                    WheelId = 1,
                },
            };
            if (Weapons.Count == 0)
            {
                data.CurrentWeaponUid = 0;
            }
            else
            {
                if (WeaponIndex < 0 || WeaponIndex >= Weapons.Count)
                    WeaponIndex = 0;
                data.CurrentWeaponUid = Weapons[WeaponIndex].InstanceId;
            }
            rsp1.SetArgs(MethodId.SyncSpiritWeaponDetail, data);
            SendPacket(rsp1);
        }
        public void SyncWeapon(int i)
        {
            if (Weapons.Count == 0 || i < 0 || i >= Weapons.Count)
            {
                Console.WriteLine($"[Weapon] SyncWeapon skipped: index={i}, count={Weapons.Count}");
                return;
            }

            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritSwitchWeaponAction,
            };
            WeaponIndex = i;
            SpiritSwitchWeaponAction data = new SpiritSwitchWeaponAction()
            {
                SpiritUid = GetCurrentSpirit().Id,
                WeaponInstanceId = Weapons[i].InstanceId,
                Reason=SpiritSwitchWeaponAction.SwitchWeaponReason.Roulette

            };
            
            rsp1.SetArgs(MethodId.SyncSpiritSwitchWeaponAction, data);
            SendPacket(rsp1);
        }

        public void SendSyncPosition(ulong entityId, SetPositionType posType = SetPositionType.SwitchSpirit)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitPositionAndFacing,
            };
            rsp.SetArgs(MethodId.SyncUnitPositionAndFacing, new SyncUnitPositionAndFacing()
            {
                unitId = entityId,
                pos = LastKnownPlayerPosition,
                facing = LastCameraFacing,
                moveId = 0,
                continueMove = false,
                type = posType,
                moveGroundInfo = new UnitInfoOnMoveGround()
                {
                    MoveGroundType = MoveGroundType.Gadget,
                    MoveGroundId = 0,
                    LocalPos = new UXVector3() { X = 0, Y = 0, Z = 0 },
                    LocalRot = new UXVector3() { X = 0, Y = 0, Z = 0 }
                },
                loadingTypeInfo = null
            });
            SendPacket(rsp);
            Console.WriteLine($"[Position] SyncUnitPositionAndFacing sent for entity {entityId} pos=({LastKnownPlayerPosition.X},{LastKnownPlayerPosition.Y},{LastKnownPlayerPosition.Z}) type={posType}");
        }

        public void SendUnitRuntimeState()
        {
            ulong spiritId = GetCurrentSpirit().Id;

            // SyncUnitHp
            UxRpcMessage rspHp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHp,
            };
            rspHp.SetArgs(MethodId.SyncUnitHp, new SyncUnitHp()
            {
                unitId = spiritId,
                hp = 50
            });
            SendPacket(rspHp);

            // SyncUnitAttrs (97 attrs all = 1.0)
            SyncAttributes();

            // SyncUnitStates - raw bytes: [u64 spirit_id] [0xFF] [u32 0] [u32 0]
            UxRpcMessage rspStates = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitStates,
            };
            byte[] stateArgs = new byte[17];
            BitConverter.GetBytes(spiritId).CopyTo(stateArgs, 0);
            stateArgs[8] = 0xFF;
            BitConverter.GetBytes((uint)0).CopyTo(stateArgs, 9);
            BitConverter.GetBytes((uint)0).CopyTo(stateArgs, 13);
            rspStates.Args = stateArgs;
            SendPacket(rspStates);

            // SyncPlayerAllSkillChargeData (3 skills)
            UxRpcMessage rspCharge = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSkillChargeData,
            };
            rspCharge.SetArgs(MethodId.SyncPlayerAllSkillChargeData, new SyncPlayerAllSkillChargeData()
            {
                spiritId = spiritId,
                allChargeDatas = new()
                {
                    {51942120, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=3,
                        CurrentPercentage=100,
                        MaxCharges=3,
                    }},
                    {51942112, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=3,
                        CurrentPercentage=100,
                        MaxCharges=3,
                    }},
                    {51942115, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=3,
                        CurrentPercentage=100,
                        MaxCharges=3,
                    }}
                }
            });
            SendPacket(rspCharge);

            // SyncSpiritUnitUrbanAttrs (6 attrs all = 10.0)
            UxRpcMessage rspUrban = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritUnitUrbanAttrs,
            };
            rspUrban.SetArgs(MethodId.SyncSpiritUnitUrbanAttrs, new SyncSpiritUnitUrbanAttrs()
            {
                entityId = spiritId,
                urbanAttrsvalues = new()
                {
                    {1, 10}, {2, 10}, {3, 10},
                    {4, 10}, {5, 10}, {6, 10}
                }
            });
            SendPacket(rspUrban);

            // SyncUnitBuffList (5 buffs)
            SyncBuffs();
        }
    }
}
