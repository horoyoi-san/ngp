using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;
using static AnantaTestGameServer.Methods.Return.SpiritInfo;

namespace AnantaTestGameServer.Packets.Req
{
    internal class GmToolHandlers
    {
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

        private static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
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

        public static void GmTeleportXYZ(Connection conn, float x, float y, float z)
        {
            Console.WriteLine($"[GM Teleport] Teleporting to X={x} Y={y} Z={z}");
            conn.LastKnownPlayerPosition = new UXVector3() { X = x, Y = y, Z = z };
            conn.HasLastKnownPlayerPosition = true;
        }

        [Handler(MethodId.GmTeleportXYZ)]
        public static void GmTeleportXYZHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmTeleportXYZArgs>();
            GmTeleportXYZ(conn, args.x, args.y, args.z);
            SendEmptySuccessReturn(conn, msg, MethodId.GmTeleportXYZ);
        }

        public class GmTeleportXYZArgs : SerializedClass
        {
            public float x;
            public float y;
            public float z;
            public GmTeleportXYZArgs() { onlyFields = true; }
        }

        [Handler(MethodId.Teleport)]
        public static void TeleportHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<TeleportArgs>();
            GmTeleportXYZ(conn, args.x, args.y, args.z);
            SendEmptySuccessReturn(conn, msg, MethodId.Teleport);
        }

        public class TeleportArgs : SerializedClass
        {
            public float x;
            public float y;
            public float z;
            public TeleportArgs() { onlyFields = true; }
        }

        public static void GmRevive(Connection conn)
        {
            Console.WriteLine($"[GM Revive] Reviving player");
            var spirit = conn.GetCurrentSpirit();
            if (spirit != null)
            {
                SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                {
                    unitId = spirit.Id,
                    hp = 1.0f
                });
            }
        }

        [Handler(MethodId.GmRevive)]
        public static void GmReviveHandler(Connection conn, UxRpcMessage msg)
        {
            GmRevive(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmRevive);
        }

        public static void GmSetHp(Connection conn, float hpRate)
        {
            Console.WriteLine($"[GM SetHp] Setting HP to {hpRate}");
            var spirit = conn.GetCurrentSpirit();
            if (spirit != null)
            {
                SpiritInfo updated = conn.Spirits.Find(s => s.TemplateId == conn.currentSpirit);
                if (updated != null)
                {
                    updated.HpRate = hpRate;
                }

                SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                {
                    unitId = spirit.Id,
                    hp = hpRate
                });
            }
        }

        [Handler(MethodId.GmSetHp)]
        public static void GmSetHpHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSetHpArgs>();
            GmSetHp(conn, args.hpRate);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetHp);
        }

        public class GmSetHpArgs : SerializedClass
        {
            public float hpRate;
            public GmSetHpArgs() { onlyFields = true; }
        }

        public static void GmAddBuff(Connection conn, uint buffId)
        {
            Console.WriteLine($"[GM AddBuff] Adding buff {buffId}");
            var spirit = conn.GetCurrentSpirit();
            if (spirit != null)
            {
                SendNotify(conn, MethodId.SyncUnitBuffList, new SyncUnitBuffList()
                {
                    entityId = spirit.Id,
                    buffList = new()
                    {
                        new BuffViewData()
                        {
                            InstanceId = (uint)new Random().Next(1000000, 9999999),
                            Id = buffId,
                            Permanent = true,
                            Tier = 1
                        }
                    }
                });
            }
        }

        [Handler(MethodId.GmAddBuff)]
        public static void GmAddBuffHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddBuffArgs>();
            GmAddBuff(conn, args.buffId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddBuff);
        }

        public class GmAddBuffArgs : SerializedClass
        {
            public uint buffId;
            public GmAddBuffArgs() { onlyFields = true; }
        }

        public static void GmRemoveBuff(Connection conn, uint buffId)
        {
            Console.WriteLine($"[GM RemoveBuff] Removing buff {buffId}");
            var spirit = conn.GetCurrentSpirit();
            if (spirit != null)
            {
                SendNotify(conn, MethodId.SyncUnitRemoveBuff, new ClientToGameserver.AskRemoveClientBuff()
                {
                    unitId = spirit.Id,
                    buffId = buffId
                });
            }
        }

        [Handler(MethodId.GmRemoveBuff)]
        public static void GmRemoveBuffHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmRemoveBuffArgs>();
            GmRemoveBuff(conn, args.buffId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveBuff);
        }

        public class GmRemoveBuffArgs : SerializedClass
        {
            public uint buffId;
            public GmRemoveBuffArgs() { onlyFields = true; }
        }

        public static void GmAddAllSpirits(Connection conn)
        {
            Console.WriteLine($"[GM] Adding all spirits");
            conn.Spirits = Connection.GetDefaultSpirits();
            SendNotify(conn, MethodId.SyncPlayerAllSpirits, new SyncPlayerAllSpirits()
            {
                list = conn.Spirits
            });
        }

        [Handler(MethodId.GmAddAllSpirits)]
        public static void GmAddAllSpiritsHandler(Connection conn, UxRpcMessage msg)
        {
            GmAddAllSpirits(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAllSpirits);
        }

        public static void GmAddAllVehicles(Connection conn)
        {
            ClientToGameserver.GmAddAllVehicles(conn);
        }

        [Handler(MethodId.GmAddAllVehicles)]
        public static void GmAddAllVehiclesHandler(Connection conn, UxRpcMessage msg)
        {
            GmAddAllVehicles(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAllVehicles);
        }

        public static void GmSetJobLevel(Connection conn, uint jobId, uint level)
        {
            Console.WriteLine($"[GM Job] Setting job {jobId} to level {level}");
            var spirit = conn.Spirits.Find(s => s.TemplateId == conn.currentSpirit);
            if (spirit != null && spirit.SpiritJobInfo != null)
            {
                spirit.SpiritJobInfo.CurrentJob = jobId;
            }
            SendNotify(conn, MethodId.SyncUnitAttrs, new SyncUnitAttrs()
            {
                entityId = conn.GetCurrentSpirit()?.Id ?? 100000000000UL,
                values = new()
                {
                    { 1, level }
                }
            });
        }

        [Handler(MethodId.GmSetJobLevel)]
        public static void GmSetJobLevelHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSetJobLevelArgs>();
            GmSetJobLevel(conn, args.jobId, args.level);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetJobLevel);
        }

        public class GmSetJobLevelArgs : SerializedClass
        {
            public uint jobId;
            public uint level;
            public GmSetJobLevelArgs() { onlyFields = true; }
        }

        public static void GmJobAddExp(Connection conn, uint jobId, uint exp)
        {
            Console.WriteLine($"[GM Job] Adding {exp} exp to job {jobId}");
            var spirit = conn.Spirits.Find(s => s.TemplateId == conn.currentSpirit);
            if (spirit != null && spirit.SpiritJobInfo != null)
            {
                spirit.SpiritJobInfo.CurrentJob = jobId;
            }
            var spiritEntity = conn.GetCurrentSpirit();
            if (spiritEntity != null)
            {
                SendNotify(conn, MethodId.SyncUnitAttrs, new SyncUnitAttrs()
                {
                    entityId = spiritEntity.Id,
                    values = new() { { 14, exp } }
                });
            }
        }

        [Handler(MethodId.GmJobAddExp)]
        public static void GmJobAddExpHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmJobAddExpArgs>();
            GmJobAddExp(conn, args.jobId, args.exp);
            SendEmptySuccessReturn(conn, msg, MethodId.GmJobAddExp);
        }

        public class GmJobAddExpArgs : SerializedClass
        {
            public uint jobId;
            public uint exp;
            public GmJobAddExpArgs() { onlyFields = true; }
        }

        public static void GmAbilityAddExp(Connection conn, uint abilityId, uint exp)
        {
            Console.WriteLine($"[GM Ability] Adding {exp} exp to ability {abilityId}");
            var spiritEntity = conn.GetCurrentSpirit();
            if (spiritEntity != null)
            {
                SendNotify(conn, MethodId.SyncUnitAttrs, new SyncUnitAttrs()
                {
                    entityId = spiritEntity.Id,
                    values = new() { { 15, exp } }
                });
            }
        }

        [Handler(MethodId.GmAbilityAddExp)]
        public static void GmAbilityAddExpHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAbilityAddExpArgs>();
            GmAbilityAddExp(conn, args.abilityId, args.exp);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAbilityAddExp);
        }

        public class GmAbilityAddExpArgs : SerializedClass
        {
            public uint abilityId;
            public uint exp;
            public GmAbilityAddExpArgs() { onlyFields = true; }
        }

        public static void AddItem(Connection conn, uint itemId, uint count)
        {
            Console.WriteLine($"[GM Item] Adding item {itemId} x{count}");
            var existing = conn.PlayerItems.PackItems?.FirstOrDefault(p => p.TemplateId == itemId);
            if (existing != null)
            {
                existing.Count += count;
                existing.IsNew = true;
                SendNotify(conn, MethodId.SyncBackpackItemChanged, new SyncBackpackItemChanged()
                {
                    uniqueId = existing.UniqueId,
                    itemId = itemId,
                    count = (int)existing.Count,
                    isNew = true
                });
            }
            else
            {
                ulong uniqueId = (ulong)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() * 1000 + new Random().Next(1000, 9999));
                conn.PlayerItems.PackItems.Add(new PlayerPackItem()
                {
                    UniqueId = uniqueId,
                    TemplateId = itemId,
                    Count = count,
                    IsNew = true,
                    ExpiryTime = 0,
                    CDFinishTime = 0
                });
                SendNotify(conn, MethodId.SyncBackpackItemChanged, new SyncBackpackItemChanged()
                {
                    uniqueId = uniqueId,
                    itemId = itemId,
                    count = (int)count,
                    isNew = true
                });
            }
            Console.WriteLine($"[GM Item] Item {itemId} x{count} added. Total: {conn.PlayerItems.PackItems.Count} item types");
        }

        [Handler(MethodId.AddItem)]
        public static void AddItemHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AddItemArgs>();
            AddItem(conn, args.itemId, args.count);
            SendEmptySuccessReturn(conn, msg, MethodId.AddItem);
        }

        public class AddItemArgs : SerializedClass
        {
            public uint itemId;
            public uint count;
            public AddItemArgs() { onlyFields = true; }
        }

        public static void AddMoney(Connection conn, uint amount)
        {
            Console.WriteLine($"[GM Money] Adding {amount} money");
            conn.PlayerItems.Money += amount;
            SendNotify(conn, MethodId.SyncMoneyAdd, new SyncMoneyAddData()
            {
                money = amount
            });
            SendNotify(conn, MethodId.SyncMoney, new SyncMoneyData()
            {
                money = conn.PlayerItems.Money
            });
            Console.WriteLine($"[GM Money] Total money: {conn.PlayerItems.Money}");
        }

        [Handler(MethodId.AddMoney)]
        public static void AddMoneyHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AddMoneyArgs>();
            AddMoney(conn, args.amount);
            SendEmptySuccessReturn(conn, msg, MethodId.AddMoney);
        }

        public class AddMoneyArgs : SerializedClass
        {
            public uint amount;
            public AddMoneyArgs() { onlyFields = true; }
        }

        public static void GmBuyFoods(Connection conn, uint foodId, uint count)
        {
            Console.WriteLine($"[GM BuyFoods] Buying food {foodId} x{count}");
            AddItem(conn, foodId, count);
        }

        [Handler(MethodId.GmBuyFoods)]
        public static void GmBuyFoodsHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmBuyFoodsArgs>();
            GmBuyFoods(conn, args.foodId, args.count);
            SendEmptySuccessReturn(conn, msg, MethodId.GmBuyFoods);
        }

        public class GmBuyFoodsArgs : SerializedClass
        {
            public uint foodId;
            public uint count;
            public GmBuyFoodsArgs() { onlyFields = true; }
        }

        public static void GmBuyCinemaTicket(Connection conn, uint ticketId)
        {
            Console.WriteLine($"[GM BuyCinemaTicket] Buying cinema ticket {ticketId}");
            AddItem(conn, ticketId, 1);
        }

        [Handler(MethodId.GmBuyCinemaTicket)]
        public static void GmBuyCinemaTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmBuyCinemaTicketArgs>();
            GmBuyCinemaTicket(conn, args.ticketId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmBuyCinemaTicket);
        }

        public class GmBuyCinemaTicketArgs : SerializedClass
        {
            public uint ticketId;
            public GmBuyCinemaTicketArgs() { onlyFields = true; }
        }

        public static void GmChangeNpcFavor(Connection conn, uint npcId, uint favorValue)
        {
            Console.WriteLine($"[GM ChangeNpcFavor] Setting NPC {npcId} favor to {favorValue}");
            conn.NpcFavors[npcId] = favorValue;
            SendNotify(conn, MethodId.SyncNpcFavor, new SyncNpcFavorData()
            {
                npcId = npcId,
                favorValue = favorValue
            });
        }

        [Handler(MethodId.GMChangeNpcFavor)]
        public static void GmChangeNpcFavorHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmChangeNpcFavorArgs>();
            GmChangeNpcFavor(conn, args.npcId, args.favorValue);
            SendEmptySuccessReturn(conn, msg, MethodId.GMChangeNpcFavor);
        }

        public class GmChangeNpcFavorArgs : SerializedClass
        {
            public uint npcId;
            public uint favorValue;
            public GmChangeNpcFavorArgs() { onlyFields = true; }
        }

        public static void GMChangeNpcProfileTrustValue(Connection conn, uint profileId, uint trustValue, int reason)
        {
            Console.WriteLine($"[GM ChangeNpcProfileTrustValue] Setting profile {profileId} trust to {trustValue} (reason: {reason})");
            if (!conn.NpcProfiles.ContainsKey(profileId))
            {
                conn.NpcProfiles[profileId] = new TrustNpcInfo()
                {
                    ProfileId = profileId,
                    TrustValue = trustValue,
                    ActivateTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                    GotRewardList = new(),
                    FinishTargetList = new(),
                    IsNew = false,
                    IsMaxTrustReward = false,
                    TargetStateList = new()
                };
            }
            else
            {
                conn.NpcProfiles[profileId].TrustValue = trustValue;
            }
            SendNotify(conn, MethodId.SyncPlayerNpcProfileTrustValueCh, new SyncPlayerNpcProfileTrustValueChangedData()
            {
                profileId = profileId,
                trustValue = trustValue,
                reason = reason
            });
        }

        [Handler(MethodId.GMChangeNpcProfileTrustValue)]
        public static void GMChangeNpcProfileTrustValueHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmChangeNpcProfileTrustValueArgs>();
            GMChangeNpcProfileTrustValue(conn, args.profileId, args.trustValue, args.reason);
            SendEmptySuccessReturn(conn, msg, MethodId.GMChangeNpcProfileTrustValue);
        }

        public class GmChangeNpcProfileTrustValueArgs : SerializedClass
        {
            public uint profileId;
            public uint trustValue;
            public int reason;
            public GmChangeNpcProfileTrustValueArgs() { onlyFields = true; }
        }

        public static void GMChangeNpcSendGiftCount(Connection conn, uint npcId, uint giftCount)
        {
            Console.WriteLine($"[GM ChangeNpcSendGiftCount] Setting NPC {npcId} gift count to {giftCount}");
            if (!conn.NpcProfiles.ContainsKey(npcId))
            {
                conn.NpcProfiles[npcId] = new TrustNpcInfo()
                {
                    ProfileId = npcId,
                    TrustValue = 0,
                    ActivateTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                    GotRewardList = new(),
                    FinishTargetList = new(),
                    IsNew = false,
                    IsMaxTrustReward = false,
                    TargetStateList = new()
                };
            }
            conn.NpcProfiles[npcId].TrustValue = giftCount;
            SendNotify(conn, MethodId.SyncPlayerNpcProfileTrustValueCh, new SyncPlayerNpcProfileTrustValueChangedData()
            {
                profileId = npcId,
                trustValue = giftCount,
                reason = 0
            });
        }

        [Handler(MethodId.GMChangeNpcSendGiftCount)]
        public static void GMChangeNpcSendGiftCountHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmChangeNpcSendGiftCountArgs>();
            GMChangeNpcSendGiftCount(conn, args.npcId, args.giftCount);
            SendEmptySuccessReturn(conn, msg, MethodId.GMChangeNpcSendGiftCount);
        }

        public class GmChangeNpcSendGiftCountArgs : SerializedClass
        {
            public uint npcId;
            public uint giftCount;
            public GmChangeNpcSendGiftCountArgs() { onlyFields = true; }
        }

        public static void ClearBag(Connection conn)
        {
            conn.Weapons.Clear();
            conn.WeaponIndex = 0;
            Console.WriteLine($"[GM] Cleared all weapons from inventory");
        }

        [Handler(MethodId.ClearBag)]
        public static void ClearBagHandler(Connection conn, UxRpcMessage msg)
        {
            ClearBag(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.ClearBag);
        }

        public static void RemoveItem(Connection conn, uint itemId, uint count)
        {
            Console.WriteLine($"[GM Item] Removing item {itemId} x{count}");
            var existing = conn.PlayerItems.PackItems?.FirstOrDefault(p => p.TemplateId == itemId);
            if (existing != null)
            {
                if (existing.Count <= count)
                {
                    conn.PlayerItems.PackItems.Remove(existing);
                    SendNotify(conn, MethodId.SyncBackpackItemChanged, new SyncBackpackItemChanged()
                    {
                        uniqueId = existing.UniqueId,
                        itemId = itemId,
                        count = 0,
                        isNew = false
                    });
                }
                else
                {
                    existing.Count -= count;
                    SendNotify(conn, MethodId.SyncBackpackItemChanged, new SyncBackpackItemChanged()
                    {
                        uniqueId = existing.UniqueId,
                        itemId = itemId,
                        count = (int)existing.Count,
                        isNew = false
                    });
                }
            }
            else
            {
                Console.WriteLine($"[GM Item] Item {itemId} not found in inventory");
            }
        }

        [Handler(MethodId.RemoveItem)]
        public static void RemoveItemHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<RemoveItemArgs>();
            RemoveItem(conn, args.itemId, args.count);
            SendEmptySuccessReturn(conn, msg, MethodId.RemoveItem);
        }

        public class RemoveItemArgs : SerializedClass
        {
            public uint itemId;
            public uint count;
            public RemoveItemArgs() { onlyFields = true; }
        }

        public static void GmAddWeapon(Connection conn, uint weaponTemplateId)
        {
            ulong nextInstanceId = 6000000000001;
            if (conn.Weapons.Count > 0)
                nextInstanceId = conn.Weapons.Max(w => w.InstanceId) + 1;
            conn.Weapons.Add(new WeaponDetail()
            {
                TemplateId = weaponTemplateId,
                InstanceId = nextInstanceId,
                SpecialLabel = "",
                WeaponFlags = new WeaponDataFlags()
                {
                    IsTaskWheelWeapon = false,
                    ShowRedDot = false,
                    AdditionalEffectIds = new List<int>()
                },
                Durability = 10000
            });
            conn.SyncWeapons();
            Console.WriteLine($"[GM Weapon] Added weapon template {weaponTemplateId} (InstanceId={nextInstanceId})");
        }

        [Handler(MethodId.GmAddWeapon)]
        public static void GmAddWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddWeaponArgs>();
            GmAddWeapon(conn, args.weaponTemplateId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddWeapon);
        }

        public class GmAddWeaponArgs : SerializedClass
        {
            public uint weaponTemplateId;
            public GmAddWeaponArgs() { onlyFields = true; }
        }

        public static void GmAddFashions(Connection conn, uint fashionId)
        {
            Console.WriteLine($"[GM Fashion] Adding fashion {fashionId}");
            if (!conn.FashionInventory.ContainsKey(fashionId))
            {
                conn.FashionInventory[fashionId] = new FashionInfo()
                {
                    FashionId = fashionId,
                    ExpiredTime = 0,
                    GainTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                    Status = 0,
                    ApplyColoringSchemeId = 0,
                    ColoringSchemeInfoDict = new()
                };
            }
            SendNotify(conn, MethodId.SyncFashionInfoDict, new SyncFashionInfoDictData()
            {
                fashionInfoDict = conn.FashionInventory
            });
            Console.WriteLine($"[GM Fashion] Fashion {fashionId} added. Total: {conn.FashionInventory.Count}");
        }

        [Handler(MethodId.GmAddFashions)]
        public static void GmAddFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddFashionsArgs>();
            GmAddFashions(conn, args.fashionId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFashions);
        }

        public class GmAddFashionsArgs : SerializedClass
        {
            public uint fashionId;
            public GmAddFashionsArgs() { onlyFields = true; }
        }

        public static void GmAddAllFashions(Connection conn)
        {
            Console.WriteLine($"[GM Fashion] Adding all fashions");
            uint[] allFashionIds = {
                11001001, 11001002, 11001003, 11001004, 11001005,
                11002001, 11002002, 11002003, 11002004, 11002005,
                11003001, 11003002, 11003003, 11003004, 11003005,
                11004001, 11004002, 11004003, 11004004, 11004005,
                11005001, 11005002, 11005003, 11005004, 11005005,
                12001001, 12001002, 12001003, 12001004, 12001005,
                12002001, 12002002, 12002003, 12002004, 12002005,
                12003001, 12003002, 12003003, 12003004, 12003005
            };
            foreach (uint fashionId in allFashionIds)
            {
                if (!conn.FashionInventory.ContainsKey(fashionId))
                {
                    conn.FashionInventory[fashionId] = new FashionInfo()
                    {
                        FashionId = fashionId,
                        ExpiredTime = 0,
                        GainTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                        Status = 0,
                        ApplyColoringSchemeId = 0,
                        ColoringSchemeInfoDict = new()
                    };
                }
            }
            SendNotify(conn, MethodId.SyncFashionInfoDict, new SyncFashionInfoDictData()
            {
                fashionInfoDict = conn.FashionInventory
            });
            Console.WriteLine($"[GM Fashion] All fashions added. Total: {conn.FashionInventory.Count}");
        }

        [Handler(MethodId.GmAddAllFashions)]
        public static void GmAddAllFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            GmAddAllFashions(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAllFashions);
        }

        public static void GmAddFashionSuits(Connection conn, uint suitId)
        {
            Console.WriteLine($"[GM FashionSuit] Adding suit {suitId}");
            if (!conn.FashionSuitInventory.Contains(suitId))
                conn.FashionSuitInventory.Add(suitId);
        }

        public static void GmAddAllFashionSuits(Connection conn)
        {
            Console.WriteLine($"[GM FashionSuit] Adding all fashion suits");
            var allIds = ConfigManager.IsLoaded
                ? ConfigManager.GetAllFashionSuitIds()
                : new List<uint> { 11190001, 11190002, 11190003, 11190004, 11190005, 11190006 };
            foreach (uint suitId in allIds)
            {
                if (!conn.FashionSuitInventory.Contains(suitId))
                    conn.FashionSuitInventory.Add(suitId);
            }
            Console.WriteLine($"[GM FashionSuit] All suits added. Total: {conn.FashionSuitInventory.Count}");
        }

        public static void GmAddAgent(Connection conn, uint agentId)
        {
            Console.WriteLine($"[GM Agent] Adding agent {agentId}");
            if (!conn.GangMembers.ContainsKey(agentId))
            {
                conn.GangMembers[agentId] = new GangMemberInfo()
                {
                    TemplateId = agentId,
                    InstanceId = 0,
                    NextReviveTimeStamp = -1,
                    IsUnlock = true,
                    HpPercent = 1.0f
                };
            }
            Console.WriteLine($"[GM Agent] Agent {agentId} added. Total: {conn.GangMembers.Count}");
        }

        [Handler(MethodId.GmAddAgent)]
        public static void GmAddAgentHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddAgentArgs>();
            GmAddAgent(conn, args.agentId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAgent);
        }

        public class GmAddAgentArgs : SerializedClass
        {
            public uint agentId;
            public GmAddAgentArgs() { onlyFields = true; }
        }

        public static void GmAddAllAgents(Connection conn)
        {
            Console.WriteLine($"[GM Agent] Adding all agents");
            var allIds = ConfigManager.IsLoaded
                ? ConfigManager.GetAllAgentIds()
                : new List<uint> { 1001001, 1001002, 1001003, 1001004, 1001005, 1001006, 1001007, 1001008 };
            foreach (uint agentId in allIds)
            {
                if (!conn.GangMembers.ContainsKey(agentId))
                {
                    conn.GangMembers[agentId] = new GangMemberInfo()
                    {
                        TemplateId = agentId,
                        InstanceId = 0,
                        NextReviveTimeStamp = -1,
                        IsUnlock = true,
                        HpPercent = 1.0f
                    };
                }
            }
            Console.WriteLine($"[GM Agent] All agents added. Total: {conn.GangMembers.Count}");
        }

        public static void GmUnlockAllQuest(Connection conn)
        {
            Console.WriteLine($"[GM Quest] Unlocking all quests");
            
            // Add some sample quests to unlocked list
            conn.UnlockedQuests.Add(1);
            conn.UnlockedQuests.Add(2);
            conn.UnlockedQuests.Add(3);
            
            // Unlock some investigator galleries
            conn.UnlockedInvestigatorGalleries.Add(100);
            conn.UnlockedInvestigatorGalleries.Add(101);
            
            SendNotify(conn, MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                taskInfos = new(),
                submitTaskList = new(),
                submitEventList = new(),
                currentTask = 0,
                eventPanelInfo = new EventPanelInfo(),
                eventViewInfoList = new(),
                loginGameServer = true
            });
            
            Console.WriteLine($"[GM Quest] Unlocked {conn.UnlockedQuests.Count} quests and {conn.UnlockedInvestigatorGalleries.Count} galleries");
        }

        [Handler(MethodId.GmUnlockAllQuest)]
        public static void GmUnlockAllQuestHandler(Connection conn, UxRpcMessage msg)
        {
            GmUnlockAllQuest(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockAllQuest);
        }

        public static void ForceAcceptTask(Connection conn, uint taskId)
        {
            Console.WriteLine($"[GM Quest] Force accepting task {taskId}");
            conn.AcceptedTasks.Add(taskId);
            conn.CurrentTaskId = taskId;
            var taskInfos = new List<TaskViewData>();
            foreach (uint acceptedTaskId in conn.AcceptedTasks)
            {
                taskInfos.Add(new TaskViewData()
                {
                    TaskId = acceptedTaskId,
                    CounterValues = new(),
                    Counters = new(),
                    State = TaskState.Accepted,
                    RecoverResource = false,
                    SpoonViewInfo = null
                });
            }
            SendNotify(conn, MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                taskInfos = taskInfos,
                submitTaskList = new(),
                submitEventList = new(),
                currentTask = taskId,
                eventPanelInfo = new EventPanelInfo(),
                eventViewInfoList = new(),
                loginGameServer = false
            });
        }

        [Handler(MethodId.ForceAcceptTask)]
        public static void ForceAcceptTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<ForceAcceptTaskArgs>();
            ForceAcceptTask(conn, args.taskId);
            SendEmptySuccessReturn(conn, msg, MethodId.ForceAcceptTask);
        }

        public class ForceAcceptTaskArgs : SerializedClass
        {
            public uint taskId;
            public ForceAcceptTaskArgs() { onlyFields = true; }
        }

        public static void ForceSubmitTask(Connection conn, uint taskId)
        {
            Console.WriteLine($"[GM Quest] Force submitting task {taskId}");
            conn.AcceptedTasks.Remove(taskId);
            conn.SubmittedTasks.Add(taskId);
            if (conn.CurrentTaskId == taskId)
                conn.CurrentTaskId = null;
            var taskInfos = new List<TaskViewData>();
            foreach (uint acceptedTaskId in conn.AcceptedTasks)
            {
                taskInfos.Add(new TaskViewData()
                {
                    TaskId = acceptedTaskId,
                    CounterValues = new(),
                    Counters = new(),
                    State = TaskState.Accepted,
                    RecoverResource = false,
                    SpoonViewInfo = null
                });
            }
            SendNotify(conn, MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                taskInfos = taskInfos,
                submitTaskList = conn.SubmittedTasks.ToList(),
                submitEventList = new(),
                currentTask = conn.CurrentTaskId ?? 0,
                eventPanelInfo = new EventPanelInfo(),
                eventViewInfoList = new(),
                loginGameServer = false
            });
        }

        [Handler(MethodId.ForceSubmitTask)]
        public static void ForceSubmitTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<ForceSubmitTaskArgs>();
            ForceSubmitTask(conn, args.taskId);
            SendEmptySuccessReturn(conn, msg, MethodId.ForceSubmitTask);
        }

        public class ForceSubmitTaskArgs : SerializedClass
        {
            public uint taskId;
            public ForceSubmitTaskArgs() { onlyFields = true; }
        }

        public static void ForceFailTask(Connection conn, uint taskId)
        {
            Console.WriteLine($"[GM Quest] Force failing task {taskId}");
            conn.AcceptedTasks.Remove(taskId);
            conn.SubmittedTasks.Remove(taskId);
            if (conn.CurrentTaskId == taskId)
                conn.CurrentTaskId = null;
            var taskInfos = new List<TaskViewData>();
            foreach (uint acceptedTaskId in conn.AcceptedTasks)
            {
                taskInfos.Add(new TaskViewData()
                {
                    TaskId = acceptedTaskId,
                    CounterValues = new(),
                    Counters = new(),
                    State = TaskState.Accepted,
                    RecoverResource = false,
                    SpoonViewInfo = null
                });
            }
            SendNotify(conn, MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                taskInfos = taskInfos,
                submitTaskList = conn.SubmittedTasks.ToList(),
                submitEventList = new(),
                currentTask = conn.CurrentTaskId ?? 0,
                eventPanelInfo = new EventPanelInfo(),
                eventViewInfoList = new(),
                loginGameServer = false
            });
        }

        [Handler(MethodId.ForceFailTask)]
        public static void ForceFailTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<ForceFailTaskArgs>();
            ForceFailTask(conn, args.taskId);
            SendEmptySuccessReturn(conn, msg, MethodId.ForceFailTask);
        }

        public class ForceFailTaskArgs : SerializedClass
        {
            public uint taskId;
            public ForceFailTaskArgs() { onlyFields = true; }
        }

        public static void GmAddEnemy(Connection conn, uint enemyId, float x, float y, float z)
        {
            Console.WriteLine($"[GM Enemy] Adding enemy {enemyId} at ({x}, {y}, {z})");
            ulong instanceId = (ulong)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() * 1000 + new Random().Next(1000, 9999));
            conn.EnemyHpMap[instanceId] = 1.0f;
            conn.EnemyOwnerMap[instanceId] = conn.Pid;

            // Use proper combat enemy spawn - mark as combat enemy with proper AI
            SendNotify(conn, MethodId.SyncAetherAIStaticNpcAddData, new ClientStaticNpcInitData()
            {
                Id = instanceId,
                NpcFormworkId = enemyId,
                Position = new UXVector3() { X = x, Y = y, Z = z },
                Facing = 0,
                StaticNpcInfoId = 0,
                AgentPersonaId = 45200058, // Combat AI persona
                NpcPid = 0,
                UrbanDiversityId = 88888000,
                PoiActionId = 0,
                SourceType = ClientStaticNpcInitData.StaticNpcSourceType.Spoon,
                AgentSyncClientInfo = new()
                {
                    stimIDList = new int[0],
                    CanBeExaminedByPolice = true,
                    indoorList = new(),
                    roomIds = new int[0],
                    SpoonAgentId = 0,
                    treeName = "CombatTree",
                    petPerformData = "",
                    spawnEffectId = new uint[0],
                    randomModelCfgId = enemyId,
                    LeaveDistance = 10000,
                    approachDistance = 10000,
                    FashionSuitId = 0,
                }
            });

            // Sync initial HP to client
            SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
            {
                unitId = instanceId,
                hp = 1.0f
            });

            Console.WriteLine($"[GM Enemy] Enemy {enemyId} spawned with instanceId={instanceId} using combat AI");
        }

        [Handler(MethodId.GmAddEnemy)]
        public static void GmAddEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddEnemyArgs>();
            GmAddEnemy(conn, args.enemyId, args.x, args.y, args.z);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddEnemy);
        }

        public class GmAddEnemyArgs : SerializedClass
        {
            public uint enemyId;
            public float x;
            public float y;
            public float z;
            public GmAddEnemyArgs() { onlyFields = true; }
        }

        public static void GmKillEnemy(Connection conn, ulong enemyEntityId)
        {
            Console.WriteLine($"[GM Enemy] Killing enemy {enemyEntityId}");
            if (conn.EnemyHpMap.ContainsKey(enemyEntityId))
            {
                conn.EnemyHpMap[enemyEntityId] = 0;
                conn.DeadEnemies.Add(enemyEntityId);
                SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                {
                    unitId = enemyEntityId,
                    hp = 0
                });
                SendNotify(conn, MethodId.SyncEnemyEndItemDrop, new EnemyFallData()
                {
                    enemyId = enemyEntityId,
                    fallType = 1
                });
                Console.WriteLine($"[GM Enemy] Enemy {enemyEntityId} killed");
            }
            else
            {
                Console.WriteLine($"[GM Enemy] Enemy {enemyEntityId} not found");
            }
        }

        [Handler(MethodId.GmKillEnemy)]
        public static void GmKillEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmKillEnemyArgs>();
            GmKillEnemy(conn, args.enemyEntityId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmKillEnemy);
        }

        public class GmKillEnemyArgs : SerializedClass
        {
            public ulong enemyEntityId;
            public GmKillEnemyArgs() { onlyFields = true; }
        }

        public static void GmAddNpc(Connection conn, uint npcFormworkId, float x, float y, float z)
        {
            Console.WriteLine($"[GM NPC] Adding NPC {npcFormworkId} at ({x}, {y}, {z})");
            ulong instanceId = (ulong)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() * 1000 + new Random().Next(1000, 9999));
            conn.LastSpawnedNpcIds.Add(instanceId);

            SendNotify(conn, MethodId.SyncAetherAIStaticNpcAddData, new ClientStaticNpcInitData()
            {
                Id = instanceId,
                NpcFormworkId = npcFormworkId,
                Position = new UXVector3() { X = x, Y = y, Z = z },
                Facing = 0,
                StaticNpcInfoId = 41739060,
                AgentPersonaId = 45200058,
                NpcPid = 41739060,
                UrbanDiversityId = 88888000,
                PoiActionId = 0,
                SourceType = ClientStaticNpcInitData.StaticNpcSourceType.Spoon,
                AgentSyncClientInfo = new()
                {
                    stimIDList = new int[0],
                    CanBeExaminedByPolice = true,
                    indoorList = new(),
                    roomIds = new int[0],
                    SpoonAgentId = 41739060,
                    treeName = "",
                    petPerformData = "",
                    spawnEffectId = new uint[0],
                    randomModelCfgId = 0,
                    LeaveDistance = 10000,
                    approachDistance = 10000,
                    FashionSuitId = 11190001,
                }
            });
            Console.WriteLine($"[GM NPC] NPC {npcFormworkId} spawned with instanceId={instanceId}");
        }

        [Handler(MethodId.GmAddNpc)]
        public static void GmAddNpcHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddNpcArgs>();
            GmAddNpc(conn, args.npcFormworkId, args.x, args.y, args.z);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddNpc);
        }

        public class GmAddNpcArgs : SerializedClass
        {
            public uint npcFormworkId;
            public float x;
            public float y;
            public float z;
            public GmAddNpcArgs() { onlyFields = true; }
        }

        public static void GmSpawnVehicle(Connection conn, uint vehicleConfigId, float x, float y, float z)
        {
            UXVector3 pos = new UXVector3() { X = x, Y = y, Z = z };
            
            // If Y is 0, use player's last known Y position to avoid spawning underground
            if (y == 0 && conn.HasLastKnownPlayerPosition)
            {
                pos.Y = conn.LastKnownPlayerPosition.Y;
                Console.WriteLine($"[GM Vehicle] Adjusting Y from 0 to player's Y: {pos.Y}");
            }
            
            ClientToGameserver.GmSpawnVehicle(conn, vehicleConfigId, pos, conn.LastCameraFacing, 262);
        }

        [Handler(MethodId.GmSpawnVehicle)]
        public static void GmSpawnVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSpawnVehicleArgs>();
            GmSpawnVehicle(conn, args.vehicleConfigId, args.x, args.y, args.z);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnVehicle);
        }

        public class GmSpawnVehicleArgs : SerializedClass
        {
            public uint vehicleConfigId;
            public float x;
            public float y;
            public float z;
            public GmSpawnVehicleArgs() { onlyFields = true; }
        }

        public static void GmDestroyVehicle(Connection conn)
        {
            ClientToGameserver.GmDestroyVehicle(conn);
        }

        [Handler(MethodId.GmDestroyVehicle)]
        public static void GmDestroyVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            GmDestroyVehicle(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmDestroyVehicle);
        }

        private static uint MapVehicleColor(uint colorId)
        {
            return VehicleColors.MapLegacyColor(colorId);
        }

        public static void GmChangeVehicleColor(Connection conn, uint newColorId)
        {
            newColorId = MapVehicleColor(newColorId);
            if (conn.CurrentVehicleId == 0 && conn.LastSpawnedVehicleId == 0)
            {
                Console.WriteLine($"[GM Vehicle] No vehicle to change color");
                return;
            }

            bool wasDriving = conn.CurrentVehicleId != 0;
            int savedSeat = conn.CurrentVehicleSeat;
            UXVector3 currentPosition = conn.LastVehicleSpawnPosition;
            float currentFacing = conn.LastVehicleFacing;
            uint vehicleConfigId = conn.LastSpawnedVehicleConfigId;

            if (wasDriving)
            {
                Console.WriteLine($"[GM Vehicle] Exiting vehicle before color change");
                ClientToGameserver.GmExitVehicle(conn);
            }

            ClientToGameserver.GmDestroyVehicle(conn);
            ClientToGameserver.SpawnVehicle(conn, vehicleConfigId, currentPosition, currentFacing, newColorId);

            if (wasDriving)
            {
                Console.WriteLine($"[GM Vehicle] Re-entering vehicle after color change");
                ClientToGameserver.GmEnterVehicle(conn, conn.LastSpawnedVehicleId, savedSeat);
            }

            Console.WriteLine($"[GM Vehicle] Changed vehicle color to {newColorId}");
        }

        [Handler(MethodId.GmChangeVehicleColor)]
        public static void GmChangeVehicleColorHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmChangeVehicleColorArgs>();
            GmChangeVehicleColor(conn, args.colorId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeVehicleColor);
        }

        public class GmChangeVehicleColorArgs : SerializedClass
        {
            public uint colorId;
            public GmChangeVehicleColorArgs() { onlyFields = true; }
        }

        public static void GmAddAllWeapons(Connection conn)
        {
            var allWeapons = Game.State.WeaponStateFactory.BuildWeapons();
            int added = 0;
            foreach (var weapon in allWeapons)
            {
                if (!conn.Weapons.Any(w => w.TemplateId == weapon.TemplateId))
                {
                    // Generate unique InstanceId
                    ulong maxId = conn.Weapons.Count > 0 ? conn.Weapons.Max(w => w.InstanceId) : 6000000000000;
                    weapon.InstanceId = maxId + 1;
                    conn.Weapons.Add(weapon);
                    added++;
                }
            }
            conn.SyncWeapons();
            Console.WriteLine($"[GM Weapon] Added {added} new weapons ({conn.Weapons.Count} total)");
        }

        [Handler(MethodId.GmAddAllWeapons)]
        public static void GmAddAllWeaponsHandler(Connection conn, UxRpcMessage msg)
        {
            GmAddAllWeapons(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAllWeapons);
        }

        public static void GmSetAttr(Connection conn, uint attrId, uint value)
        {
            Console.WriteLine($"[GM Attr] Setting attr {attrId} to {value}");
            var spirit = conn.GetCurrentSpirit();
            if (spirit != null)
            {
                SendNotify(conn, MethodId.SyncUnitAttrs, new SyncUnitAttrs()
                {
                    entityId = spirit.Id,
                    values = new() { { attrId, value } }
                });
            }
        }

        [Handler(MethodId.GmSetAttr)]
        public static void GmSetAttrHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSetAttrArgs>();
            GmSetAttr(conn, args.attrId, args.value);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetAttr);
        }

        public class GmSetAttrArgs : SerializedClass
        {
            public uint attrId;
            public uint value;
            public GmSetAttrArgs() { onlyFields = true; }
        }

        public static void GmUnlockAllFogMap(Connection conn)
        {
            Console.WriteLine($"[GM] Unlocking all fog map");
            SendNotify(conn, MethodId.SyncSceneFogMapAllUnlock, new SyncSceneFogMapAllData()
            {
                fogMapUnlocked = new Dictionary<uint, bool>()
            });
        }

        [Handler(MethodId.GmUnlockAllFogMap)]
        public static void GmUnlockAllFogMapHandler(Connection conn, UxRpcMessage msg)
        {
            GmUnlockAllFogMap(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockAllFogMap);
        }

        public static void GmEnterRaid(Connection conn, uint raidId)
        {
            Console.WriteLine($"[GM Raid] Entering raid {raidId}");
            // Send SyncPrepareMapEntrance to trigger client scene transition
            SendNotify(conn, MethodId.SyncPrepareMapEntrance, new SyncPrepareMapEntrance()
            {
                entrance = raidId
            });
        }

        [Handler(MethodId.EnterRaid)]
        public static void EnterRaidHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<EnterRaidArgs>();
            GmEnterRaid(conn, args.raidId);
            SendEmptySuccessReturn(conn, msg, MethodId.EnterRaid);
        }

        public class EnterRaidArgs : SerializedClass
        {
            public uint raidId;
            public EnterRaidArgs() { onlyFields = true; }
        }

        public static void GmLeaveRaid(Connection conn)
        {
            Console.WriteLine($"[GM Raid] Leaving raid");
            // SyncPlayerLeaveScene class not yet defined — would send scene leave notify
            // For now, client handles leave via AskLeaveRaid return
        }

        [Handler(MethodId.AskLeaveRaid)]
        public static void AskLeaveRaidHandler(Connection conn, UxRpcMessage msg)
        {
            GmLeaveRaid(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveRaid);
        }

        public static void GmRefreshAllDestructibles(Connection conn)
        {
            Console.WriteLine($"[GM] Refreshing all destructibles");
            // Re-spawn city destructible objects
            DestructibleObjectManager.SpawnCityObjects();
            var allObjects = DestructibleObjectManager.AllObjects;
            var entries = allObjects.Select(o => o.ToAddEntry()).ToList();
            if (entries.Count > 0)
            {
                SendNotify(conn, MethodId.SyncDestructibleObjectAddList, new SyncDestructibleObjectAddListData()
                {
                    Objects = entries
                });
                Console.WriteLine($"[GM] Refreshed {entries.Count} destructibles");
            }
        }

        [Handler(MethodId.GmRefreshAllDestructibles)]
        public static void GmRefreshAllDestructiblesHandler(Connection conn, UxRpcMessage msg)
        {
            GmRefreshAllDestructibles(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmRefreshAllDestructibles);
        }

        public static void GmAddDestructible(Connection conn, uint configId, float x, float y, float z)
        {
            Console.WriteLine($"[GM] Adding destructible {configId} at ({x}, {y}, {z})");
            var state = new DestructibleObjectState()
            {
                ConfigId = configId,
                Position = new UXVector3() { X = x, Y = y, Z = z },
                Facing = 0,
                Hp = 100,
                MaxHp = 100,
                State = 0, // normal
            };
            DestructibleObjectManager.AddObject(state);
            SendNotify(conn, MethodId.SyncDestructibleObjectAdd, state.ToAddEntry());
            Console.WriteLine($"[GM] Added destructible {state.DestructibleId} (configId={configId})");
        }

        [Handler(MethodId.GmAddDestructible)]
        public static void GmAddDestructibleHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmAddDestructibleArgs>();
            GmAddDestructible(conn, args.configId, args.x, args.y, args.z);
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddDestructible);
        }

        public class GmAddDestructibleArgs : SerializedClass
        {
            public uint configId;
            public float x;
            public float y;
            public float z;
            public GmAddDestructibleArgs() { onlyFields = true; }
        }

        public static void GmStartRaid(Connection conn, uint raidId)
        {
            Console.WriteLine($"[GM Raid] Starting raid {raidId}");
            // Start raid = enter raid with scene transition
            SendNotify(conn, MethodId.SyncPrepareMapEntrance, new SyncPrepareMapEntrance()
            {
                entrance = raidId
            });
        }

        [Handler(MethodId.GmStartRaid)]
        public static void GmStartRaidHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmStartRaidArgs>();
            GmStartRaid(conn, args.raidId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartRaid);
        }

        public class GmStartRaidArgs : SerializedClass
        {
            public uint raidId;
            public GmStartRaidArgs() { onlyFields = true; }
        }

        public static void GmEnterOtherRaid(Connection conn, uint raidId)
        {
            Console.WriteLine($"[GM Raid] Entering other raid {raidId}");
            // Enter another player's raid = same scene transition
            SendNotify(conn, MethodId.SyncPrepareMapEntrance, new SyncPrepareMapEntrance()
            {
                entrance = raidId
            });
        }

        [Handler(MethodId.GmEnterOtherRaid)]
        public static void GmEnterOtherRaidHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmEnterOtherRaidArgs>();
            GmEnterOtherRaid(conn, args.raidId);
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnterOtherRaid);
        }

        public class GmEnterOtherRaidArgs : SerializedClass
        {
            public uint raidId;
            public GmEnterOtherRaidArgs() { onlyFields = true; }
        }

        public static void GmOpenDebugPosition(Connection conn)
        {
            Console.WriteLine($"[GM] Opening debug position");
            conn.HasLastKnownPlayerPosition = true;
        }

        [Handler(MethodId.GmOpenDebugPosition)]
        public static void GmOpenDebugPositionHandler(Connection conn, UxRpcMessage msg)
        {
            GmOpenDebugPosition(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmOpenDebugPosition);
        }

        public static void GmFreeSkill(Connection conn, bool enable)
        {
            Console.WriteLine($"[GM] Free skill: {enable}");
            conn.GmInfiniteSkillCooldown = enable;
        }

        [Handler(MethodId.GmFreeSkill)]
        public static void GmFreeSkillHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmFreeSkillArgs>();
            GmFreeSkill(conn, args.enable);
            SendEmptySuccessReturn(conn, msg, MethodId.GmFreeSkill);
        }

        public class GmFreeSkillArgs : SerializedClass
        {
            public bool enable;
            public GmFreeSkillArgs() { onlyFields = true; }
        }

        public static void GmWeaponDurabilityFree(Connection conn, bool enable)
        {
            Console.WriteLine($"[GM] Weapon durability free: {enable}");
            conn.GmWeaponDurabilityFree = enable;
            if (enable)
            {
                foreach (var weapon in conn.Weapons)
                {
                    weapon.Durability = 10000;
                }
                conn.SyncWeapons();
            }
        }

        [Handler(MethodId.GmWeaponDurabilityFree)]
        public static void GmWeaponDurabilityFreeHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmWeaponDurabilityFreeArgs>();
            GmWeaponDurabilityFree(conn, args.enable);
            SendEmptySuccessReturn(conn, msg, MethodId.GmWeaponDurabilityFree);
        }

        public class GmWeaponDurabilityFreeArgs : SerializedClass
        {
            public bool enable;
            public GmWeaponDurabilityFreeArgs() { onlyFields = true; }
        }

        public static void GmSendTaskMessage(Connection conn, uint taskId, string message, float duration = 3.0f)
        {
            Console.WriteLine($"[GM Task] Sending task message: taskId={taskId}, message={message}");
            HandlerUtils.SendTaskMessage(conn, taskId, message, duration);
        }

        [Handler(MethodId.GmSendTaskMessage)]
        public static void GmSendTaskMessageHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSendTaskMessageArgs>();
            GmSendTaskMessage(conn, args.taskId, args.message, args.duration);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSendTaskMessage);
        }

        public class GmSendTaskMessageArgs : SerializedClass
        {
            public uint taskId;
            public string message;
            public float duration;
            public GmSendTaskMessageArgs() { onlyFields = true; }
        }

        public static void GmRecoverAllSkillCooldown(Connection conn)
        {
            Console.WriteLine($"[GM] Recovering all skill cooldowns");
            conn.ActiveSkills.Clear();
            Game.SkillManager.ClearAllCooldowns();
            SendNotify(conn, MethodId.SyncPlayerAllSkillChargeData, new SyncSkillCooldownData()
            {
                skillInstanceIds = new()
            });
        }

        [Handler(MethodId.GmRecoverAllSkillCooldown)]
        public static void GmRecoverAllSkillCooldownHandler(Connection conn, UxRpcMessage msg)
        {
            GmRecoverAllSkillCooldown(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.GmRecoverAllSkillCooldown);
        }

        public static void GmSetTimeFixLimit(Connection conn, bool enable)
        {
            Console.WriteLine($"[GM] Time fix limit: {enable}");
            if (enable)
            {
                conn.timeOffset = 0;
                SendNotify(conn, MethodId.SyncPlayerCurrentTime, new SyncPlayerCurrentTime()
                {
                    realTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                    raidDaySeconds = 0,
                    fix = true,
                    transitionSecond = 0,
                    reason = SyncPlayerCurrentTime.RaidTimeAndWeatherChangeReason.Gm
                });
            }
        }

        [Handler(MethodId.GmSetTimeFixLimit)]
        public static void GmSetTimeFixLimitHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSetTimeFixLimitArgs>();
            GmSetTimeFixLimit(conn, args.enable);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetTimeFixLimit);
        }

        public class GmSetTimeFixLimitArgs : SerializedClass
        {
            public bool enable;
            public GmSetTimeFixLimitArgs() { onlyFields = true; }
        }

        public static void GmSetReputation(Connection conn, uint factionId, uint value)
        {
            Console.WriteLine($"[GM] Setting reputation faction={factionId} value={value}");
            if (conn.FactionInfoDic.ContainsKey(factionId))
            {
                conn.FactionInfoDic[factionId].Disposition = (int)value;
                conn.FactionInfoDic[factionId].DispositionLevel = (uint)(value / 100 + 1);
            }
            SendNotify(conn, MethodId.SyncFactionInfosChange, new SyncReputationData()
            {
                factionId = factionId,
                disposition = value,
                dispositionLevel = (uint)(value / 100 + 1),
                influence = value * 2
            });
        }

        [Handler(MethodId.GmSetReputation)]
        public static void GmSetReputationHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GmSetReputationArgs>();
            GmSetReputation(conn, args.factionId, args.value);
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetReputation);
        }

        public class GmSetReputationArgs : SerializedClass
        {
            public uint factionId;
            public uint value;
            public GmSetReputationArgs() { onlyFields = true; }
        }
    }
}
