using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Packets.Req;
using AnantaTestGameServer.Utils;
using AnantaTestGameServer.Game;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UX.RPC.Protocol;

namespace AnantaTestGameServer

{
    public static class NpcSpawnHandlers
    {
        // Local definition for SyncAetherAINpcRemoveArgs (from MassEntityManager namespace)
        private class SyncAetherAINpcRemoveArgs : SerializedClass
        {
            public ulong npcId;
            public SyncAetherAINpcRemoveArgs() { onlyFields = true; }
        }
        public static void SpawnNPC(Connection conn, uint[] npcFormworkIds, UXVector3? basePosition = null)
        {
            Random random = new();
            float baseX = basePosition?.X ?? 1003;
            float baseY = basePosition?.Y ?? 0;
            float baseZ = basePosition?.Z ?? 2000;
            conn.LastSpawnedNpcIds.Clear();

            for (int i = 0; i < npcFormworkIds.Length; i++)
            {
                ulong randomNpcGuid = (ulong)random.NextInt64();

                UXVector3 spawnPosition = new()
                {
                    Y = baseY,
                    X = baseX + (i % 5) * 2,
                    Z = baseZ + (i / 5) * 2
                };

                // Use CrowdAdd directly - no conversion delay
                var path = Game.DynamicPathGenerator.GeneratePath(
                    spawnPosition.X, spawnPosition.Z,
                    spawnPosition.X, spawnPosition.Z,
                    Game.DynamicPathGenerator.PathType.WanderLoop);

                var crowdNpc = new ClientCrowdInitData()
                {
                    Id = randomNpcGuid,
                    NpcFormworkId = npcFormworkIds[i],
                    AgentPersonaId = 45200058,
                    UrbanDiversityConfigId = 88888000,
                    DesiredSpeed = 1.8f,
                    ActionId = 0,
                    TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                    FashionSuitId = 11190001,
                    Points = path,
                    Position = spawnPosition,
                    Facing = (float)(random.NextDouble() * 360.0),
                };

                // Send crowd add packet
                UxRpcMessage npcRsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncAetherAICrowdAdd,
                };
                npcRsp.SetArgs(MethodId.SyncAetherAICrowdAdd, crowdNpc);
                conn.SendPacket(npcRsp);

                conn.LastSpawnedNpcIds.Add(randomNpcGuid);

                // Register spawned NPCs for AI behavior tracking
                var npc = new Connection.SpawnedNpc()
                {
                    EntityId = randomNpcGuid,
                    FormworkId = npcFormworkIds[i],
                    PosX = spawnPosition.X,
                    PosY = spawnPosition.Y,
                    PosZ = spawnPosition.Z,
                    Facing = crowdNpc.Facing,
                    OriginX = spawnPosition.X,
                    OriginZ = spawnPosition.Z,
                    CurrentState = Connection.NpcState.Wandering,
                    StateEnteredAt = DateTime.UtcNow,
                    IsStatic = false,
                    DesiredSpeed = 1.8f,
                    Waypoints = path,
                };
                BehaviorTreeEngine.BTFactory.AssignTree(npc);
                conn.RegisterSpawnedNpc(npc);
                MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Walk);
            }

            Console.WriteLine($"[GM NPC] Spawned {npcFormworkIds.Length} NPCs using CrowdAdd (no conversion delay)");
        }

        private static ClientStaticNpcInitData BuildTestStaticNpcData(ulong npcInstanceId, uint npcFormworkId, UXVector3? position = null)
        {
            ulong testStaticNpcInfoId = 41739060;

            return new ClientStaticNpcInitData()
            {
                Position = position ?? new UXVector3()
                {
                    Y = 0,
                    X = 1003,
                    Z = 2000
                },
                Id = npcInstanceId,
                StaticNpcInfoId = testStaticNpcInfoId,
                AgentPersonaId = 45200058,
                NpcPid = (int)testStaticNpcInfoId,
                UrbanDiversityId = 88888000,
                NpcFormworkId = npcFormworkId,
                PoiActionId = 0,
                SourceType = ClientStaticNpcInitData.StaticNpcSourceType.Spoon,

                AgentSyncClientInfo = new()
                {
                    stimIDList = new int[0],
                    CanBeExaminedByPolice = true,
                    indoorList = new(),
                    roomIds = new int[0],
                    SpoonAgentId = (int)testStaticNpcInfoId,
                    treeName = "",
                    petPerformData = "",
                    spawnEffectId = new uint[0],
                    randomModelCfgId = npcFormworkId,
                    LeaveDistance = 10000,
                    approachDistance = 10000,
                    FashionSuitId = 11190001,
                },
            };
        }

        private static void SendAetherAIInitDatas(Connection conn, List<ClientStaticNpcInitData> staticNpcs)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIInitDatas,
            };

            rsp.SetArgs(MethodId.SyncAetherAIInitDatas, new AetherAIInitData()
            {
                RaidId = 0,
                HasZoneGraph = false,
                ZoneStorageDataHandle = 0,
                Intersections = new(),
                Crowds = new(),
                StaticNpcs = staticNpcs,
                Vehicles = new(),
                StaticVehicles = new(),
                VehicleNpcs = new(),
                MetroNpcs = Game.MetroManager.BuildInitialMetroNpcs(conn),
            });

            conn.SendPacket(rsp);
        }

        // Generates a small set of placeholder metro passengers bound to the 4 running
        // metro trains (LineIds 1-4, MetroInstanceIds 1-4 — matches AskGetAllMetroInfos).
        // Each passenger is attached to carriage 0 of its respective train.
        // FormworkId 40968601 is the first crowd NPC template from NpcStateFactory.
        private static List<ClientMetroNpcInitData> BuildMetroPassengers()
        {
            var list = new List<ClientMetroNpcInitData>();
            const uint crowdFormworkBase = 40968601u;
            ulong passengerIdBase = 4100000000000ul;

            for (uint metroInstanceId = 1; metroInstanceId <= 4; metroInstanceId++)
            {
                // 2 passengers per train (carriage 0 and carriage 1)
                for (byte carriage = 0; carriage < 2; carriage++)
                {
                    int slotIndex = (int)((metroInstanceId - 1) * 2 + carriage);
                    list.Add(new ClientMetroNpcInitData()
                    {
                        Id = passengerIdBase + (ulong)slotIndex,
                        NpcFormworkId = crowdFormworkBase + (uint)slotIndex,
                        MetroInstanceId = metroInstanceId,
                        MetroCarriageIndex = carriage,
                        PoiActionId = 0,
                        Position = new UXVector3() { X = 0, Y = 0, Z = 0 },
                        Facing = 0f,
                    });
                }
            }
            return list;
        }

        private static void SendAetherAIStaticNpcAddData(Connection conn, ClientStaticNpcInitData staticNpc)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData,
            };

            rsp.SetArgs(MethodId.SyncAetherAIStaticNpcAddData, staticNpc);
            conn.SendPacket(rsp);
        }

        private static void SendStaticNpcConvertToPed(Connection conn, ulong npcInstanceId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcConvertToPe,
            };

            rsp.SetArgs((int)MethodId.SyncAetherAIStaticNpcConvertToPe, new StaticNpcInstanceIdArgs()
            {
                npcInstanceId = npcInstanceId,
            });

            conn.SendPacket(rsp);
        }

        private class StaticNpcInstanceIdArgs : SerializedClass
        {
            public ulong npcInstanceId;

            public StaticNpcInstanceIdArgs()
            {
                onlyFields = true;
            }
        }

        public static void DestroyAllNpcs(Connection conn)
        {
            int count = conn.LastSpawnedNpcIds.Count;
            foreach (ulong npcId in conn.LastSpawnedNpcIds)
            {
                // Use SyncAetherAINpcRemove for proper client-side removal
                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncAetherAINpcRemove,
                };
                rsp.SetArgs(MethodId.SyncAetherAINpcRemove, new SyncAetherAINpcRemoveArgs()
                {
                    npcId = npcId
                });
                conn.SendPacket(rsp);

                // Mark as destroyed on server
                conn.MarkNpcDestroyed(npcId);
            }
            conn.LastSpawnedNpcIds.Clear();
            conn.ClearAllNpcs();
            Console.WriteLine($"[GM NPC] Destroyed {count} NPCs using SyncAetherAINpcRemove.");
        }

        public static string BuildNpcStatus(Connection conn)
        {
            var liveNpcs = conn.GetLiveNpcs();
            var sb = new System.Text.StringBuilder();
            sb.AppendLine($"Total Live NPCs: {liveNpcs.Count}");
            sb.AppendLine($"GM-Spawned NPCs: {conn.LastSpawnedNpcIds.Count}");
            sb.AppendLine();
            sb.AppendLine("Recent NPCs (last 10):");
            foreach (var npc in liveNpcs.TakeLast(10))
            {
                sb.AppendLine($"  ID: {npc.EntityId}, Formwork: {npc.FormworkId}, Pos: ({npc.PosX:F1}, {npc.PosY:F1}, {npc.PosZ:F1}), State: {npc.CurrentState}");
            }
            if (liveNpcs.Count > 10)
            {
                sb.AppendLine($"  ... and {liveNpcs.Count - 10} more");
            }
            return sb.ToString();
        }

        // ================================================================
        // PHONE CALL ROUTER
        // ================================================================
        // Command formats (parsed from phoneNumber field):
        //   1#<vehId>    — Spawn vehicle by config ID (e.g. 1#81001006)
        //   0#1          — Enter last spawned vehicle
        //   0#3          — Force exit vehicle
        //   2#<HH>:<MM>  — Set time (e.g. 2#14:30)
        //   9#0          — Exit vehicle + honk horn (buzina)
        //   10000-10004  — Contact-based routing (NPC spawn, vehicle, etc.)
        //   Other        — Default NPC spawn
        // ================================================================

        [Handler(MethodId.AskPhoneAddCallRecord)]
        public static void AskPhoneAddCallRecordHandler(Connection conn, Messages.UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPhoneAddCallRecordArgs>();

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcMethodId = msg.RpcMethodId,
                RpcRetcode = 0,
            };
            conn.SendPacket(rsp);

            string phone = args.phoneNumber?.Trim() ?? "";
            Console.WriteLine($"[Phone] Call: \"{phone}\"");

            PhoneSystem.AddCallRecord(conn, conn.currentSpirit, phone, Methods.Return.PhoneContactCallRecord.PhoneContactCallType.Outgoing);

            // --- 1#<vehId> → Spawn vehicle ---
            if (phone.StartsWith("1#"))
            {
                string vehIdStr = phone.Substring(2);
                if (uint.TryParse(vehIdStr, out uint vehConfigId))
                {
                    Console.WriteLine($"[Phone] Spawning vehicle configId={vehConfigId}");
                    ClientToGameserver.SpawnVehicle(conn, vehConfigId);
                }
                else
                {
                    Console.WriteLine($"[Phone] Invalid vehicle ID: {vehIdStr}");
                }
                return;
            }

            // --- 0#<action> → Vehicle control ---
            if (phone.StartsWith("0#"))
            {
                string action = phone.Substring(2);
                switch (action)
                {
                    case "1":
                        Console.WriteLine("[Phone] Entering last spawned vehicle");
                        ClientToGameserver.GmEnterVehicle(conn);
                        break;
                    case "3":
                        Console.WriteLine("[Phone] Force exiting vehicle");
                        ClientToGameserver.GmExitVehicle(conn);
                        break;
                    default:
                        Console.WriteLine($"[Phone] Unknown vehicle action: {action}");
                        break;
                }
                return;
            }

            // --- 2#<HH>:<MM> → Set time ---
            if (phone.StartsWith("2#"))
            {
                string timeStr = phone.Substring(2);
                string[] parts = timeStr.Split(':');
                if (parts.Length == 2 && int.TryParse(parts[0], out int hour) && int.TryParse(parts[1], out int minute))
                {
                    if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59)
                    {
                        Console.WriteLine($"[Phone] Setting time to {hour:D2}:{minute:D2}");
                        ClientToGameserver.GmSetTime(conn, hour, minute);
                    }
                    else
                    {
                        Console.WriteLine($"[Phone] Invalid time: {timeStr}");
                    }
                }
                else
                {
                    Console.WriteLine($"[Phone] Invalid time format: {timeStr} (expected HH:MM)");
                }
                return;
            }

            // --- 9#0 → Exit vehicle + horn (buzina) ---
            if (phone.StartsWith("9#"))
            {
                Console.WriteLine("[Phone] Horn + exit vehicle");
                ClientToGameserver.GmVehicleHorn(conn, 0);
                ClientToGameserver.GmExitVehicle(conn);
                return;
            }

            // --- Contact-based routing ---
            string contactName = FindContactName(conn, phone);
            if (contactName != null)
            {
                Console.WriteLine($"[Phone] Calling contact: {contactName} ({phone})");
                RouteContactCall(conn, phone, contactName);
                return;
            }

            // --- Default: NPC spawn ---
            Console.WriteLine("[Phone] Default: NPC spawn");
            if (!Game.WorldPopulationBuilder.NpcAutoSpawnEnabled)
            {
                Console.WriteLine("[Phone] Auto-spawn disabled, skipping NPC spawn.");
                return;
            }
            var npcFormworkIds = Game.State.NpcStateFactory.BuildAutoSpawnNpcIds();
            SpawnNPC(conn, npcFormworkIds);
        }

        private static string FindContactName(Connection conn, string phoneNumber)
        {
            foreach (var kv in conn.PhoneData.SpiritPhoneInfos)
            {
                var contact = kv.Value.ContactList?.FirstOrDefault(c => c.PhoneNumber == phoneNumber);
                if (contact != null)
                    return string.IsNullOrEmpty(contact.Remark) ? phoneNumber : contact.Remark;
            }
            return null;
        }

        private static void RouteContactCall(Connection conn, string phoneNumber, string contactName)
        {
            switch (phoneNumber)
            {
                case "10000":
                    Console.WriteLine("[Phone] Information center: spawning NPCs");
                    if (Game.WorldPopulationBuilder.NpcAutoSpawnEnabled)
                    {
                        var npcIds = Game.State.NpcStateFactory.BuildAutoSpawnNpcIds();
                        SpawnNPC(conn, npcIds);
                    }
                    break;
                case "10001":
                    Console.WriteLine($"[Phone] Calling {contactName}: NPC encounter");
                    if (Game.WorldPopulationBuilder.NpcAutoSpawnEnabled)
                    {
                        var npcIds = Game.State.NpcStateFactory.BuildAutoSpawnNpcIds();
                        SpawnNPC(conn, npcIds);
                    }
                    break;
                case "10002":
                    Console.WriteLine($"[Phone] Calling {contactName}: spawning vehicle");
                    ClientToGameserver.SpawnVehicle(conn, 81001006);
                    break;
                case "10003":
                    Console.WriteLine($"[Phone] Calling {contactName}: combat encounter");
                    if (Game.WorldPopulationBuilder.NpcAutoSpawnEnabled)
                    {
                        var npcIds = Game.State.NpcStateFactory.BuildAutoSpawnNpcIds();
                        SpawnNPC(conn, npcIds);
                    }
                    break;
                case "10004":
                    Console.WriteLine($"[Phone] Calling {contactName}: vehicle service menu");
                    ClientToGameserver.SpawnVehicle(conn, 81001006);
                    break;
                default:
                    Console.WriteLine($"[Phone] Unknown contact {contactName}, spawning NPCs");
                    if (Game.WorldPopulationBuilder.NpcAutoSpawnEnabled)
                    {
                        var npcIds = Game.State.NpcStateFactory.BuildAutoSpawnNpcIds();
                        SpawnNPC(conn, npcIds);
                    }
                    break;
            }
        }

        public class AskPhoneAddCallRecordArgs : SerializedClass
        {
            public string phoneNumber;

            public AskPhoneAddCallRecordArgs()
            {
                onlyFields = true;
            }
        }
    }
}
