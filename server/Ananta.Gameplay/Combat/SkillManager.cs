using System;
using System.Collections.Generic;
using AnantaTestGameServer.Configs;
using AnantaTestGameServer;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Messages;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Skill Manager - manages skill cooldowns, execution, and buff application.
    /// </summary>
    public static class SkillManager
    {
        // Skill cooldown tracking: skillId -> cooldownEndTime (timestamp)
        private static readonly Dictionary<uint, long> _skillCooldowns = new();
        private static readonly object _lock = new();

        // Active buffs: entityId -> (buffId -> (endTime, instanceId))
        private static readonly Dictionary<ulong, Dictionary<uint, (long endTime, uint instanceId)>> _activeBuffs = new();

        // Skill damage multipliers (simplified)
        private static readonly Dictionary<uint, float> _skillDamageMultipliers = new();

        // Buff instance ID counter
        private static uint _nextBuffInstanceId = 1000000;

        // Local definitions for buff sync args (from ClientToGameserver namespace)
        private class AskAddClientBuffArgs : SerializedClass
        {
            public ulong unitId;
            public uint buffId;
            public int buffLayer;
            public AskAddClientBuffArgs() { onlyFields = true; }
        }

        private class AskRemoveClientBuff : SerializedClass
        {
            public ulong unitId;
            public uint buffId;
            public AskRemoveClientBuff() { onlyFields = true; }
        }

        /// <summary>
        /// Check if a skill is on cooldown.
        /// </summary>
        public static bool IsSkillOnCooldown(uint skillId)
        {
            lock (_lock)
            {
                if (!_skillCooldowns.TryGetValue(skillId, out var endTime))
                    return false;

                return DateTime.UtcNow.Ticks / 10000 < endTime; // Convert to milliseconds
            }
        }

        /// <summary>
        /// Get remaining cooldown time in milliseconds.
        /// </summary>
        public static long GetSkillCooldownRemaining(uint skillId)
        {
            lock (_lock)
            {
                if (!_skillCooldowns.TryGetValue(skillId, out var endTime))
                    return 0;

                long now = DateTime.UtcNow.Ticks / 10000;
                return Math.Max(0, endTime - now);
            }
        }

        /// <summary>
        /// Set skill cooldown.
        /// </summary>
        public static void SetSkillCooldown(uint skillId, long cooldownMs)
        {
            lock (_lock)
            {
                long now = DateTime.UtcNow.Ticks / 10000;
                _skillCooldowns[skillId] = now + cooldownMs;
            }
        }

        /// <summary>
        /// Clear skill cooldown.
        /// </summary>
        public static void ClearSkillCooldown(uint skillId)
        {
            lock (_lock)
            {
                _skillCooldowns.Remove(skillId);
            }
        }

        /// <summary>
        /// Clear all skill cooldowns.
        /// </summary>
        public static void ClearAllCooldowns()
        {
            lock (_lock)
            {
                _skillCooldowns.Clear();
            }
        }

        /// <summary>
        /// Apply a buff to an entity and sync with client.
        /// </summary>
        public static void ApplyBuff(ulong entityId, uint buffId, long durationMs, Connection? conn = null)
        {
            lock (_lock)
            {
                if (!_activeBuffs.TryGetValue(entityId, out var buffs))
                {
                    buffs = new Dictionary<uint, (long, uint)>();
                    _activeBuffs[entityId] = buffs;
                }

                long now = DateTime.UtcNow.Ticks / 10000;
                uint instanceId = _nextBuffInstanceId++;
                buffs[buffId] = (now + durationMs, instanceId);

                Console.WriteLine($"[SkillManager] Applied buff {buffId} to entity {entityId} for {durationMs}ms (instance: {instanceId})");

                // Sync with client if connection is provided
                if (conn != null)
                {
                    SyncBuffAddToClient(conn, entityId, buffId, instanceId, durationMs);
                }
            }
        }

        /// <summary>
        /// Remove a buff from an entity and sync with client.
        /// </summary>
        public static void RemoveBuff(ulong entityId, uint buffId, Connection? conn = null)
        {
            lock (_lock)
            {
                if (_activeBuffs.TryGetValue(entityId, out var buffs))
                {
                    buffs.Remove(buffId);
                    Console.WriteLine($"[SkillManager] Removed buff {buffId} from entity {entityId}");

                    // Sync with client if connection is provided
                    if (conn != null)
                    {
                        SyncBuffRemoveToClient(conn, entityId, buffId);
                    }
                }
            }
        }

        /// <summary>
        /// Check if an entity has a specific buff.
        /// </summary>
        public static bool HasBuff(ulong entityId, uint buffId)
        {
            lock (_lock)
            {
                if (!_activeBuffs.TryGetValue(entityId, out var buffs))
                    return false;

                if (!buffs.TryGetValue(buffId, out var data))
                    return false;

                long now = DateTime.UtcNow.Ticks / 10000;
                if (now >= data.endTime)
                {
                    buffs.Remove(buffId);
                    return false;
                }

                return true;
            }
        }

        /// <summary>
        /// Get all active buffs for an entity.
        /// </summary>
        public static List<uint> GetActiveBuffs(ulong entityId)
        {
            lock (_lock)
            {
                if (!_activeBuffs.TryGetValue(entityId, out var buffs))
                    return new List<uint>();

                long now = DateTime.UtcNow.Ticks / 10000;
                var active = new List<uint>();

                var expired = new List<uint>();
                foreach (var kvp in buffs)
                {
                    if (now >= kvp.Value.endTime)
                    {
                        expired.Add(kvp.Key);
                    }
                    else
                    {
                        active.Add(kvp.Key);
                    }
                }

                // Remove expired buffs
                foreach (var buffId in expired)
                {
                    buffs.Remove(buffId);
                }

                return active;
            }
        }

        /// <summary>
        /// Clear all buffs for an entity.
        /// </summary>
        public static void ClearAllBuffs(ulong entityId)
        {
            lock (_lock)
            {
                _activeBuffs.Remove(entityId);
            }
        }

        /// <summary>
        /// Calculate skill damage (simplified).
        /// </summary>
        public static float CalculateSkillDamage(uint skillId, float baseDamage, ulong targetId)
        {
            float multiplier = 1.0f;
            if (_skillDamageMultipliers.TryGetValue(skillId, out var mult))
            {
                multiplier = mult;
            }

            // Apply buff modifiers if target has buffs
            var buffs = GetActiveBuffs(targetId);
            foreach (var buffId in buffs)
            {
                var buff = ConfigManager.GetBuff(buffId);
                if (buff != null)
                {
                    // Simplified: some buffs reduce damage
                    if (buff.Type == 1) // Assume type 1 is damage reduction
                    {
                        multiplier *= 0.8f;
                    }
                }
            }

            return baseDamage * multiplier;
        }

        /// <summary>
        /// Set skill damage multiplier.
        /// </summary>
        public static void SetSkillDamageMultiplier(uint skillId, float multiplier)
        {
            _skillDamageMultipliers[skillId] = multiplier;
        }

        /// <summary>
        /// Cleanup expired buffs and cooldowns (call periodically).
        /// </summary>
        public static void CleanupExpired()
        {
            lock (_lock)
            {
                long now = DateTime.UtcNow.Ticks / 10000;

                // Cleanup expired cooldowns
                var expiredCooldowns = new List<uint>();
                foreach (var kvp in _skillCooldowns)
                {
                    if (now >= kvp.Value)
                    {
                        expiredCooldowns.Add(kvp.Key);
                    }
                }
                foreach (var skillId in expiredCooldowns)
                {
                    _skillCooldowns.Remove(skillId);
                }

                // Cleanup expired buffs
                foreach (var kvp in _activeBuffs)
                {
                    var expiredBuffs = new List<uint>();
                    foreach (var buffKvp in kvp.Value)
                    {
                        if (now >= buffKvp.Value.endTime)
                        {
                            expiredBuffs.Add(buffKvp.Key);
                        }
                    }
                    foreach (var buffId in expiredBuffs)
                    {
                        kvp.Value.Remove(buffId);
                    }
                }
            }
        }

        /// <summary>
        /// Get debug info.
        /// </summary>
        public static string GetDebugInfo()
        {
            lock (_lock)
            {
                return $"Cooldowns: {_skillCooldowns.Count}, Active Buffs: {_activeBuffs.Count}";
            }
        }

        /// <summary>
        /// Sync buff add to client.
        /// </summary>
        private static void SyncBuffAddToClient(Connection conn, ulong entityId, uint buffId, uint instanceId, long durationMs)
        {
            try
            {
                var rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncUnitAddBuff,
                };
                rsp.SetArgs(MethodId.SyncUnitAddBuff, new AskAddClientBuffArgs()
                {
                    unitId = entityId,
                    buffId = buffId,
                    buffLayer = 1
                });
                conn.SendPacket(rsp);
                Console.WriteLine($"[SkillManager] Synced buff add: {buffId} to entity {entityId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SkillManager] Failed to sync buff add: {ex.Message}");
            }
        }

        /// <summary>
        /// Sync buff remove to client.
        /// </summary>
        private static void SyncBuffRemoveToClient(Connection conn, ulong entityId, uint buffId)
        {
            try
            {
                var rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncUnitRemoveBuff,
                };
                rsp.SetArgs(MethodId.SyncUnitRemoveBuff, new AskRemoveClientBuff()
                {
                    unitId = entityId,
                    buffId = buffId
                });
                conn.SendPacket(rsp);
                Console.WriteLine($"[SkillManager] Synced buff remove: {buffId} from entity {entityId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SkillManager] Failed to sync buff remove: {ex.Message}");
            }
        }

        /// <summary>
        /// Sync full buff list to client.
        /// </summary>
        public static void SyncBuffListToClient(Connection conn, ulong entityId)
        {
            try
            {
                var buffs = GetActiveBuffs(entityId);
                var buffList = new List<BuffViewData>();

                lock (_lock)
                {
                    if (_activeBuffs.TryGetValue(entityId, out var entityBuffs))
                    {
                        long now = DateTime.UtcNow.Ticks / 10000;
                        foreach (var kvp in entityBuffs)
                        {
                            if (now < kvp.Value.endTime)
                            {
                                var buffConfig = ConfigManager.GetBuff(kvp.Key);
                                if (buffConfig != null)
                                {
                                    buffList.Add(new BuffViewData()
                                    {
                                        Id = kvp.Key,
                                        InstanceId = kvp.Value.instanceId,
                                        ReleaserId = entityId,
                                        ExpireTime = kvp.Value.endTime / 1000.0, // Convert to seconds
                                        Tier = (uint)buffConfig.Quality,
                                        Permanent = buffConfig.Duration == 0
                                    });
                                }
                            }
                        }
                    }
                }

                var rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncUnitBuffList,
                };
                rsp.SetArgs(MethodId.SyncUnitBuffList, new SyncUnitBuffList()
                {
                    entityId = entityId,
                    buffList = buffList
                });
                conn.SendPacket(rsp);
                Console.WriteLine($"[SkillManager] Synced buff list: {buffList.Count} buffs for entity {entityId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SkillManager] Failed to sync buff list: {ex.Message}");
            }
        }
    }
}
