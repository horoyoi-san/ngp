using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Utils;
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
    public class Connection
    {
        public Socket ClientSocket;
        private Thread ReceiveThread;
        private List<byte> Buffer = new List<byte>();
        public RC4 rc4encrypt;
        public RC4 rc4Decrypt;
        public byte[] Rc4Key;
        public ulong Pid;
        public uint currentSpirit = 15020967;
        public List<SpiritInfo> Spirits = new()
        {
            CreateSpirit(15020967, 100000000000),
            new SpiritInfo()
            {
                TemplateId = 15020968,
                Id = 100000000002,
                HpRate = 1,
                CurrentJobId = 100,
                SpiritUrbanSkill = new()
                {
                    UrbanAbilities = new() { 92, 55, 70, 62, 81, 72 }
                },
                SpiritAbilities = CreateDefaultAbilities(),
                SpiritJobInfo = CreateDefaultJobInfo(),
                PermanentAddAttributes = new(),
                InfoBadge = new() { Badges = new(), HistoryBadges = new() },
                MobileSkinInfo = new() { Wallpaper = 12003000, Decoration = 12003001, Pendant = 12003002 },
                WeaponSlots = new(),
                SpiritBattleInfo = new(),
                TalentInfo = CreateDefaultTalentInfo(),
                SpiritFightStyle = new() { FightStyleInfo = new() }
            },
            CreateSpirit(15020967, 100000000000),
            CreateSpirit(15021021, 100000000001),
            CreateSpirit(15021040, 100000000003),
            CreateSpirit(15021023, 100000000005),
            CreateSpirit(15021024, 100000000006),
            CreateSpirit(15020989, 100000000007),
            CreateSpirit(15020997, 100000000008),
            CreateSpirit(15020992, 100000000009),
        };
        public List<WeaponDetail> Weapons = new()
        {
            new WeaponDetail()
                        {
                            TemplateId = 98003184,
                            InstanceId = 6000000000001,
                            SpecialLabel = "",
                            WeaponFlags = new()
                            {
                                AdditionalEffectIds = new(),
                                IsTaskWheelWeapon = false
                            },

                            Durability = -1,

                        },
                        new WeaponDetail()
                        {
                            TemplateId = 98005002,
                            InstanceId = 6000000000002,
                            SpecialLabel = "",
                            WeaponFlags = new()
                            {
                                AdditionalEffectIds = new(),
                                IsTaskWheelWeapon = false
                            },

                            Durability = 10000,

                        },
                        new WeaponDetail()
                        {
                            TemplateId = 98006006,
                            InstanceId = 6000000000003,
                            SpecialLabel = "",
                            WeaponFlags = new()
                            {
                                AdditionalEffectIds = new(),
                                IsTaskWheelWeapon = false
                            },

                            Durability = 10000,
                            MagazineAmmo=1000,

                        },
                        new WeaponDetail()
                        {
                            TemplateId = 98003185,
                            InstanceId = 6000000000004,
                            SpecialLabel = "",
                            WeaponFlags = new()
                            {
                                AdditionalEffectIds = new(),
                                IsTaskWheelWeapon = false
                            },

                            Durability = 10000,
                            MagazineAmmo=1000,

                        }
        };
        public int WeaponIndex = 1;
        public SpiritInfo GetCurrentSpirit()
        {
            return Spirits.Find(s => s.TemplateId == currentSpirit);
        }
        public Connection(Socket socket)
        {
            this.ClientSocket = socket;
            ReceiveThread = new Thread(ReceiveLoop);
            ReceiveThread.Start();
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
                        
                        continue;
                    }

                    // Aggiungi i nuovi byte al buffer
                    Buffer.AddRange(new ArraySegment<byte>(recvBuffer, 0, received));

                    // Processa i pacchetti completi
                    ProcessPackets();
                }
            }
            catch(Exception e)
            {
                Disconnect();
            }
        }

        private void ProcessPackets()
        {
            while (true)
            {
                // Need at least: [int length][byte type] => 5 bytes
                if (Buffer.Count < 5)
                    return;

                int length = ReadInt32LE(Buffer, 0);

                // Outer framing: [int bodyLength][byte type][body...]
                // total packet bytes = 4 + 1 + bodyLength
                if (length < 0 || length > 10_000_000)
                {
                    // Desync: slide by 1 byte instead of clearing everything.
                    Buffer.RemoveAt(0);
                    continue;
                }

                int totalSize = 5 + length;
                if (Buffer.Count < totalSize)
                    return; // wait for more data

                UxMessageType type = (UxMessageType)Buffer[4];

                byte[] packetData = new byte[length];
                if (length > 0)
                    Buffer.CopyTo(5, packetData, 0, length);

                // Decrypt only when decryptor is ready.
                if (rc4Decrypt != null && packetData.Length > 0)
                {
                    packetData = rc4Decrypt.Crypt(packetData);
                }

                // Remove consumed bytes
                Buffer.RemoveRange(0, totalSize);

                UxMessage packet = UxMessageFactory.Create(type, packetData);
                try
                {
                    HandlePacket(packet);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                    Console.WriteLine(e.StackTrace);
                }
            }
        }

        private static int ReadInt32LE(List<byte> buffer, int offset)
        {
            // Ensure enough bytes already validated by caller.
            // TCP is a byte stream; our protocol expects little-endian ints.
            unchecked
            {
                return buffer[offset]
                    | (buffer[offset + 1] << 8)
                    | (buffer[offset + 2] << 16)
                    | (buffer[offset + 3] << 24);
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
            Console.WriteLine("[Received] " + packet.ToString());
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
                if (rsp.Encryption)
                    rc4Decrypt = new RC4(rsp.Keys);
                SendPacket(rsp);
                if (rsp.Encryption)
                    rc4encrypt = new RC4(rsp.Keys);
            }

            if (packet.Type == UxMessageType.Raw)
            {
                UxRpcMessage req = (UxRpcMessage)packet;

                // Targeted URL debugging (scope C): log RPC payload URLs if payload contains "http"/"https".
                // This helps correlate the Unity-side "Curl error 3" with the exact RPC method/payload.
                try
                {
                    if (req.Args != null && req.Args.Length > 0)
                    {
                        var asciiContainsHttp = Encoding.ASCII.GetString(req.Args).IndexOf("http", StringComparison.OrdinalIgnoreCase) >= 0;
                        if (asciiContainsHttp)
                        {
                            var urls = AnantaTestGameServer.Utils.UrlStringExtractor.ExtractHttpUrls(req.Args);
                            if (urls.Count > 0)
                            {
                                Logger.PrintWarn($"[RPC_URL_HIT] methodId={req.RpcMethodId} mode={req.Mode} invokeId={req.RpcInvokeId} retcode={req.RpcRetcode} urlsCount={urls.Count}");
                                foreach (var u in urls)
                                {
                                    // Also dump a compact hex prefix so we can match exact byte sequences if needed.
                                    string hexPrefix = BitConverter.ToString(req.Args, 0, Math.Min(64, req.Args.Length)).Replace("-", " ");
                                    Logger.PrintWarn($"[RPC_URL] {u} | argsHexPrefix({Math.Min(64, req.Args.Length)} bytes): {hexPrefix}");
                                }
                            }
                        }
                    }
                }
                catch { }

                HandlerDelegate Hdelegate = NotifyManager.GetHandler(req.RpcMethodId);
                if (Hdelegate != null)
                {
                    Hdelegate.Invoke(this, req);
                }
                else
                {
                    // Unknown RPC handler. Do NOT send a partially-constructed Return; it can desync the client.
                    // Instead, for Invoke messages send a Return with a non-zero retcode and no args.
                    if (req.Mode == UxRpcPacketMode.Invoke)
                    {
                        UxRpcMessage rsp = new UxRpcMessage()
                        {
                            Mode = UxRpcPacketMode.Return,
                            RpcInvokeId = req.RpcInvokeId,
                            RpcMethodId = req.RpcMethodId,
                            RpcRetcode = 1,
                            Args = Array.Empty<byte>()
                        };
                        // Ensure Body is empty for no-args Return.
                        rsp.Args = Array.Empty<byte>();
                        rsp.Build();
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
                ClientSocket?.Shutdown(SocketShutdown.Both);
            }
            catch { }
            ClientSocket?.Close();

            Server.Instance.RemoveConnection(this);
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
                RpcMethodId = (int)MethodId.SyncAgentCharacter,
            };
            rsp9.SetArgs(MethodId.SyncUnitBuffList, new SyncUnitBuffList()
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
                        Id=52853763, //CarBuff
                        InstanceId=1003248,
                        Permanent=true,
                        Tier=1
                    }
                }
            });



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
                TempWeaponSlots = new()
                {
                    WeaponSlots =Weapons,
                    WheelId = 1,

                },
                WeaponSlots = new()
                {

                },

            };
            data.CurrentWeaponUid = data.TempWeaponSlots.WeaponSlots[WeaponIndex].InstanceId;
            rsp1.SetArgs(MethodId.SyncSpiritWeaponDetail, data);
            SendPacket(rsp1);
        }
        public void SyncWeapon(int i)
        {
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

        private static SpiritInfo CreateSpirit(uint templateId, ulong id)
        {
            return new SpiritInfo()
            {
                TemplateId = templateId,
                Id = id,
                HpRate = 1,
                CurrentJobId = 100,
                SpiritUrbanSkill = new() { UrbanAbilities = new() },
                SpiritAbilities = CreateDefaultAbilities(),
                SpiritJobInfo = CreateDefaultJobInfo(),
                PermanentAddAttributes = new(),
                InfoBadge = new() { Badges = new(), HistoryBadges = new() },
                MobileSkinInfo = new() { Wallpaper = 12003000, Decoration = 12003001, Pendant = 12003002 },
                WeaponSlots = new(),
                SpiritBattleInfo = new(),
                TalentInfo = CreateDefaultTalentInfo(),
                SpiritFightStyle = new() { FightStyleInfo = new() }
            };
        }

        private static Dictionary<uint, SpiritAbilityInfo> CreateDefaultAbilities()
        {
            return new Dictionary<uint, SpiritAbilityInfo>()
            {
                {1, new SpiritAbilityInfo(){
                    TemplateId=1,
                    Level=5,
                    ConfirmedLevel=5,
                    AbilityBuffConfigIdList=new(),
                    BuffList=new(),
                    Exp=1000
                }},
                {100, new SpiritAbilityInfo(){
                    TemplateId=100,
                    Level=5,
                    ConfirmedLevel=5,
                    AbilityBuffConfigIdList=new(),
                    BuffList=new()
                }},
                {101, new SpiritAbilityInfo(){
                    TemplateId=101,
                    Level=1,
                    ConfirmedLevel=1,
                    AbilityBuffConfigIdList=new(),
                    BuffList=new()
                }},
                {102, new SpiritAbilityInfo(){
                    TemplateId=102,
                    Level=1,
                    ConfirmedLevel=1,
                    AbilityBuffConfigIdList=new(),
                    BuffList=new()
                }},
                {200, new SpiritAbilityInfo(){
                    TemplateId=200,
                    Level=1,
                    ConfirmedLevel=1,
                    AbilityBuffConfigIdList=new(),
                    BuffList=new()
                }},
                {300, new SpiritAbilityInfo(){
                    TemplateId=300,
                    Level=1,
                    ConfirmedLevel=1,
                    AbilityBuffConfigIdList=new(),
                    BuffList=new(),
                }},
            };
        }

        private static SpiritJobInfo CreateDefaultJobInfo()
        {
            return new SpiritJobInfo()
            {
                CurrentJob = 100,
                AvailableJobs = new(),
                HistoryJobs = new()
            };
        }

        private static SpiritTalentInfo CreateDefaultTalentInfo()
        {
            return new SpiritTalentInfo()
            {
                Level = 1,
                TalentPoint = 10,
                UnlockTalentInfoDict = new()
                {
                    {601, new SpiritOrJobTalentNodeInfo()
                    {
                        TalentId=601,
                        Layer=0,
                    }},
                    {608, new SpiritOrJobTalentNodeInfo()
                    {
                        TalentId=608,
                        Layer=0,
                    }}
                }
            };
        }
    }
}
