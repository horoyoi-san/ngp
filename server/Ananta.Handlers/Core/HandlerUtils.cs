using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal static class HandlerUtils
    {
        internal static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
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

        internal static void SendReturn(Connection conn, UxRpcMessage msg, MethodId methodId, SerializedClass args)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            rsp.SetArgs(methodId, args);
            conn.SendPacket(rsp);
        }

        internal static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            rsp.SetArgs(methodId, args);
            conn.SendPacket(rsp);
        }

        internal static void SendTaskMessage(Connection conn, uint taskId, string message, float duration = 3.0f)
        {
            SendNotify(conn, MethodId.SyncShowTaskMessage, new SyncShowTaskMessageArgs()
            {
                taskId = taskId,
                message = message,
                duration = duration
            });
            Console.WriteLine($"[Task] Sent task message: taskId={taskId}, message={message}, duration={duration}s");
        }

        internal static void SendPhoneInfos(Connection conn, uint spiritId, PhoneInfos phoneInfos)
        {
            SendNotify(conn, MethodId.AddSpiritPhoneInfos, new PhoneSpiritIdArgs()
            {
                spiritId = spiritId
            });
            Console.WriteLine($"[Phone] Sent phone infos for spirit {spiritId}: {phoneInfos.ContactList?.Count ?? 0} contacts, {phoneInfos.ContactGroupList?.Count ?? 0} groups");
        }

        internal static void SyncPhoneData(Connection conn, uint spiritId)
        {
            if (conn.PhoneData?.SpiritPhoneInfos?.ContainsKey(spiritId) == true)
            {
                var phoneInfos = conn.PhoneData.SpiritPhoneInfos[spiritId];
                SendPhoneInfos(conn, spiritId, phoneInfos);
            }
            else
            {
                Console.WriteLine($"[Phone] No phone data found for spirit {spiritId}");
            }
        }
    }

    public class SyncShowTaskMessageArgs : SerializedClass
    {
        public uint taskId;
        public string message;
        public float duration;

        public SyncShowTaskMessageArgs()
        {
            onlyFields = true;
        }
    }

    public class AskUseSkillArgs : SerializedClass
    {
        public uint skillId;
        public ulong targetId;
        public AskUseSkillArgs() { onlyFields = true; }
    }

    public class AskSkillExecuteArgs : SerializedClass
    {
        public ulong skillInstanceId;
        public uint skillId;
        public ulong targetId;
        public AskSkillExecuteArgs() { onlyFields = true; }
    }

    public class AskEnemyInteractionArgs : SerializedClass
    {
        public ulong enemyId;
        public uint interactionType;
        public AskEnemyInteractionArgs() { onlyFields = true; }
    }

    public class AskMultipleSkillHit2Args : SerializedClass
    {
        public uint skillId;
        public List<HitTargetInfo> hitTargets;
        public AskMultipleSkillHit2Args() { onlyFields = true; }
    }

    public class HitTargetInfo : SerializedClass
    {
        public ulong targetId;
        public float damageRate;
        public bool isCritical;
        public HitTargetInfo() { onlyFields = true; }
    }

    public class AskDiscardWeaponArgs : SerializedClass
    {
        public ulong instanceId;
        public AskDiscardWeaponArgs() { onlyFields = true; }
    }

    // === Sync notify data classes for combat handlers ===

    public class SyncUseSkillData : SerializedClass
    {
        public uint skillId;
        public ulong releaserId;
        public ulong targetId;
        public UXVector3 position;
        public float facing;
        public SyncUseSkillData() { onlyFields = true; }
    }

    public class SyncUnitHurtEffectData : SerializedClass
    {
        public ulong unitId;
        public uint hurtEffectId;
        public ulong attackerId;
        public UXVector3 hitDirection;
        public SyncUnitHurtEffectData() { onlyFields = true; }
    }

    public class SyncUnitAttackedData : SerializedClass
    {
        public ulong targetId;
        public ulong attackerId;
        public uint skillId;
        public float damage;
        public SyncUnitAttackedData() { onlyFields = true; }
    }

    public class EnemyIdData : SerializedClass
    {
        public ulong enemyId;
        public EnemyIdData() { onlyFields = true; }
    }

    public class ChaosNpcAttackedData : SerializedClass
    {
        public ulong npcId;
        public ulong attackerId;
        public uint skillId;
        public float damage;
        public ChaosNpcAttackedData() { onlyFields = true; }
    }

    public class VehicleHitNotifyData : SerializedClass
    {
        public ulong vehicleId;
        public ulong targetId;
        public float speed;
        public uint hurtEffectId;
        public VehicleHitNotifyData() { onlyFields = true; }
    }

    public class EnemyFallData : SerializedClass
    {
        public ulong enemyId;
        public uint fallType;
        public EnemyFallData() { onlyFields = true; }
    }

    public class SyncBackpackItemChanged : SerializedClass
    {
        public ulong uniqueId;
        public uint itemId;
        public int count;
        public bool isNew;
        public SyncBackpackItemChanged() { onlyFields = true; }
    }

    public class SyncMoneyData : SerializedClass
    {
        public uint money;
        public SyncMoneyData() { onlyFields = true; }
    }

    public class SyncMoneyAddData : SerializedClass
    {
        public uint money;
        public SyncMoneyAddData() { onlyFields = true; }
    }

    public class SyncMoneyRemoveData : SerializedClass
    {
        public uint money;
        public SyncMoneyRemoveData() { onlyFields = true; }
    }

    public class SyncNpcFavorData : SerializedClass
    {
        public uint npcId;
        public uint favorValue;
        public SyncNpcFavorData() { onlyFields = true; }
    }

    public class SyncPlayerNpcProfileTrustValueChangedData : SerializedClass
    {
        public uint profileId;
        public uint trustValue;
        public int reason;
        public SyncPlayerNpcProfileTrustValueChangedData() { onlyFields = true; }
    }

    public class SyncFashionInfoDictData : SerializedClass
    {
        public Dictionary<uint, FashionInfo> fashionInfoDict;
        public SyncFashionInfoDictData() { onlyFields = true; }
    }

    public class SyncPlayerAllFashionsData : SerializedClass
    {
        public PlayerFashionsInfo playerFashionsInfo;
        public SyncPlayerAllFashionsData() { onlyFields = true; }
    }

    public class SyncEnemyAddData : SerializedClass
    {
        public ulong instanceId;
        public uint configId;
        public UXVector3 position;
        public float facing;
        public float hpRate;
        public SyncEnemyAddData() { onlyFields = true; }
    }

    public class SyncSceneFogMapAllData : SerializedClass
    {
        public Dictionary<uint, bool> fogMapUnlocked;
        public SyncSceneFogMapAllData() { onlyFields = true; }
    }

    public class SyncReputationData : SerializedClass
    {
        public uint factionId;
        public uint disposition;
        public uint dispositionLevel;
        public uint influence;
        public SyncReputationData() { onlyFields = true; }
    }

    public class SyncSkillCooldownData : SerializedClass
    {
        public List<ulong> skillInstanceIds;
        public SyncSkillCooldownData() { onlyFields = true; }
    }

    public class SyncEnemyDieData : SerializedClass
    {
        public ulong enemyId;
        public SyncEnemyDieData() { onlyFields = true; }
    }

    public class SyncPlayerSwitchSpiritInSitu : SerializedClass
    {
        public ulong pid;
        public uint spiritId;
        public ulong newSpiritInstanceId;
        public SyncPlayerSwitchSpiritInSitu() { onlyFields = true; }
    }

    public class SyncUnitPositionAndFacing : SerializedClass
    {
        public ulong unitId;
        public UXVector3 pos;
        public float facing;
        public int moveId;
        public bool continueMove;
        public SetPositionType type;
        public UnitInfoOnMoveGround moveGroundInfo;
        public LoadingTypeInfo loadingTypeInfo;
        public SyncUnitPositionAndFacing() { onlyFields = true; }
    }

    // --- Tier 2 Handler Args ---

    public class AskRepairWeaponDurabilityArgs : SerializedClass
    {
        public ulong weaponInstanceId;
        public AskRepairWeaponDurabilityArgs() { onlyFields = true; }
    }

    public class AskGameplayTagArgs : SerializedClass
    {
        public ulong agentEntityId;
        public uint tagId;
        public AskGameplayTagArgs() { onlyFields = true; }
    }

    public class AskPickDelayDropArgs : SerializedClass
    {
        public uint delayDropId;
        public AskPickDelayDropArgs() { onlyFields = true; }
    }

    // --- Tier 3 Handler Args ---

    public class AskBuyCinemaTicketArgs : SerializedClass
    {
        public uint cinemaId;
        public uint movieId;
        public uint cinemaNpcId;
        public uint companionNpcId;
        public AskBuyCinemaTicketArgs() { onlyFields = true; }
    }

    public class AskBuyFerrisWheelTicketArgs : SerializedClass
    {
        public uint ticketType;
        public uint ferrisWheelId;
        public AskBuyFerrisWheelTicketArgs() { onlyFields = true; }
    }

    public class AskBuyVehicleFromMassArgs : SerializedClass
    {
        public uint vehicleId;
        public bool sendChat;
        public AskBuyVehicleFromMassArgs() { onlyFields = true; }
    }

    public class AskModifySpiritCustomSuitSchemeNArgs : SerializedClass
    {
        public uint spiritId;
        public int schemeIndex;
        public string schemeName;
        public AskModifySpiritCustomSuitSchemeNArgs() { onlyFields = true; }
    }

    public class AskGetNpcRandomWearFashionsArgs : SerializedClass
    {
        public uint spiritId;
        public AskGetNpcRandomWearFashionsArgs() { onlyFields = true; }
    }
}
