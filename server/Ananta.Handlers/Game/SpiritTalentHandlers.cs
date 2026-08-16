using System;
using System.Linq;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    // ── Request Args ──────────────────────────────────────────────

    public class AskActiveSpiritJobTalentLayerArg : SerializedClass
    {
        public uint spiritid;
        public uint jobclassid;
        public uint talentid;
        public uint addlayer;
        public AskActiveSpiritJobTalentLayerArg() { onlyFields = true; }
    }

    public class AskResetSpiritJobTalentArg : SerializedClass
    {
        public uint spiritid;
        public uint jobclassid;
        public AskResetSpiritJobTalentArg() { onlyFields = true; }
    }

    public class AskConvertCommonSpiritTalentExpArg : SerializedClass
    {
        public uint spiritid;
        public uint convertexp;
        public AskConvertCommonSpiritTalentExpArg() { onlyFields = true; }
    }

    // ── Sync Notify Args (server → client, primitive fields) ──────

    public class SyncActiveSpiritJobTalentLayerArgs : SerializedClass
    {
        public uint spiritid;
        public uint jobclassid;
        public uint talentid;
        public uint layer;
        public SyncActiveSpiritJobTalentLayerArgs() { onlyFields = true; }
    }

    public class SyncSpiritJobTalentPointArgs : SerializedClass
    {
        public uint spiritid;
        public uint jobclassid;
        public uint talentpoint;
        public int reason;
        public SyncSpiritJobTalentPointArgs() { onlyFields = true; }
    }

    public class SyncSpiritTalentExpAndLevelArgs : SerializedClass
    {
        public uint spiritid;
        public uint addexp;
        public uint exp;
        public uint level;
        public SyncSpiritTalentExpAndLevelArgs() { onlyFields = true; }
    }

    public class SyncCommonSpiritTalentExpArgs : SerializedClass
    {
        public int changeexp;
        public uint exp;
        public SyncCommonSpiritTalentExpArgs() { onlyFields = true; }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class SpiritTalentHandlers
    {
        /// <summary>
        /// Helper: find a SpiritInfo by templateId in the connection's spirit list.
        /// </summary>
        private static SpiritInfo? FindSpirit(Connection conn, uint spiritTemplateId)
        {
            return conn.Spirits.FirstOrDefault(s => s.TemplateId == spiritTemplateId);
        }

        /// <summary>
        /// Helper: get the correct TalentInfo based on jobClassId.
        /// jobClassId == 0 → spirit's base TalentInfo
        /// jobClassId != 0 → job's TalentInfo (from SpiritJobInfo.AvailableJobs)
        /// </summary>
        private static SpiritJobTalentInfo? GetJobTalentInfo(SpiritInfo spirit, uint jobClassId)
        {
            if (jobClassId == 0)
                return null; // caller should use spirit.TalentInfo instead

            if (spirit.SpiritJobInfo?.AvailableJobs == null)
                return null;

            // Find the job by its Job id matching the jobClassId
            // AvailableJobs is keyed by jobId, the Job field inside holds the class id
            foreach (var kvp in spirit.SpiritJobInfo.AvailableJobs)
            {
                if (kvp.Value.Job == jobClassId)
                    return kvp.Value.TalentInfo;
            }
            return null;
        }

        /// <summary>
        /// Helper: get either the spirit's base TalentInfo or the job's TalentInfo.
        /// Returns a SpiritJobTalentInfo-compatible view.
        /// For base talents (jobClassId=0), we work with SpiritTalentInfo directly.
        /// </summary>
        private static (SpiritTalentInfo? baseTalent, SpiritJobTalentInfo? jobTalent) GetTalentTarget(SpiritInfo spirit, uint jobClassId)
        {
            if (jobClassId == 0)
                return (spirit.TalentInfo, null);
            else
                return (null, GetJobTalentInfo(spirit, jobClassId));
        }

        /// <summary>
        /// Send a Notify packet with primitive-style args.
        /// </summary>
        private static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            UxRpcMessage notify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcMethodId = (int)methodId,
            };
            notify.SetArgs(methodId, args);
            conn.SendPacket(notify);
        }

        /// <summary>
        /// Send an empty success Return response.
        /// </summary>
        private static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        /// <summary>
        /// AskActiveSpiritJobTalentLayer:
        /// Activate a talent node for a spirit (base or job-specific).
        /// Deducts 1 TalentPoint, updates UnlockTalentInfoDict, sends sync notifiers.
        /// </summary>
        [Handler(MethodId.AskActiveSpiritJobTalentLayer)]
        public static void AskActiveSpiritJobTalentLayerHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskActiveSpiritJobTalentLayerArg>();
            uint spiritId = args.spiritid;
            uint jobClassId = args.jobclassid;
            uint talentId = args.talentid;
            uint addLayer = args.addlayer;

            Console.WriteLine($"[SpiritTalent] AskActiveSpiritJobTalentLayer spirit={spiritId} job={jobClassId} talent={talentId} layer={addLayer}");

            var spirit = FindSpirit(conn, spiritId);
            if (spirit == null)
            {
                Console.WriteLine($"[SpiritTalent] Spirit {spiritId} not found");
                SendEmptySuccessReturn(conn, msg, MethodId.AskActiveSpiritJobTalentLayer);
                return;
            }

            var (baseTalent, jobTalent) = GetTalentTarget(spirit, jobClassId);

            if (jobClassId == 0)
            {
                // Base spirit talent
                if (baseTalent == null)
                {
                    Console.WriteLine($"[SpiritTalent] Spirit {spiritId} has no TalentInfo");
                    SendEmptySuccessReturn(conn, msg, MethodId.AskActiveSpiritJobTalentLayer);
                    return;
                }

                if (baseTalent.UnlockTalentInfoDict == null)
                    baseTalent.UnlockTalentInfoDict = new();

                // Set or update the talent layer
                baseTalent.UnlockTalentInfoDict[talentId] = new SpiritOrJobTalentNodeInfo()
                {
                    TalentId = talentId,
                    Layer = addLayer
                };

                // Deduct talent point if available
                if (baseTalent.TalentPoint > 0)
                    baseTalent.TalentPoint--;
                baseTalent.SpentTalentPoint++;
            }
            else
            {
                // Job-specific talent
                if (jobTalent == null)
                {
                    Console.WriteLine($"[SpiritTalent] Job {jobClassId} not found for spirit {spiritId}");
                    SendEmptySuccessReturn(conn, msg, MethodId.AskActiveSpiritJobTalentLayer);
                    return;
                }

                if (jobTalent.UnlockTalentInfoDict == null)
                    jobTalent.UnlockTalentInfoDict = new();

                jobTalent.UnlockTalentInfoDict[talentId] = new SpiritOrJobTalentNodeInfo()
                {
                    TalentId = talentId,
                    Layer = addLayer
                };

                if (jobTalent.TalentPoint > 0)
                    jobTalent.TalentPoint--;
                jobTalent.SpentTalentPoint++;
            }

            // Send return (success)
            SendEmptySuccessReturn(conn, msg, MethodId.AskActiveSpiritJobTalentLayer);

            // Send SyncActiveSpiritJobTalentLayer notify
            SendNotify(conn, MethodId.SyncActiveSpiritJobTalentLayer, new SyncActiveSpiritJobTalentLayerArgs()
            {
                spiritid = spiritId,
                jobclassid = jobClassId,
                talentid = talentId,
                layer = addLayer
            });

            // Send updated talent point count
            uint currentPoints = jobClassId == 0
                ? (baseTalent?.TalentPoint ?? 0)
                : (jobTalent?.TalentPoint ?? 0);

            SendNotify(conn, MethodId.SyncSpiritJobTalentPoint, new SyncSpiritJobTalentPointArgs()
            {
                spiritid = spiritId,
                jobclassid = jobClassId,
                talentpoint = currentPoints,
                reason = 0 // 0 = talent activation
            });
        }

        /// <summary>
        /// AskResetSpiritJobTalent:
        /// Reset all talents for a specific job on a spirit.
        /// Clears UnlockTalentInfoDict and refunds spent talent points.
        /// </summary>
        [Handler(MethodId.AskResetSpiritJobTalent)]
        public static void AskResetSpiritJobTalentHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskResetSpiritJobTalentArg>();
            uint spiritId = args.spiritid;
            uint jobClassId = args.jobclassid;

            Console.WriteLine($"[SpiritTalent] AskResetSpiritJobTalent spirit={spiritId} job={jobClassId}");

            var spirit = FindSpirit(conn, spiritId);
            if (spirit == null)
            {
                Console.WriteLine($"[SpiritTalent] Spirit {spiritId} not found");
                SendEmptySuccessReturn(conn, msg, MethodId.AskResetSpiritJobTalent);
                return;
            }

            var (baseTalent, jobTalent) = GetTalentTarget(spirit, jobClassId);

            uint refundedPoints = 0;

            if (jobClassId == 0)
            {
                if (baseTalent != null)
                {
                    refundedPoints = baseTalent.SpentTalentPoint;
                    baseTalent.UnlockTalentInfoDict = new();
                    baseTalent.TalentPoint += refundedPoints;
                    baseTalent.SpentTalentPoint = 0;
                }
            }
            else
            {
                if (jobTalent != null)
                {
                    refundedPoints = jobTalent.SpentTalentPoint;
                    jobTalent.UnlockTalentInfoDict = new();
                    jobTalent.TalentPoint += refundedPoints;
                    jobTalent.SpentTalentPoint = 0;
                }
            }

            Console.WriteLine($"[SpiritTalent] Reset {refundedPoints} talent points for spirit={spiritId} job={jobClassId}");

            // Send return (success)
            SendEmptySuccessReturn(conn, msg, MethodId.AskResetSpiritJobTalent);

            // Send updated talent point count
            uint currentPoints = jobClassId == 0
                ? (baseTalent?.TalentPoint ?? 0)
                : (jobTalent?.TalentPoint ?? 0);

            SendNotify(conn, MethodId.SyncSpiritJobTalentPoint, new SyncSpiritJobTalentPointArgs()
            {
                spiritid = spiritId,
                jobclassid = jobClassId,
                talentpoint = currentPoints,
                reason = 1 // 1 = talent reset
            });
        }

        /// <summary>
        /// AskConvertCommonSpiritTalentExp:
        /// Convert common (shared) talent exp into a specific spirit's talent exp.
        /// Deducts from CommonSpiritTalentExp, adds to spirit's TalentInfo.Exp,
        /// and handles level-ups (every 1000 exp = 1 level, granting 1 talent point).
        /// </summary>
        [Handler(MethodId.AskConvertCommonSpiritTalentExp)]
        public static void AskConvertCommonSpiritTalentExpHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskConvertCommonSpiritTalentExpArg>();
            uint spiritId = args.spiritid;
            uint convertExp = args.convertexp;

            Console.WriteLine($"[SpiritTalent] AskConvertCommonSpiritTalentExp spirit={spiritId} exp={convertExp}");

            var spirit = FindSpirit(conn, spiritId);
            if (spirit == null || spirit.TalentInfo == null)
            {
                Console.WriteLine($"[SpiritTalent] Spirit {spiritId} not found or no TalentInfo");
                SendEmptySuccessReturn(conn, msg, MethodId.AskConvertCommonSpiritTalentExp);
                return;
            }

            // Clamp to available common exp
            uint actualConvert = Math.Min(convertExp, conn.CommonSpiritTalentExp);
            if (actualConvert == 0)
            {
                Console.WriteLine($"[SpiritTalent] No common talent exp to convert");
                SendEmptySuccessReturn(conn, msg, MethodId.AskConvertCommonSpiritTalentExp);
                return;
            }

            // Deduct from common pool
            conn.CommonSpiritTalentExp -= actualConvert;

            // Add to spirit's talent exp
            uint oldExp = spirit.TalentInfo.Exp;
            uint oldLevel = spirit.TalentInfo.Level;
            spirit.TalentInfo.Exp += actualConvert;

            // Level up: every 1000 exp = 1 level, each level grants 1 talent point
            uint newLevel = oldLevel + (spirit.TalentInfo.Exp / 1000) - (oldExp / 1000);
            uint levelsGained = newLevel - oldLevel;
            spirit.TalentInfo.Level = newLevel;
            spirit.TalentInfo.TalentPoint += levelsGained;

            Console.WriteLine($"[SpiritTalent] Converted {actualConvert} exp: spirit={spiritId} exp={spirit.TalentInfo.Exp} level={spirit.TalentInfo.Level} (+{levelsGained} levels, +{levelsGained} points)");

            // Send return (success)
            SendEmptySuccessReturn(conn, msg, MethodId.AskConvertCommonSpiritTalentExp);

            // Send SyncSpiritTalentExpAndLevel notify
            SendNotify(conn, MethodId.SyncSpiritTalentExpAndLevel, new SyncSpiritTalentExpAndLevelArgs()
            {
                spiritid = spiritId,
                addexp = actualConvert,
                exp = spirit.TalentInfo.Exp,
                level = spirit.TalentInfo.Level
            });

            // Send SyncCommonSpiritTalentExp notify
            SendNotify(conn, MethodId.SyncCommonSpiritTalentExp, new SyncCommonSpiritTalentExpArgs()
            {
                changeexp = -(int)actualConvert,
                exp = conn.CommonSpiritTalentExp
            });
        }
    }
}
