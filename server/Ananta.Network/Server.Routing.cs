using System;
using System.Collections.Generic;
using AnantaTestGameServer.Packets.Req;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Game;

namespace AnantaTestGameServer
{
    public partial class Server
    {
        private string DispatchGmToolRequest(string rawTarget, out int statusCode, out string contentType)
        {
            statusCode = 200;
            contentType = "text/plain; charset=utf-8";
            Uri uri = new Uri("http://127.0.0.1" + rawTarget);
            Dictionary<string, string> query = ParseQuery(uri.Query);

            if (uri.AbsolutePath == "/" || uri.AbsolutePath.Equals("/gm/menu", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmMainMenu();
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmVehicleUi();
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/help", StringComparison.OrdinalIgnoreCase))
                return BuildGmHelp();

            if (uri.AbsolutePath.Equals("/gm/vehicle/list", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmVehicleList();
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/spawns", StringComparison.OrdinalIgnoreCase))
            {
                // JSON endpoint for the Live Fleet table (works even without connection — returns empty list).
                Connection? fleetConn = GetActiveConnection();
                contentType = "application/json; charset=utf-8";
                return BuildGmVehicleSpawnsJson(fleetConn);
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/diagnose", StringComparison.OrdinalIgnoreCase))
            {
                return ClientToGameserver.BuildVehicleDiagnoseReport();
            }

            if (uri.AbsolutePath.Equals("/gm/sessions", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmSessionsPage();
            }

            if (uri.AbsolutePath.Equals("/gm/transit", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmTransitUi();
            }

            if (uri.AbsolutePath.Equals("/gm/transit/status", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmTransitStatus();
            }

            if (uri.AbsolutePath.Equals("/gm/transit/state", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "application/json; charset=utf-8";
                return BuildGmTransitStateJson();
            }

            if (uri.AbsolutePath.Equals("/gm/sessions/export", StringComparison.OrdinalIgnoreCase))
            {
                string path = GameSessionTracker.ExportToFile();
                return $"Session report exported to: {path}";
            }

            if (uri.AbsolutePath.Equals("/gm/sessions/clear", StringComparison.OrdinalIgnoreCase))
            {
                GameSessionTracker.Clear();
                return "Session data cleared.";
            }

            Connection? conn = GetActiveConnection();
            if (conn == null)
            {
                statusCode = 409;
                return "No active game connection. Enter the game first, then retry.";
            }

            // ── Transit control actions ───────────────────────────────
            if (uri.AbsolutePath.Equals("/gm/transit/toggle", StringComparison.OrdinalIgnoreCase))
                return TransitToggle(GetQueryUInt(query, "lineId", 0));

            if (uri.AbsolutePath.Equals("/gm/transit/resync", StringComparison.OrdinalIgnoreCase))
                return TransitResync();

            if (uri.AbsolutePath.Equals("/gm/transit/restore", StringComparison.OrdinalIgnoreCase))
                return TransitRestore();

            if (uri.AbsolutePath.Equals("/gm/transit/enable_all", StringComparison.OrdinalIgnoreCase))
                return TransitEnableAll();

            if (uri.AbsolutePath.Equals("/gm/transit/disable_all", StringComparison.OrdinalIgnoreCase))
                return TransitDisableAll();

            if (uri.AbsolutePath.Equals("/gm/transit/set_trains", StringComparison.OrdinalIgnoreCase))
                return TransitSetTrains((int)GetQueryUInt(query, "count", 2));

            if (uri.AbsolutePath.Equals("/gm/transit/set_cycle", StringComparison.OrdinalIgnoreCase))
                return TransitSetLineCycle(GetQueryUInt(query, "lineId", 0), GetQueryFloat(query, "seconds") ?? 300f);

            if (uri.AbsolutePath.Equals("/gm/transit/set_line_trains", StringComparison.OrdinalIgnoreCase))
                return TransitSetLineTrains(GetQueryUInt(query, "lineId", 0), (int)GetQueryUInt(query, "count", 0));

            if (uri.AbsolutePath.Equals("/gm/transit/set_offset", StringComparison.OrdinalIgnoreCase))
                return TransitSetLineOffset(GetQueryUInt(query, "lineId", 0), GetQueryFloat(query, "seconds") ?? 0f);

            if (uri.AbsolutePath.Equals("/gm/transit/toggle_final", StringComparison.OrdinalIgnoreCase))
                return TransitToggleFinal(GetQueryUInt(query, "lineId", 0), (int)GetQueryUInt(query, "idx", 0));

            if (uri.AbsolutePath.Equals("/gm/transit/teleport_to_train", StringComparison.OrdinalIgnoreCase))
            {
                int trainId = (int)GetQueryUInt(query, "trainId", 0);
                return TeleportToMetroTrain(conn, trainId);
            }

            if (uri.AbsolutePath.Equals("/gm/transit/list_json", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "application/json; charset=utf-8";
                return BuildMetroListJson(conn);
            }

            uint vehicleConfigId = GetQueryUInt(query, "vehicleId", ClientToGameserver.DefaultGmDrivableVehicleConfigId);
            int seatIndex = (int)GetQueryUInt(query, "seat", 0);
            float? facing = GetQueryFloat(query, "facing");
            UXVector3? position = TryBuildQueryPosition(query);
            uint colorConfigId = GetQueryUInt(query, "colorConfigId", 0);

            if (uri.AbsolutePath.Equals("/gm/vehicle/status", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmStatus(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/spawn", StringComparison.OrdinalIgnoreCase))
            {
                ulong vehicleId = ClientToGameserver.GmSpawnVehicle(conn, vehicleConfigId, position, facing, colorConfigId);
                int live = conn.GetLiveVehicles().Count;
                int total = conn.SpawnedVehicles.Count;
                return $"Spawned vehicleConfigId={vehicleConfigId}, vehicleEntityId={vehicleId}, colorConfigId={colorConfigId}. Tracked: {live} live / {total} total.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/spawn_enter", StringComparison.OrdinalIgnoreCase))
            {
                ulong vehicleId = ClientToGameserver.GmSpawnAndEnterVehicle(conn, vehicleConfigId, position, facing, seatIndex, colorConfigId);
                int live = conn.GetLiveVehicles().Count;
                int total = conn.SpawnedVehicles.Count;
                return $"Spawned & entered vehicleConfigId={vehicleConfigId}, vehicleEntityId={vehicleId}, seat={seatIndex}. Tracked: {live} live / {total} total.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/enter", StringComparison.OrdinalIgnoreCase))
            {
                ulong vehicleId = GetQueryULong(query, "vehicleId", 0);
                if (vehicleId == 0) vehicleId = GetQueryULong(query, "entityId", 0);
                bool ok = ClientToGameserver.GmEnterVehicle(conn, vehicleId, seatIndex);
                return ok ? BuildGmStatus(conn) : "Enter failed: no spawned vehicle is available.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/exit", StringComparison.OrdinalIgnoreCase))
            {
                bool ok = ClientToGameserver.GmExitVehicle(conn);
                return ok ? BuildGmStatus(conn) : "Exit failed: no vehicle is available.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/add", StringComparison.OrdinalIgnoreCase))
            {
                ClientToGameserver.GmAddVehicle(conn, vehicleConfigId);
                return $"Added vehicleConfigId={vehicleConfigId} to unlocked vehicles.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/add_all", StringComparison.OrdinalIgnoreCase))
            {
                ClientToGameserver.GmAddAllVehicles(conn);
                return "Added all vehicles to unlocked list.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/destroy", StringComparison.OrdinalIgnoreCase))
            {
                ulong targetId = GetQueryULong(query, "vehicleId", 0);
                ClientToGameserver.GmDestroyVehicle(conn, targetId);
                return targetId == 0 ? "Last/Current vehicle destroyed." : $"Vehicle {targetId} destroyed.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/purge_destroyed", StringComparison.OrdinalIgnoreCase))
            {
                int before = conn.SpawnedVehicles.Count;
                conn.PurgeDestroyedVehicles();
                int removed = before - conn.SpawnedVehicles.Count;
                return $"Purged {removed} destroyed vehicle(s). Remaining: {conn.SpawnedVehicles.Count}.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/teleport_to", StringComparison.OrdinalIgnoreCase))
            {
                ulong vehicleId = GetQueryULong(query, "vehicleId", 0);
                if (vehicleId == 0) vehicleId = GetQueryULong(query, "entityId", 0);
                return TeleportToVehicle(conn, vehicleId);
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/list_json", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "application/json; charset=utf-8";
                return BuildVehicleListJson(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/horn", StringComparison.OrdinalIgnoreCase))
            {
                uint hornType = GetQueryUInt(query, "hornType", 0);
                ClientToGameserver.GmVehicleHorn(conn, hornType);
                return "Horn sounded.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/door", StringComparison.OrdinalIgnoreCase))
            {
                byte doorIndex = (byte)GetQueryUInt(query, "index", 0);
                byte doorState = (byte)GetQueryUInt(query, "state", 1);
                ClientToGameserver.GmChangeVehicleDoorState(conn, doorIndex, doorState);
                return $"Door {doorIndex} state set to {doorState}.";
            }

            if (uri.AbsolutePath.Equals("/gm/vehicle/color", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmChangeVehicleColor(conn, colorConfigId);
                return $"Vehicle color changed to {colorConfigId}.";
            }

            // Character switching routes
            if (uri.AbsolutePath.Equals("/gm/spirit", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmSpiritUi();
            }

            if (uri.AbsolutePath.Equals("/gm/spirit/status", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmSpiritStatus(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/spirit/switch", StringComparison.OrdinalIgnoreCase))
            {
                uint spiritId = GetQueryUInt(query, "spiritId", 0);
                if (spiritId == 0)
                {
                    statusCode = 400;
                    return "Missing spiritId parameter.";
                }
                try
                {
                    Console.WriteLine($"[GM WebUI] Received switch request for spiritId={spiritId}");
                    ClientToGameserver.GmSwitchSpirit(conn, spiritId);
                    Console.WriteLine($"[GM WebUI] Switch completed successfully");
                    return $"Switched to spirit {spiritId}.";
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[GM WebUI] ERROR during switch: {ex.Message}");
                    Console.WriteLine($"[GM WebUI] Stack trace: {ex.StackTrace}");
                    statusCode = 500;
                    return $"Switch failed: {ex.Message}";
                }
            }

            // Weapons panel routes
            if (uri.AbsolutePath.Equals("/gm/weapons", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmWeaponsUi();
            }

            if (uri.AbsolutePath.Equals("/gm/weapons/status", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmWeaponsStatus(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/weapons/switch", StringComparison.OrdinalIgnoreCase))
            {
                uint weaponIndex = GetQueryUInt(query, "index", 0);
                if (weaponIndex >= conn.Weapons.Count)
                {
                    statusCode = 400;
                    return $"Invalid weapon index {weaponIndex}. Valid range: 0-{conn.Weapons.Count - 1}";
                }
                try
                {
                    Console.WriteLine($"[GM WebUI] Received weapon switch request for index={weaponIndex}");
                    conn.SyncWeapon((int)weaponIndex);
                    Console.WriteLine($"[GM WebUI] Weapon switch completed successfully");
                    return $"Switched to weapon at index {weaponIndex}.";
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[GM WebUI] ERROR during weapon switch: {ex.Message}");
                    statusCode = 500;
                    return $"Weapon switch failed: {ex.Message}";
                }
            }

            if (uri.AbsolutePath.Equals("/gm/weapons/add", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmAddWeapon(conn, query);
            }

            if (uri.AbsolutePath.Equals("/gm/weapons/addall", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    GmToolHandlers.GmAddAllWeapons(conn);
                    return $"All weapons added to inventory ({conn.Weapons.Count} total).";
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[GM WebUI] ERROR adding all weapons: {ex.Message}");
                    statusCode = 500;
                    return $"Failed to add all weapons: {ex.Message}";
                }
            }

            if (uri.AbsolutePath.Equals("/gm/weapons/remove", StringComparison.OrdinalIgnoreCase))
            {
                return BuildGmRemoveWeapon(conn, query);
            }

            if (uri.AbsolutePath.Equals("/gm/weapons/removeall", StringComparison.OrdinalIgnoreCase))
            {
                int count = conn.Weapons.Count;
                conn.Weapons.Clear();
                conn.WeaponIndex = 0;
                conn.SyncWeapons();
                return $"All weapons removed. Cleared {count} weapons from inventory.";
            }

            // Weather & Time Control routes
            if (uri.AbsolutePath.Equals("/gm/weather", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmWeatherUi();
            }

            if (uri.AbsolutePath.Equals("/gm/weather/set", StringComparison.OrdinalIgnoreCase))
            {
                uint weatherId = GetQueryUInt(query, "weatherId", 3);
                ClientToGameserver.GmSetWeather(conn, weatherId);
                return $"Weather set to {weatherId}.";
            }

            if (uri.AbsolutePath.Equals("/gm/time", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmTimeUi();
            }

            if (uri.AbsolutePath.Equals("/gm/time/set", StringComparison.OrdinalIgnoreCase))
            {
                uint hour = GetQueryUInt(query, "hour", 12);
                uint minute = GetQueryUInt(query, "minute", 0);
                ClientToGameserver.GmSetTime(conn, (int)hour, (int)minute);
                return $"Time set to {hour:D2}:{minute:D2}.";
            }

            // NPCs panel routes
            if (uri.AbsolutePath.Equals("/gm/npcs", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmNpcsUi();
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/status", StringComparison.OrdinalIgnoreCase))
            {
                return NpcSpawnHandlers.BuildNpcStatus(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/spawn", StringComparison.OrdinalIgnoreCase))
            {
                uint npcFormworkId = GetQueryUInt(query, "npcId", 40924922);
                UXVector3? npcPosition = TryBuildQueryPosition(query);
                NpcSpawnHandlers.SpawnNPC(conn, new uint[] { npcFormworkId }, npcPosition);
                return $"Spawned NPC with FormworkId={npcFormworkId}.";
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/spawn_batch", StringComparison.OrdinalIgnoreCase))
            {
                UXVector3? npcPosition = TryBuildQueryPosition(query);
                var npcFormworkIds = Game.State.NpcStateFactory.BuildNpcFormworkIds();
                NpcSpawnHandlers.SpawnNPC(conn, npcFormworkIds, npcPosition);
                return $"Spawned {npcFormworkIds.Length} NPCs.";
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/destroy", StringComparison.OrdinalIgnoreCase))
            {
                NpcSpawnHandlers.DestroyAllNpcs(conn);
                return "All spawned NPCs destroyed.";
            }

            // New endpoints for real-time NPC manipulation
            if (uri.AbsolutePath.Equals("/gm/npcs/list", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "application/json; charset=utf-8";
                return BuildNpcListJson(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/teleport", StringComparison.OrdinalIgnoreCase))
            {
                ulong entityId = GetQueryULong(query, "entityId", 0);
                if (entityId == 0)
                {
                    statusCode = 400;
                    return "Missing entityId parameter.";
                }
                float x = (float)GetQueryDouble(query, "x", 1000);
                float y = (float)GetQueryDouble(query, "y", 0);
                float z = (float)GetQueryDouble(query, "z", 2000);
                return TeleportNpc(conn, entityId, x, y, z);
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/set_state", StringComparison.OrdinalIgnoreCase))
            {
                ulong entityId = GetQueryULong(query, "entityId", 0);
                if (entityId == 0)
                {
                    statusCode = 400;
                    return "Missing entityId parameter.";
                }
                string stateStr = query.TryGetValue("state", out string? s) ? s : "Idle";
                return SetNpcState(conn, entityId, stateStr);
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/destroy_one", StringComparison.OrdinalIgnoreCase))
            {
                ulong entityId = GetQueryULong(query, "entityId", 0);
                if (entityId == 0)
                {
                    statusCode = 400;
                    return "Missing entityId parameter.";
                }
                return DestroyNpc(conn, entityId);
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/teleport_to", StringComparison.OrdinalIgnoreCase))
            {
                ulong entityId = GetQueryULong(query, "entityId", 0);
                return TeleportToNpc(conn, entityId);
            }

            if (uri.AbsolutePath.Equals("/gm/npcs/refresh", StringComparison.OrdinalIgnoreCase))
            {
                return RefreshNpcSpawn(conn);
            }

            // ===== GM Teleport =====
            if (uri.AbsolutePath.Equals("/gm/teleport", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmTeleportUi();
            }
            if (uri.AbsolutePath.Equals("/gm/teleport/go", StringComparison.OrdinalIgnoreCase))
            {
                float x = (float)GetQueryDouble(query, "x", 1000);
                float y = (float)GetQueryDouble(query, "y", 0);
                float z = (float)GetQueryDouble(query, "z", 2000);
                GmToolHandlers.GmTeleportXYZ(conn, x, y, z);
                return $"Teleported to ({x}, {y}, {z}).";
            }

            if (uri.AbsolutePath.Equals("/gm/player/info", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "application/json; charset=utf-8";
                return BuildPlayerInfoJson(conn);
            }

            if (uri.AbsolutePath.Equals("/gm/player/set_hp", StringComparison.OrdinalIgnoreCase))
            {
                float hpRate = (float)GetQueryDouble(query, "hpRate", 1.0);
                return SetPlayerHp(conn, hpRate);
            }

            // ===== GM Player Management =====
            if (uri.AbsolutePath.Equals("/gm/player", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmPlayerUi();
            }
            if (uri.AbsolutePath.Equals("/gm/player/heal", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmSetHp(conn, 1.0f);
                return "HP restored to 100%.";
            }
            if (uri.AbsolutePath.Equals("/gm/player/revive", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmRevive(conn);
                return "Player revived.";
            }
            if (uri.AbsolutePath.Equals("/gm/player/sethp", StringComparison.OrdinalIgnoreCase))
            {
                float hpRate = (float)GetQueryDouble(query, "hp", 1.0);
                GmToolHandlers.GmSetHp(conn, hpRate);
                return $"HP set to {hpRate}.";
            }
            if (uri.AbsolutePath.Equals("/gm/player/addbuff", StringComparison.OrdinalIgnoreCase))
            {
                uint buffId = GetQueryUInt(query, "buffId", 52606154);
                GmToolHandlers.GmAddBuff(conn, buffId);
                return $"Buff {buffId} added.";
            }
            if (uri.AbsolutePath.Equals("/gm/player/removebuff", StringComparison.OrdinalIgnoreCase))
            {
                uint buffId = GetQueryUInt(query, "buffId", 52606154);
                GmToolHandlers.GmRemoveBuff(conn, buffId);
                return $"Buff {buffId} removed.";
            }
            if (uri.AbsolutePath.Equals("/gm/player/setattr", StringComparison.OrdinalIgnoreCase))
            {
                uint attrId = GetQueryUInt(query, "attrId", 1);
                uint value = GetQueryUInt(query, "value", 1);
                GmToolHandlers.GmSetAttr(conn, attrId, value);
                return $"Attr {attrId} set to {value}.";
            }

            // ===== GM Items =====
            if (uri.AbsolutePath.Equals("/gm/items", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmItemsUi();
            }
            if (uri.AbsolutePath.Equals("/gm/items/add", StringComparison.OrdinalIgnoreCase))
            {
                uint itemId = GetQueryUInt(query, "itemId", 1);
                uint count = GetQueryUInt(query, "count", 1);
                GmToolHandlers.AddItem(conn, itemId, count);
                return $"Added item {itemId} x{count}.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addmoney", StringComparison.OrdinalIgnoreCase))
            {
                uint amount = GetQueryUInt(query, "amount", 1000);
                GmToolHandlers.AddMoney(conn, amount);
                return $"Added {amount} money.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/remove", StringComparison.OrdinalIgnoreCase))
            {
                uint itemId = GetQueryUInt(query, "itemId", 1);
                uint count = GetQueryUInt(query, "count", 1);
                GmToolHandlers.RemoveItem(conn, itemId, count);
                return $"Removed item {itemId} x{count}.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/clearbag", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.ClearBag(conn);
                return "Bag cleared.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addfashion", StringComparison.OrdinalIgnoreCase))
            {
                uint fashionId = GetQueryUInt(query, "fashionId", 1);
                GmToolHandlers.GmAddFashions(conn, fashionId);
                return $"Fashion {fashionId} added.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addallfashions", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmAddAllFashions(conn);
                return "All fashions added.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addfashionsuit", StringComparison.OrdinalIgnoreCase))
            {
                uint suitId = GetQueryUInt(query, "suitId", 11190001);
                GmToolHandlers.GmAddFashionSuits(conn, suitId);
                return $"Fashion suit {suitId} added.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addallfashionsuits", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmAddAllFashionSuits(conn);
                return "All fashion suits added.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addweapon", StringComparison.OrdinalIgnoreCase))
            {
                uint weaponTemplateId = GetQueryUInt(query, "templateId", 60000001);
                GmToolHandlers.GmAddWeapon(conn, weaponTemplateId);
                return $"Weapon template {weaponTemplateId} added.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addagent", StringComparison.OrdinalIgnoreCase))
            {
                uint agentId = GetQueryUInt(query, "agentId", 1001001);
                GmToolHandlers.GmAddAgent(conn, agentId);
                return $"Agent {agentId} added.";
            }
            if (uri.AbsolutePath.Equals("/gm/items/addallagents", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmAddAllAgents(conn);
                return "All agents added.";
            }

            // ===== GM Quests =====
            if (uri.AbsolutePath.Equals("/gm/quests", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmQuestsUi();
            }
            if (uri.AbsolutePath.Equals("/gm/quests/unlockall", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmUnlockAllQuest(conn);
                return "All quests unlocked.";
            }
            if (uri.AbsolutePath.Equals("/gm/quests/accept", StringComparison.OrdinalIgnoreCase))
            {
                uint taskId = GetQueryUInt(query, "taskId", 1);
                GmToolHandlers.ForceAcceptTask(conn, taskId);
                return $"Task {taskId} accepted.";
            }
            if (uri.AbsolutePath.Equals("/gm/quests/submit", StringComparison.OrdinalIgnoreCase))
            {
                uint taskId = GetQueryUInt(query, "taskId", 1);
                GmToolHandlers.ForceSubmitTask(conn, taskId);
                return $"Task {taskId} submitted.";
            }
            if (uri.AbsolutePath.Equals("/gm/quests/fail", StringComparison.OrdinalIgnoreCase))
            {
                uint taskId = GetQueryUInt(query, "taskId", 1);
                GmToolHandlers.ForceFailTask(conn, taskId);
                return $"Task {taskId} failed.";
            }

            // ===== GM Spawn =====
            if (uri.AbsolutePath.Equals("/gm/spawn", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmSpawnUi();
            }
            if (uri.AbsolutePath.Equals("/gm/spawn/enemy", StringComparison.OrdinalIgnoreCase))
            {
                uint enemyId = GetQueryUInt(query, "enemyId", 1);
                float x = (float)GetQueryDouble(query, "x", 1000);
                float y = (float)GetQueryDouble(query, "y", 0);
                float z = (float)GetQueryDouble(query, "z", 2000);
                GmToolHandlers.GmAddEnemy(conn, enemyId, x, y, z);
                return $"Enemy {enemyId} spawned at ({x}, {y}, {z}).";
            }
            if (uri.AbsolutePath.Equals("/gm/spawn/npc", StringComparison.OrdinalIgnoreCase))
            {
                uint npcId = GetQueryUInt(query, "npcId", 40924922);
                float x = (float)GetQueryDouble(query, "x", 1000);
                float y = (float)GetQueryDouble(query, "y", 0);
                float z = (float)GetQueryDouble(query, "z", 2000);
                GmToolHandlers.GmAddNpc(conn, npcId, x, y, z);
                return $"NPC {npcId} spawned at ({x}, {y}, {z}).";
            }

            // ===== GM Debug =====
            if (uri.AbsolutePath.Equals("/gm/debug", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmDebugUi();
            }
            if (uri.AbsolutePath.Equals("/gm/debug/freeskill", StringComparison.OrdinalIgnoreCase))
            {
                bool enable = GetQueryUInt(query, "enable", 1) == 1;
                GmToolHandlers.GmFreeSkill(conn, enable);
                return $"Free skill: {enable}.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/durabilityfree", StringComparison.OrdinalIgnoreCase))
            {
                bool enable = GetQueryUInt(query, "enable", 1) == 1;
                GmToolHandlers.GmWeaponDurabilityFree(conn, enable);
                return $"Weapon durability free: {enable}.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/resetcooldowns", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmRecoverAllSkillCooldown(conn);
                return "Skill cooldowns reset.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/opendebugpos", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmOpenDebugPosition(conn);
                return "Debug position opened.";
            }

            // ===== GM World =====
            if (uri.AbsolutePath.Equals("/gm/world", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmWorldUi();
            }
            if (uri.AbsolutePath.Equals("/gm/world/unlockfog", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmUnlockAllFogMap(conn);
                return "Fog map unlocked.";
            }
            if (uri.AbsolutePath.Equals("/gm/world/setreputation", StringComparison.OrdinalIgnoreCase))
            {
                uint factionId = GetQueryUInt(query, "factionId", 1);
                uint value = GetQueryUInt(query, "value", 100);
                GmToolHandlers.GmSetReputation(conn, factionId, value);
                return $"Reputation set for faction {factionId}.";
            }
            if (uri.AbsolutePath.Equals("/gm/world/addallspirits", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmAddAllSpirits(conn);
                return "All spirits added.";
            }
            if (uri.AbsolutePath.Equals("/gm/world/addallvehicles", StringComparison.OrdinalIgnoreCase))
            {
                GmToolHandlers.GmAddAllVehicles(conn);
                return "All vehicles added.";
            }

            // ===== GM RPC Dump =====
            if (uri.AbsolutePath.Equals("/gm/dump", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/html; charset=utf-8";
                return BuildGmDumpUi();
            }
            if (uri.AbsolutePath.Equals("/gm/dump/view", StringComparison.OrdinalIgnoreCase))
            {
                bool showHex = GetQueryUInt(query, "hex", 1) == 1;
                return RpcDumpService.GetDumpReport(showHex);
            }
            if (uri.AbsolutePath.Equals("/gm/dump/export", StringComparison.OrdinalIgnoreCase))
            {
                string filePath = RpcDumpService.ExportToFile();
                return $"Dump exported to: {filePath}";
            }
            if (uri.AbsolutePath.Equals("/gm/dump/clear", StringComparison.OrdinalIgnoreCase))
            {
                RpcDumpService.Clear();
                return "Dump data cleared.";
            }
            if (uri.AbsolutePath.Equals("/gm/dump/debug_on", StringComparison.OrdinalIgnoreCase))
            {
                RpcDumpService.DebugMode = true;
                return "Debug mode ON - all unhandled RPCs will be logged to console.";
            }
            if (uri.AbsolutePath.Equals("/gm/dump/debug_off", StringComparison.OrdinalIgnoreCase))
            {
                RpcDumpService.DebugMode = false;
                return "Debug mode OFF.";
            }
            if (uri.AbsolutePath.Equals("/gm/dump/enable", StringComparison.OrdinalIgnoreCase))
            {
                RpcDumpService.Enabled = true;
                return "RPC dump collection ENABLED.";
            }
            if (uri.AbsolutePath.Equals("/gm/dump/disable", StringComparison.OrdinalIgnoreCase))
            {
                RpcDumpService.Enabled = false;
                return "RPC dump collection DISABLED.";
            }

            // ===== GM Debug: Lua Error Collector =====
            if (uri.AbsolutePath.Equals("/gm/debug/luaerrors", StringComparison.OrdinalIgnoreCase))
            {
                contentType = "text/plain; charset=utf-8";
                return LuaErrorCollector.GetReport();
            }
            if (uri.AbsolutePath.Equals("/gm/debug/luaerrors/enable", StringComparison.OrdinalIgnoreCase))
            {
                LuaErrorCollector.Enabled = true;
                return "Lua Error Collector ENABLED.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/luaerrors/disable", StringComparison.OrdinalIgnoreCase))
            {
                LuaErrorCollector.Enabled = false;
                return "Lua Error Collector DISABLED.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/luaerrors/clear", StringComparison.OrdinalIgnoreCase))
            {
                LuaErrorCollector.Clear();
                return "Lua Error Collector cleared.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/luaerrors/export", StringComparison.OrdinalIgnoreCase))
            {
                string filePath = LuaErrorCollector.ExportToFile();
                return $"Lua errors exported to: {filePath}";
            }

            // ===== GM Debug: NPC Auto-Spawn Toggle =====
            if (uri.AbsolutePath.Equals("/gm/debug/npcautospawn", StringComparison.OrdinalIgnoreCase))
            {
                bool enabled = WorldPopulationBuilder.NpcAutoSpawnEnabled;
                return $"NPC Auto-Spawn is currently: {(enabled ? "ENABLED" : "DISABLED")}";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/npcautospawn/enable", StringComparison.OrdinalIgnoreCase))
            {
                WorldPopulationBuilder.NpcAutoSpawnEnabled = true;
                return "NPC Auto-Spawn ENABLED. NPCs will spawn on scene load and phone use.";
            }
            if (uri.AbsolutePath.Equals("/gm/debug/npcautospawn/disable", StringComparison.OrdinalIgnoreCase))
            {
                WorldPopulationBuilder.NpcAutoSpawnEnabled = false;
                return "NPC Auto-Spawn DISABLED. NPCs will NOT spawn automatically.";
            }


            // Per-type AetherAI spawn toggles: /gm/debug/spawntype/{type}/{on|off}
            if (uri.AbsolutePath.StartsWith("/gm/debug/spawntype", StringComparison.OrdinalIgnoreCase))
            {
                var parts = uri.AbsolutePath.TrimEnd('/').Split('/');
                if (parts.Length >= 6)
                {
                    string typeName = parts[4].ToLowerInvariant();
                    bool on = parts[5].Equals("on", StringComparison.OrdinalIgnoreCase);
                    switch (typeName)
                    {
                        case "static":  WorldPopulationBuilder.StaticNpcsEnabled = on; break;
                        case "crowd":   WorldPopulationBuilder.CrowdNpcsEnabled = on; break;
                        case "traffic": WorldPopulationBuilder.TrafficVehiclesEnabled = on; break;
                        case "parked":  WorldPopulationBuilder.ParkedVehiclesEnabled = on; break;
                        case "metro":   WorldPopulationBuilder.MetroNpcsEnabled = on; break;
                        default: return $"Unknown spawn type: {typeName}. Valid: static, crowd, traffic, parked, metro";
                    }
                    return $"Spawn type '{typeName}' → {(on ? "ON" : "OFF")}. Reconnect to apply.";
                }
                return $"static={WorldPopulationBuilder.StaticNpcsEnabled} crowd={WorldPopulationBuilder.CrowdNpcsEnabled} " +
                       $"traffic={WorldPopulationBuilder.TrafficVehiclesEnabled} parked={WorldPopulationBuilder.ParkedVehiclesEnabled} metro={WorldPopulationBuilder.MetroNpcsEnabled}";
            }

            // ── AOI Grid Manager routes ─────────────────────────────────
            if (uri.AbsolutePath.Equals("/gm/aoi", StringComparison.OrdinalIgnoreCase))
            {
                var aoiConn = GetActiveConnection();
                string status = aoiConn != null
                    ? $"grid=({aoiConn.LastGridX},{aoiConn.LastGridZ}) cells={aoiConn.LoadedDestructibleCells.Count} initialized={aoiConn.AOIInitialized}"
                    : "no active connection";
                return $"AOI Grid Driver\n  cellSize={AOIGridManager.GridCellSize}\n  destructibleRange={AOIGridManager.DestructibleRange}\n  sceneItemRange={AOIGridManager.SceneItemRange}\n  {status}";
            }

            if (uri.AbsolutePath.Equals("/gm/aoi/cellsize", StringComparison.OrdinalIgnoreCase))
            {
                float? val = GetQueryFloat(query, "value");
                if (val.HasValue && val.Value > 0)
                {
                    AOIGridManager.GridCellSize = val.Value;
                    return $"AOI cellSize set to {val.Value}";
                }
                return $"Current cellSize={AOIGridManager.GridCellSize}. Usage: /gm/aoi/cellsize?value=10";
            }

            if (uri.AbsolutePath.Equals("/gm/aoi/resend", StringComparison.OrdinalIgnoreCase))
            {
                var aoiConn = GetActiveConnection();
                if (aoiConn == null) return "No active connection.";
                AOIGridManager.ResetAOI(aoiConn);
                AOIGridManager.SendInitialAOI(aoiConn);
                return "AOI reset + resent.";
            }

            if (uri.AbsolutePath.Equals("/gm/aoi/range", StringComparison.OrdinalIgnoreCase))
            {
                float? destr = GetQueryFloat(query, "destructible");
                float? scene = GetQueryFloat(query, "scene");
                if (destr.HasValue) AOIGridManager.DestructibleRange = (int)destr.Value;
                if (scene.HasValue) AOIGridManager.SceneItemRange = (int)scene.Value;
                return $"AOI ranges: destructible={AOIGridManager.DestructibleRange} scene={AOIGridManager.SceneItemRange}";
            }

            if (uri.AbsolutePath.Equals("/gm/aoi/offset", StringComparison.OrdinalIgnoreCase))
            {
                float? ox = GetQueryFloat(query, "x");
                float? oz = GetQueryFloat(query, "z");
                if (ox.HasValue) AOIGridManager.GridOffsetX = ox.Value;
                if (oz.HasValue) AOIGridManager.GridOffsetZ = oz.Value;
                return $"AOI offset: X={AOIGridManager.GridOffsetX} Z={AOIGridManager.GridOffsetZ}";
            }

            // ===== GM Debug: Memory Manager =====
            if (uri.AbsolutePath.Equals("/gm/memory", StringComparison.OrdinalIgnoreCase))
            {
                return Game.MemoryManager.GetMemoryStats();
            }
            if (uri.AbsolutePath.Equals("/gm/memory/cleanup", StringComparison.OrdinalIgnoreCase))
            {
                Game.MemoryManager.ForceCleanup();
                return "Forced memory cleanup completed.";
            }
            if (uri.AbsolutePath.Equals("/gm/memory/stop", StringComparison.OrdinalIgnoreCase))
            {
                Game.MemoryManager.Stop();
                return "Memory manager stopped.";
            }
            if (uri.AbsolutePath.Equals("/gm/memory/start", StringComparison.OrdinalIgnoreCase))
            {
                Game.MemoryManager.Start();
                return "Memory manager started.";
            }

            // ===== GM Debug: Skill Manager =====
            if (uri.AbsolutePath.Equals("/gm/skill/info", StringComparison.OrdinalIgnoreCase))
            {
                return Game.SkillManager.GetDebugInfo();
            }
            if (uri.AbsolutePath.Equals("/gm/skill/clearcooldowns", StringComparison.OrdinalIgnoreCase))
            {
                Game.SkillManager.ClearAllCooldowns();
                return "All skill cooldowns cleared.";
            }
            if (uri.AbsolutePath.Equals("/gm/skill/clearbuffs", StringComparison.OrdinalIgnoreCase))
            {
                uint entityId = GetQueryUInt(query, "entityId", 0);
                if (entityId > 0)
                {
                    Game.SkillManager.ClearAllBuffs(entityId);
                    return $"Cleared all buffs for entity {entityId}.";
                }
                return "Missing entityId parameter.";
            }
            if (uri.AbsolutePath.Equals("/gm/skill/cleanup", StringComparison.OrdinalIgnoreCase))
            {
                Game.SkillManager.CleanupExpired();
                return "Skill manager cleanup completed.";
            }

            statusCode = 404;
            return "Unknown GM endpoint.";
        }

        // ======================== NPC Manipulation Helpers ========================

        private static string BuildNpcListJson(Connection conn)
        {
            var npcs = conn.GetLiveNpcs();
            var sb = new System.Text.StringBuilder();
            sb.Append("[");
            bool first = true;
            foreach (var npc in npcs)
            {
                if (!first) sb.Append(",");
                first = false;
                sb.Append("{");
                sb.Append($"\"entityId\":{npc.EntityId},");
                sb.Append($"\"formworkId\":{npc.FormworkId},");
                sb.Append($"\"posX\":{npc.PosX:F2},");
                sb.Append($"\"posY\":{npc.PosY:F2},");
                sb.Append($"\"posZ\":{npc.PosZ:F2},");
                sb.Append($"\"facing\":{npc.Facing:F1},");
                sb.Append($"\"state\":\"{npc.CurrentState}\",");
                sb.Append($"\"isDestroyed\":{npc.IsDestroyed.ToString().ToLower()}");
                sb.Append("}");
            }
            sb.Append("]");
            return sb.ToString();
        }

        private static string TeleportNpc(Connection conn, ulong entityId, float x, float y, float z)
        {
            var npc = conn.GetNpcById(entityId);
            if (npc == null)
                return $"NPC with entityId={entityId} not found.";

            npc.PosX = x;
            npc.PosY = y;
            npc.PosZ = z;
            npc.OriginX = x;
            npc.OriginZ = z;

            // For now, just update server-side position
            // Client-side position sync would require additional RPC implementation
            return $"NPC {entityId} position updated to ({x:F2}, {y:F2}, {z:F2}). Note: Client-side sync not implemented yet.";
        }

        private static string SetNpcState(Connection conn, ulong entityId, string stateStr)
        {
            var npc = conn.GetNpcById(entityId);
            if (npc == null)
                return $"NPC with entityId={entityId} not found.";

            if (!System.Enum.TryParse<Connection.NpcState>(stateStr, true, out var newState))
            {
                return $"Invalid state '{stateStr}'. Valid states: {string.Join(", ", System.Enum.GetNames(typeof(Connection.NpcState)))}";
            }

            npc.CurrentState = newState;
            return $"NPC {entityId} state changed to {newState}.";
        }

        private static string DestroyNpc(Connection conn, ulong entityId)
        {
            var npc = conn.GetNpcById(entityId);
            if (npc == null)
                return $"NPC with entityId={entityId} not found.";

            conn.MarkNpcDestroyed(entityId);
            return $"NPC {entityId} marked as destroyed on server. Note: Client-side sync not implemented yet.";
        }

        private static string TeleportToNpc(Connection conn, ulong entityId)
        {
            var npc = conn.GetNpcById(entityId);
            if (npc == null)
            {
                var availableIds = string.Join(", ", conn.GetLiveNpcs().Select(n => n.EntityId));
                return $"NPC {entityId} not found. Available NPCs: {availableIds}";
            }

            float x = npc.PosX;
            float y = npc.PosY + 2f; // Offset slightly above the NPC
            float z = npc.PosZ;

            GmToolHandlers.GmTeleportXYZ(conn, x, y, z);
            return $"Teleported to NPC {entityId} (Formwork: {npc.FormworkId}) at ({x:F2}, {y:F2}, {z:F2}).";
        }

        private static string TeleportToMetroTrain(Connection conn, int trainId)
        {
            var metros = conn.BuildRunningMetros();
            var train = metros.FirstOrDefault(m => m.Id == trainId);
            if (train == null)
            {
                var availableIds = string.Join(", ", metros.Select(m => m.Id));
                return $"Train {trainId} not found. Available trains: {availableIds}";
            }

            float x = train.Position.X;
            float y = train.Position.Y + 2f; // Offset slightly above the train
            float z = train.Position.Z;

            GmToolHandlers.GmTeleportXYZ(conn, x, y, z);
            return $"Teleported to train {trainId} (Line {train.LineId}) at ({x:F2}, {y:F2}, {z:F2}).";
        }

        private static string RefreshNpcSpawn(Connection conn)
        {
            if (!conn.HasLastKnownPlayerPosition)
                return "No player position known. Enter the game first.";

            float x = conn.LastKnownPlayerPosition.X;
            float z = conn.LastKnownPlayerPosition.Z;

            var (gx, gz) = AOIGridManager.WorldToGrid(x, z);

            // Force NPC spawn/despawn for current cell
            WorldPopulationBuilder.OnPlayerCellChanged(conn, gx, gz);

            var liveNpcs = conn.GetLiveNpcs();
            return $"NPC spawn refreshed for grid cell ({gx}, {gz}). Current live NPCs: {liveNpcs.Count}";
        }

        private static string TeleportToVehicle(Connection conn, ulong vehicleId)
        {
            var vehicle = conn.SpawnedVehicles.FirstOrDefault(v => v.EntityId == vehicleId && !v.IsDestroyed);
            if (vehicle == null)
            {
                var availableIds = string.Join(", ", conn.SpawnedVehicles.Where(v => !v.IsDestroyed).Select(v => v.EntityId));
                return $"Vehicle {vehicleId} not found or destroyed. Available vehicles: {availableIds}";
            }

            float x = vehicle.SpawnX;
            float y = vehicle.SpawnY + 2f; // Offset slightly above the vehicle
            float z = vehicle.SpawnZ;

            GmToolHandlers.GmTeleportXYZ(conn, x, y, z);
            return $"Teleported to vehicle {vehicleId} (Config: {vehicle.ConfigId}) at ({x:F2}, {y:F2}, {z:F2}).";
        }

        private static string BuildVehicleListJson(Connection conn)
        {
            var vehicles = conn.SpawnedVehicles.Where(v => !v.IsDestroyed);
            var sb = new System.Text.StringBuilder();
            sb.Append("[");
            bool first = true;
            foreach (var v in vehicles)
            {
                if (!first) sb.Append(",");
                first = false;
                sb.Append("{");
                sb.Append($"\"entityId\":{v.EntityId},");
                sb.Append($"\"configId\":{v.ConfigId},");
                sb.Append($"\"posX\":{v.SpawnX:F2},");
                sb.Append($"\"posY\":{v.SpawnY:F2},");
                sb.Append($"\"posZ\":{v.SpawnZ:F2},");
                sb.Append($"\"facing\":{v.Facing:F1},");
                sb.Append($"\"colorConfigId\":{v.ColorConfigId},");
                sb.Append($"\"isDestroyed\":{v.IsDestroyed.ToString().ToLower()}");
                sb.Append("}");
            }
            sb.Append("]");
            return sb.ToString();
        }

        private static string BuildMetroListJson(Connection conn)
        {
            var metros = conn.BuildRunningMetros();
            var sb = new System.Text.StringBuilder();
            sb.Append("[");
            bool first = true;
            foreach (var m in metros)
            {
                if (!first) sb.Append(",");
                first = false;
                sb.Append("{");
                sb.Append($"\"id\":{m.Id},");
                sb.Append($"\"lineId\":{m.LineId},");
                sb.Append($"\"elapsedTime\":{m.ElapsedTime:F2},");
                sb.Append($"\"positionX\":{m.Position.X:F2},");
                sb.Append($"\"positionY\":{m.Position.Y:F2},");
                sb.Append($"\"positionZ\":{m.Position.Z:F2},");
                sb.Append($"\"facing\":{m.Facing:F1},");
                sb.Append($"\"speed\":{m.Speed:F2},");
                sb.Append($"\"isFinalTrain\":{m.IsFinalTrain.ToString().ToLower()}");
                sb.Append("}");
            }
            sb.Append("]");
            return sb.ToString();
        }

        private static string BuildPlayerInfoJson(Connection conn)
        {
            var currentSpirit = conn.GetCurrentSpirit();
            var sb = new System.Text.StringBuilder();
            sb.Append("{");
            sb.Append($"\"pid\":{conn.Pid},");
            sb.Append($"\"currentSpiritTemplateId\":{currentSpirit.TemplateId},");
            sb.Append($"\"currentSpiritInstanceId\":{currentSpirit.Id},");
            sb.Append($"\"totalSpirits\":{conn.Spirits.Count},");
            sb.Append($"\"totalWeapons\":{conn.Weapons.Count},");
            sb.Append($"\"currentWeaponIndex\":{conn.WeaponIndex},");
            sb.Append($"\"hasLastKnownPosition\":{conn.HasLastKnownPlayerPosition.ToString().ToLower()},");
            sb.Append($"\"positionX\":{conn.LastKnownPlayerPosition.X:F2},");
            sb.Append($"\"positionY\":{conn.LastKnownPlayerPosition.Y:F2},");
            sb.Append($"\"positionZ\":{conn.LastKnownPlayerPosition.Z:F2},");
            sb.Append($"\"currentVehicleId\":{conn.CurrentVehicleId},");
            sb.Append($"\"currentVehicleSeat\":{conn.CurrentVehicleSeat}");
            sb.Append("}");
            return sb.ToString();
        }

        private static string SetPlayerHp(Connection conn, float hpRate)
        {
            if (hpRate < 0 || hpRate > 1)
                return "HP rate must be between 0.0 and 1.0";
            
            GmToolHandlers.GmSetHp(conn, hpRate);
            return $"HP set to {hpRate * 100:F0}%";
        }
    }
}
