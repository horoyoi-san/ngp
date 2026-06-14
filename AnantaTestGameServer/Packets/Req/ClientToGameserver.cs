using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;
using static AnantaTestGameServer.Methods.Return.SpiritInfo;

namespace AnantaTestGameServer.Packets.Req
{
    internal class ClientToGameserver
    {

        [Handler(MethodId.LoginGame)]
        public static void LoginGame(Connection conn, UxRpcMessage msg)
        {
            LoginGame args = msg.GetArgs<LoginGame>();
            Console.WriteLine(args.ToString());
            conn.Pid = args.pid;
            PlayerClientInfo data = new PlayerClientInfo()
            {

                InfoLogin = new()
                {
                    AccountId = "aibgr4rznwj5r6zg",
                    Pid = args.pid,
                    Aid = 5944,
                    Level = 1,
                    Name = "AnantaPS",
                    
                    Sex = RPCMethodArgsRequestCreateRoleEx.SexType.Male,
                    PzHeadInfo = new()
                    {
                        HeadType = PersonalZoneHeadInfo.PersonalZoneHeadType.System,
                        SystemHeadId = 91195003
                    },

                },
                Config = new byte[0],
                InfoAchievement = new()
                {
                    ChallengeRecordInfo = new(),
                    CompletedSubQuestCnt = new()
                    {
                        
                    },
                    FirstKillEnemyRecord = new(),
                    CountryReputationInfo = new(),
                    FactionInfoDic = new()
                    {
                        {18000111, new FactionInfo()
                        {
                            
                        } }
                    },
                    NewChallengeRecordInfo = new(),
                    OccupiedInfluenceArea = new(),
                    SceneFogMapPoiIds = new(),
                    SceneFogMaps = new(),
                    UnlockedCountryList = new(),
                    UnlockedQuestList = new(),
                    UnlockInvestigateGalleryList = new(),

                },
                InfoItem = new()
                {
                    DestructibleShortcut = 0,

                    ItemCountLimitInfoList = new(),
                    PortalPosition = new(),
                    PackItems = new(),
                    ItemDayCounts = new(),
                    ItemShortcutDic = new()
                    {
                        {ItemShortcutType.Wheel1, new ItemShortcutInfo()
                        {
                            
                        } },
                        {ItemShortcutType.Wheel2, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Wheel3, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Wheel4, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Wheel5, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Resurrection, new ItemShortcutInfo()
                        {

                        } }
                    },
                    GachaPoolCount = new(),
                   // PortalRaidId= 23301263
                },
                InfoMinor = new()
                {
                    Badges = new(),
                    ChargeInfo = new()
                    {

                    },
                    ModuleEventProgressInfoDict = new()
                    {
                        
                    },
                    ComputerUnlockInfo = new()
                    {
                        ComputerInfos = new(),
                        UnlockEmails = new(),
                        UnlockFiles = new(),

                    },
                    DropLimitCount = new(),
                    FavorNpcDailyScheduleInfos = new(),
                    GroupChats = new(),
                    housesInfo = new()
                    {
                        FurnitureInfoDict = new(),
                        HouseInfoList = new(),
                        NotParkingSpaceVehicleIdList = new(),

                    },
                    InfoNpcCultivation = new()
                    {
                        NpcEventQueueList = new()
                        {
                            IdToNpcDict = new(),
                            NpcQueues = new(),

                        },
                        LockedCardInfos = new(),
                        NpcCardInfos = new(),
                        NpcChats = new(),
                        NpcGroupChats = new(),

                    },
                    InfoNpcProfile = new()
                    {
                        NpcProfiles = new(),
                        ProgressRewards = new(),

                    },
                    LevelRewards = new(),
                    LoadingTexts = new(),
                    MallInfo = new()
                    {
                        CommodityInfoDict = new(),
                        CommoditySpiritDisplayPreferencesList = new(),
                        MonthCardInfo = new()
                        {

                        },

                    },
                    MapPins = new(),
                    MatchInfo = new()
                    {
                        AvailablePrepareActions=new(),
                        LoadingTypeInfo = new()
                        {
                            Members=new()
                        },
                        GameId2LastPlayTime=new()
                    },
                    MiniGame = new()
                    {
                        MiniGame_Bee = new(),

                    },
                    Level = 1,
                    Fan=100,
                    Fan12=100,
                    Fan123=100,
                    
                    PlanningBoardInfo = new()
                    {
                        StepId2OptionIndexDict = new(),
                        
                    },
                    PlayerBattlePassInfo = new()
                    {
                        ChallengeTaskStates = new(),
                        ClaimedLevelRewards = new(),
                        CurrentPassType=BattlePassType.Free,
                        CurrentBattlePassId=1
                    },
                    PlayerCityPediaInfos = new()
                    {
                        CityPedia2IsReadDict = new(),
                        CreditInfo = new()
                        {
                            ClaimedLevelRewards = new(),

                        },

                    },
                    PlayerFashionsInfo = new()
                    {
                        FashionInfoDict = new(),
                        FavoriteFashionIdList = new(),
                        FavoriteFashionSuitIdList = new(),

                        SpiritFashionsInfoDict = new()
                        {
                            {15021023, new SpiritFashionsInfo()
                            {
                                FashionFunctionSuitSchemeInfoDict=new(),
                                FirstGainSuitIdList=new(),
                                SpiritId=15021023,

                                SpiritPrevWearFashionsInfo = new()
                                {
                                     WearFashionInfoList=new(),
                                    WearFashionEditInfoList=new(),

                                },
                                SpiritWearFashionsInfo = new()
                                {
                                    WearFashionInfoList=new(),
                                    WearFashionEditInfoList=new(),

                                },
                                FashionCustomSuitSchemeInfos=new FashionCustomSuitSchemeInfo[0]

                            }
                            },
                           
                        },
                        SpiritId2TaskTryWearInfoDict = new()
                    },
                    PlayerGachaInfos = new()
                    {
                        GroupInfos = new(),
                        PityInfos = new(),
                        PoolInfos = new()
                    },
                    PlayerInfoAtmosphereGameplay = new()
                    {
                        PartTimeJobUnlockStore = new()
                    },
                    PlayerInfoGuide = new()
                    {
                        FinishedGuides = new(),
                        NewGuideTeachInfos = new(),
                        RewardedGuideTeachInfos = new(),
                        TaskTitleGuideUnlockList = new(),
                        UnlockSystems = new()
                        {
                             
                        },

                    },
                    PlayerInspireHubInfo = new()
                    {
                        TodayGamePlayJoinCountDict = new(),

                    },
                    PlayerInteractionActionInfo = new()
                    {
                        UnlockActionItemDict = new(),

                    },
                    PlayerInterActionInfo = new(),
                    PlayerLinkPlanningBoardInfo = new()
                    {

                        MultiGamePutInKeyCountInfoList = new(),

                    },
                    PlayerPhoneInfo = new()
                    {
                        DownLoadAppIds = new(),
                        SpiritPhoneInfos = new()
                        {
                            
                        },

                    },
                    PopularityInfoNew = new()
                    {
                        ChangeList = new(),
                        DropList = new(),
                        HistoryPopularityList = new(),
                        PastHoursCoinRewards = new(),
                        WalletRewards = new(),
                        

                    },
                    VehicleInfo = new()
                    {
                        UnlockedVehicles = new() { },

                    },


                },
                InfoSpirit = new()
                {
                    Spirits = conn.Spirits,
                    InfoPokemon = new()
                    {
                        AllPokemons = new()
                        {
                            
                        },
                        EnabledBodyIds = new(),
                        EnabledCampIds = new(),
                        EnabledWeaponIds = new(),
                        FastFightSquad = new(),

                    },
                    AvailableSkinParts = new(),
                    InfoArmory = new()
                    {
                        Weapons = new()
                        {
                            new WeaponData()
                            {
                                TemplateId=98005002,
                                InstanceId=13,
                                SpecialLabel="",
                                WeaponFlags = new()
                                {
                                    AdditionalEffectIds=new(),
                                    IsTaskWheelWeapon=true
                                },

                                Durability=10000,

                            }
                        },

                    },
                    InfoFightStyle = new()
                    {
                        FightStyleIsUnLocked = new(),

                    },
                   
                  
                    DisableBadgeInfoDict = new(),
                    ActiveSpirit = conn.currentSpirit
                },

            };


            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerInfo
            };
            foreach(SystemUnlock type in Enum.GetValues(typeof(SystemUnlock)))
            {
                
                data.InfoMinor.PlayerInfoGuide.UnlockSystems.Add((uint)type);
            }

            rsp.SetArgs(MethodId.SyncPlayerInfo, data);



           
            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnterScene
            };

            rsp7.SetArgs(MethodId.SyncEnterScene, new EnterSceneInfo()
            {
                GridInfo = new()
                {
                    MaxX=300000,
                    MaxZ=300000,
                    
                },
                PlayerSessionId = conn.Pid,
                InstanceId = (uint)20001200,
                
                //SectorControlId = 17300301,
                Position = new()
                {
                    Y=0,
                    X=1000,
                    Z=2000
                },
                LoadingType = new()
                {
                    
                },
                
                RaidId = 23300888,
                Spirits = new List<SpiritInitData>()
                {
                }
                .Concat(conn.Spirits.Select(s => new SpiritInitData()
                {
                    Id = s.Id,
                    TemplateId = s.TemplateId,
                    IsActive = s.TemplateId==conn.currentSpirit,
                    
                }))
                .ToList(),
                // IsSwitchSpiritShow =true,
                //  SwitchShowId= (uint)new Random().Next(12),
                SpoonLevels = new string[0],
                SpoonMd5s= new string[0],
                

            });


          

            conn.SendPacket(rsp);
           
            UxRpcMessage rsp2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllTask
            };

            rsp2.SetArgs(MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                eventPanelInfo = new()
                {
                    EventsInfo = new()
                    {
                        new TaskEventInfo()
                        {
                            EventId=1441,
                            HasAccepted=true,
                            IsUnderway=true,
                            Visible=true,
                            TaskId=60004938,
                            FinishedChoiceLs=new(),
                            Acceptable=true,
                            RedPoint=true,
                            
                        }
                    }
                },
                eventViewInfoList = new()
                {
                    new EventSpoonViewInfo()
                    {
                        EventId=1441,
                        RaidId=23301180,
                        SpoonMd5="",
                        
                    }
                },
                submitEventList = new() { },
                loginGameServer=true,
                submitTaskList = new() {  },
                taskInfos = new()
                {
                   new TaskViewData()
                   {
                       TaskId=60004938,
                       State=TaskState.Accepted,
                       CounterValues=new(){1},
                       Counters = new()
                       {
                           new TaskViewCounter()
                           {
                               ConfigValue=1,
                               Index=0,
                               Parent=0,
                               Duty=new uint[0]
                           }
                       },
                       RecoverResource=false,
                       SpoonViewInfo = new()
                       {
                           EventId=1441,
                           SpoonMd5="",
                           SpRaidId=23301180, //Task raid
                           StartTaskId=60004938,
                           EventStartTaskId=60004938,
                           Alias=""
                       },
                       
                   }
                }

            });



            conn.SendPacket(rsp2);
            
            conn.SendPacket(rsp7);

        }

        public class GetServerTimeGame : SerializedClass
        {

            public double clientUnixTime;

            public GetServerTimeGame()
            {
                onlyFields = true;
            }
        }
        public class AskUpdatePlayerCameraDirection : SerializedClass
        {

            public float cameraDirection;
           
            public AskUpdatePlayerCameraDirection()
            {
                onlyFields = true;
            }
        }
        public class SyncUnitFacingDirection : SerializedClass
        {
            public ulong pid;
            public float facing;
         
            public SyncUnitFacingDirection()
            {
                onlyFields = true;
            }
        }
        
        [Handler(MethodId.AskUpdatePlayerCameraDirection)]
        public static void AskUpdatePlayerCameraDirectionHandler(Connection conn, UxRpcMessage msg)
        {
            AskUpdatePlayerCameraDirection args = msg.GetArgs<AskUpdatePlayerCameraDirection>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitFacingDirection,
            };

            rsp.SetArgs(MethodId.SyncUnitFacingDirection, new SyncUnitFacingDirection()
            {
                pid=conn.Pid,
                facing=args.cameraDirection
            });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetServerTimeGame)]
        public static void GetServerTimeGameHandler(Connection conn, UxRpcMessage msg)
        {
            GetServerTimeGame args = msg.GetArgs<GetServerTimeGame>();
            //MethodId.SyncReport
            // conn.SendPacket(rsp1);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SendServerTimeGame,
            };

            rsp.SetArgs(MethodId.SendServerTimeGame, new SendServerTimeGame()
            {
                serverUnixTime=args.clientUnixTime,
                clientUnixTime=args.clientUnixTime,
            });



            conn.SendPacket(rsp);
            UxRpcMessage rsp2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHp,
            };

            rsp2.SetArgs(MethodId.SyncUnitHp, new SyncUnitHp()
            {
                unitId= conn.GetCurrentSpirit().Id,
                hp=50
            });



            conn.SendPacket(rsp2);
            conn.SyncAttributes();
            conn.SyncWeapons();
            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSkillChargeData,
            };
            rsp7.SetArgs(MethodId.SyncPlayerAllSkillChargeData, new SyncPlayerAllSkillChargeData()
            {

                spiritId = conn.GetCurrentSpirit().Id,
                allChargeDatas = new()
                {
                    {51942120, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=1,
                        CurrentPercentage=1,
                        MaxCharges=1,
                        
                    }},
                    {51942112, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=1,
                        CurrentPercentage=1,
                        MaxCharges=1,

                    }},
                    {51942115, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=1,
                        CurrentPercentage=1,
                        MaxCharges=1,

                    }}
                }

            });
            conn.SendPacket(rsp7);
            UxRpcMessage rsp8 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritUnitUrbanAttrs,
            };
            rsp8.SetArgs(MethodId.SyncSpiritUnitUrbanAttrs, new SyncSpiritUnitUrbanAttrs()
            {

                entityId = conn.GetCurrentSpirit().Id,
                urbanAttrsvalues = new()
                {
                    {1,10 },
                    {2,10 },
                    {3,10 },
                    {4,10 },
                    {5,10 },
                    {6,10 }
                }

            });


            conn.SendPacket(rsp8);

            conn.SyncBuffs();
            UxRpcMessage rsp3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,

            };
            rsp3.SetArgs(MethodId.SyncPlayerWeather, new SyncPlayerWeather()
            {
                weatherTypeId = 3,
                nextWeatherTypeId = 3,
                transitionSecond = 1,

            });
            //conn.SendPacket(rsp3);
        }
        public class AskRemoveClientBuff : SerializedClass
        {
            public ulong unitId;
            public uint buffId;

            public AskRemoveClientBuff()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.AskRemoveClientBuff)]
        public static void AskRemoveClientBuffH(Connection conn, UxRpcMessage msg)
        {
            AskRemoveClientBuff args = msg.GetArgs<AskRemoveClientBuff>();
            //MethodId.SyncReport
            // conn.SendPacket(rsp1);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SendServerTimeGame,
            };

            rsp.SetArgs(MethodId.SyncUnitRemoveBuff, new AskRemoveClientBuff()
            {
                unitId=args.unitId,
                buffId=args.buffId
            });

            

          //  conn.SendPacket(rsp);
           
        }
        [Handler(MethodId.AskAetherChangeQuality)]
        public static void AskAetherChangeQualityHandler(Connection conn, UxRpcMessage msg)
        {
           

        }
        public class SyncGamePause : SerializedClass
        {
            public byte pause;

            public SyncGamePause()
            {
                onlyFields = true;
            }
        }
        public class SyncPlayerMoveToDriveSeat : SerializedClass
        {
            public ulong pid;
            public ulong vehicleEntityId;


            public SyncPlayerMoveToDriveSeat()
            {
                onlyFields = true;
            }
        }
        public class SyncRemoveUnitState : SerializedClass
        {
            public ulong entityId;
            public uint state;
            public UnitStateChangeType reason;
            public uint effectFreezeState;
            public SyncRemoveUnitState()
            {
                onlyFields = true;
            }
            public enum UnitStateChangeType // TypeDefIndex: 28542
            {
                Add = 0,
                Remove = 1,
                Exclusion = 2
            }
        }
        public class SyncSceneLoadCompleted : SerializedClass
        {
            public ulong sceneId;

            public SyncSceneLoadCompleted()
            {
                onlyFields = true;
            }
        }
        public class AskLoadSceneCompleted : SerializedClass
        {
            public ulong sceneId;
            public ulong sessionId;

            public AskLoadSceneCompleted()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.AskLoadingFinished)]
        public static void AskLoadingFinishedHandler(Connection conn, UxRpcMessage msg)
        {
            AskLoadSceneCompleted args = msg.GetArgs<AskLoadSceneCompleted>();
            conn.SyncAttributes();
            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldReady,
            };
            rsp1.SetArgs(MethodId.SyncSceneLoadCompleted, new SyncSceneLoadCompleted()
            {
                sceneId = args.sceneId
            });
           
           // conn.SendPacket(rsp1);


            UxRpcMessage rsp3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentTask
            };

            rsp3.SetArgs(MethodId.SyncCurrentTask, new SyncCurrentTask()
            {
                eventId = 1441,
                taskId = 60004938,
                firstTime = true,
                reason = SyncCurrentTask.ChangeCurrentTaskReason.MainEvent,
                taskGps = new()
                {
                    BelongTaskId = 60004938,
                    Type = SyncCurrentTask.TaskGpsType.None,
                    Position = new()
                },
                type = SyncCurrentTask.CurrentTaskType.Primary
            });



            conn.SendPacket(rsp3);
            UxRpcMessage rsp4 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedSpirit
            };
            rsp4.SetArgs(MethodId.SyncManagedSpirit, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId=1
                
            });
           // conn.SendPacket(rsp4);
            UxRpcMessage rsp5 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedAgent
            };
            
            rsp5.SetArgs(MethodId.SyncManagedAgent, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId = 0

            });
            conn.SendPacket(rsp5);
            
            SpawnVehicle(conn);
            conn.SyncWeapon(0);
        }
        [Handler(MethodId.AskLoadSceneCompleted)]
        public static void AskLoadSceneCompletedHandler(Connection conn, UxRpcMessage msg)
        {
            AskLoadSceneCompleted args = msg.GetArgs<AskLoadSceneCompleted>();
            Console.WriteLine(args.ToString());
            conn.SyncAttributes();
            conn.SyncWeapon(0);
            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneLoadCompleted,
            };
            rsp1.SetArgs(MethodId.SyncSceneLoadCompleted, new SyncSceneLoadCompleted()
            {
                sceneId = args.sceneId
            });
           // conn.SendPacket(rsp1);

            

        }
        public class AskGetAllMetroInfos : SerializedClass
        {
            public List<MetroClientInfo> list;


            public AskGetAllMetroInfos()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.AskGetAllMetroInfos)]
        public static void AskGetAllMetroInfosHandler(Connection conn, UxRpcMessage msg)
        {

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetAllMetroInfos,
            };

            rsp.SetArgs(MethodId.AskGetAllMetroInfos, new AskGetAllMetroInfos()
            {
                list = new()
                {
                    
                }
            });



            conn.SendPacket(rsp);
           
        }
        public class QuerySkey : SerializedClass
        {
            public string key;
            public QuerySkey()
            {
                onlyFields = true;
            }
        }
        [Handler(153965146)]
        public static void QuerySkeyHandler(Connection conn, UxRpcMessage msg)
        {

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)153965146
            };

            rsp.SetArgs(153965146, new QuerySkey()
            {
                key="idk?"
            });



            conn.SendPacket(rsp);
        }
        public class AskAllSpiritPanelData : SerializedClass
        {
            public List<SpiritPanelData> list;


            public AskAllSpiritPanelData()
            {
                onlyFields = true;
            }
           
        }
        [Handler(MethodId.AskAllSpiritPanelData)]
        public static void AskAllSpiritPanelDataHandler(Connection conn, UxRpcMessage msg)
        {

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAllSpiritPanelData,
            };

            rsp.SetArgs(MethodId.AskAllSpiritPanelData, new AskAllSpiritPanelData()
            {
                list = conn.Spirits.Select(S => S.ToSpiritPanelData()).ToList()
            });



            conn.SendPacket(rsp);
        }
        public class ChangeParkourState : SerializedClass
        {
            public uint parkourStateId;


            public ChangeParkourState()
            {
                onlyFields = true;
            }
           
        }
        public class OnParkourStateChange : SerializedClass
        {
            public uint parkourStateId;


            public OnParkourStateChange()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.OnParkourStateChange)]
        public static void OnParkourStateChangeHandler(Connection conn, UxRpcMessage msg)
        {
            OnParkourStateChange args = msg.GetArgs<OnParkourStateChange>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.OnParkourStateChange,
            };

            rsp.SetArgs(MethodId.ChangeParkourState, new ChangeParkourState()
            {
               parkourStateId=args.parkourStateId
            });



            conn.SendPacket(rsp);
        }
        public class AskSwitchSpirit : SerializedClass
        {
            public uint spiritId;


            public AskSwitchSpirit()
            {
                onlyFields = true;
            }
        }
        public static void SpawnNPC(Connection conn)
        {
            ulong randomNpcGuid = (ulong)new Random().NextInt64();
            UxRpcMessage rsp8 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData,
            };

            rsp8.SetArgs(MethodId.SyncAetherAIStaticNpcAddData, new ClientStaticNpcInitData()
            {
                Position = new()
                {
                    Y = 0,
                    X = 1003,
                    Z = 2000
                },
                Id = randomNpcGuid,
                StaticNpcInfoId = randomNpcGuid,
                AgentPersonaId = 45200058,
                NpcPid = 41739060,
                UrbanDiversityId = 88888000,
                NpcFormworkId = 40924922,
                PoiActionId = 0,

                AgentSyncClientInfo = new()
                {
                    stimIDList = new int[0],
                    CanBeExaminedByPolice = true,
                    indoorList = new(),
                    roomIds = new int[0],
                    SpoonAgentId = 0,
                    treeName = "",
                    petPerformData = "",
                    spawnEffectId = new uint[0],
                    randomModelCfgId = 0,
                    LeaveDistance = 10000,
                    approachDistance = 10000,
                    FashionSuitId = 11190001,
                    
                },

            });



            conn.SendPacket(rsp8);
        }
        public static void SpawnVehicle(Connection conn)
        {
            ulong randomVehicleGuid = (ulong)new Random().NextInt64();
            UxRpcMessage rsp3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpawnVehicle,
            };

            rsp3.SetArgs(MethodId.SyncSpawnVehicle, new VehicleClientInfo()
            {
                EntityId = randomVehicleGuid,
                VehicleConfigId = 81005003,
                Interactable = true,
                ControllerPid=conn.Pid,
                //IsDynamicGo=true,
                
                Facing=45,
                Position = new()
                {
                    Y = 5,
                    X = 1015,
                    Z = 1998
                },
                Parts = new()
                {

                },
                ColorConfigId = 262,
                SummonType = VehicleSummonType.ForceSummon,
                GpsInfo = new()
                {
                    TargetPosition = new(),
                    Type = RaidVehicleGpsInfo.GpsType.None
                },
                CreateSourceType = VehicleCreateSourceType.Online,
                DisableNavigation=true,
                SpoonId=25001,
                SeatInfos = new()
                {
                    new RaidVehicleSeatInfo()
                    {
                        EntityId=randomVehicleGuid+1,
                        SeatIndex=0,
                        SeatState=RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated=true
                    },
                    new RaidVehicleSeatInfo()
                    {
                        EntityId=randomVehicleGuid+2,
                        SeatIndex=1,
                        SeatState=RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated=true
                    },
                    new RaidVehicleSeatInfo()
                    {
                        EntityId=randomVehicleGuid+3,
                        SeatIndex=2,
                        SeatState=RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated=true
                    },
                    new RaidVehicleSeatInfo()
                    {
                        EntityId=randomVehicleGuid+4,
                        SeatIndex=3,
                        SeatState=RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated=true
                    }
                }
            });
            
            
            
            conn.SendPacket(rsp3);
            
            UxRpcMessage rsp5 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitVehicleStatus,
            };
            rsp5.SetArgs(MethodId.SyncUnitVehicleStatus, new NewClientBoardingInfo()
            {
                EntityId = conn.GetCurrentSpirit().Id,
                SeatIndex = 0,
                Status = NewClientBoardingInfo.BoardingStatus.OnVehicle,
                VehicleUId = randomVehicleGuid
            });
           // conn.SendPacket(rsp5);

            UxRpcMessage rsp6 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerVehicleStateChange,
            };
            rsp6.SetArgs(MethodId.SyncVehicleBuffList, new PlayerVehicleDriveStateInfo()
            {
               Pid=conn.Pid,
               //VehicleEntityId=randomVehicleGuid,
               
                
            });
            //conn.SendPacket(rsp6);
            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAISetVehicleStatus,
            };
            rsp7.SetArgs(MethodId.SyncAetherAISetVehicleStatus, new SyncAetherAISetVehicleStatus()
            {
               vehicleInstanceId=randomVehicleGuid,
               status=0
  
            });
            conn.SendPacket(rsp7);
            
        }
        
        [Handler(MethodId.AskSwitchSpiritComplete)]
        public static void AskSwitchSpiritCompleteHandler(Connection conn, UxRpcMessage msg)
        {
           // AskSwitchSpirit args = msg.GetArgs<AskSwitchSpirit>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchSpiritComplete,
            };
            
            conn.SendPacket(rsp);
        }
        [Handler(MethodId.AskVehicleMove)]
        public static void AskVehicleMoveHandle(Connection conn, UxRpcMessage msg)
        {
            RaidVehicleSyncData args = msg.GetArgs<RaidVehicleSyncData>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleMove,
            };
            rsp.SetArgs(MethodId.SyncVehicleMove, args);
            conn.SendPacket(rsp);
        }
        [Handler(MethodId.AskSwitchSpirit)]
        public static void AskSwitchSpiritHandler(Connection conn, UxRpcMessage msg)
        {
            AskSwitchSpirit args = msg.GetArgs<AskSwitchSpirit>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchSpirit,
            };


            UxRpcMessage rsp2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSwitchSpiritConfigId,
                Args=BitConverter.GetBytes(args.spiritId)
            };

            conn.SendPacket(rsp2);

           
            UxRpcMessage rsp4 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveManagedSpirit
            };
            rsp4.SetArgs(MethodId.SyncRemoveManagedSpirit, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId = 0

            });
            conn.SendPacket(rsp4);
            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit
            };

            conn.currentSpirit = args.spiritId;
            rsp7.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            {
                pid = conn.Pid,
                spiritId = conn.GetCurrentSpirit().Id,
                templateId = conn.GetCurrentSpirit().TemplateId,
                isAgentSwitch=true
            });
            conn.SendPacket(rsp7);


            UxRpcMessage rsp8 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedSpirit
            };
            rsp8.SetArgs(MethodId.SyncManagedSpirit, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId = 0

            });
            conn.SendPacket(rsp8);

            conn.SendPacket(rsp);
            UxRpcMessage rsp9 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedAgent
            };
            rsp9.SetArgs(MethodId.SyncManagedAgent, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId = 0

            });
            conn.SendPacket(rsp9);

        }

        [Handler(MethodId.AskSwitchWeapon)]
        public static void AskSwitchWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            AskSwitchWeapon args = msg.GetArgs<AskSwitchWeapon>();
            
            conn.SyncWeapon(args.index);
        }
    }
}
