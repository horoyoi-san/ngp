using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using static AnantaTestGameServer.Methods.Return.SyncPlayerCurrentTime;
using static AnantaTestGameServer.Methods.RPCMethodArgsRequestCreateRoleEx;
using static AnantaTestGameServer.Packets.Req.ClientToGameserver.AskAllSpiritPanelData;

namespace AnantaTestGameServer.Methods.Return
{
    public class PlayerClientInfo : SerializedClass
    {
        public byte[] Config;
        public PlayerClientInfoLogin InfoLogin;
        public PlayerClientInfoItem InfoItem;

        public PlayerClientInfoSpirit InfoSpirit;
        
        public PlayerClientInfoMinor InfoMinor;
        public PlayerClientInfoAchievement InfoAchievement;

    }
    public class SyncVehicleDatas : SerializedClass
    {
        public List<ClientVehicleData> vehicleDatas;

        public SyncVehicleDatas()
        {
            onlyFields = true;
        }
    }
    public class ClientVehicleData : SerializedClass
    {
        // Fields
        public int Id;
        public UXVector3 Position;
        public int ActionId;
        public int LaneHandle;
        public float DistanceAlongLane;
        public int NextLaneHandle;
    }
    public class SyncManagedSpirit : SerializedClass
    {
        public ulong pid;
        public ulong id;
        public int moveId;

        public SyncManagedSpirit()
        {
            onlyFields = true;
        }
    }
    public class SyncSwitchControl : SerializedClass
    {
        public ulong spiritId;
        public ulong agentEntityId;
        public bool enterOrLeave;
        public SwitchControlReason reason;

        public SyncSwitchControl()
        {
            onlyFields = true;
        }
        public enum SwitchControlReason
        {
            None = 0,
            Skill = 1,
            Client = 2,
            ClientWithdraw = 3,
            ClientSwitch = 4,
            System = 5,
            Desinger = 6,
            DesignerLoading = 7,
            Distance = 8,
            Death = 9
        }
    }
    public class SyncPlayerWeather : SerializedClass
    {
        public uint weatherTypeId;
        public uint nextWeatherTypeId;
        public uint transitionSecond;

        public SyncPlayerWeather()
        {
            onlyFields = true;
        }
    }
    public class PlayerClientInfoSpirit : SerializedClass
    {
        public List<SpiritInfo> Spirits;
        public PlayerInfoPokemon InfoPokemon;
        public List<uint> AvailableSkinParts;
        public PlayerInfoArmory InfoArmory;
        public uint ActiveSpirit;
        public Dictionary<uint, DisableBadgeInfo> DisableBadgeInfoDict;
        public PlayerInfoFightStyle InfoFightStyle;
        public uint CommonSpiritTalentExp;
    }
    public class PlayerInfoFightStyle : SerializedClass
    {
      
        public Dictionary<uint, bool> FightStyleIsUnLocked;

    }
    public class DisableBadgeInfo : SerializedClass
    {
       
        public Dictionary<uint, int> BadgeId2CountDict;

    }
    public class SpiritInfo : SerializedClass
    {
        public ulong Id;
        public uint TemplateId;
        public uint PossessTime;
        public float HpRate;
        public SpiritUrbanSkill SpiritUrbanSkill;
        public Dictionary<uint, SpiritAbilityInfo> SpiritAbilities;
        public SpiritJobInfo SpiritJobInfo;
        public Dictionary<uint, float> PermanentAddAttributes;
        public PlayerInfoBadge InfoBadge;
        public SpiritMobileSkinInfo MobileSkinInfo;
        public List<WeaponData> WeaponSlots;
        public bool EverSwitched;
        public uint CurrentJobId;
        public SpiritBattleInfo SpiritBattleInfo;
        public SpiritTalentInfo TalentInfo;
        public SpiritFightStyleInfo SpiritFightStyle;
        public bool Blocked;
        public class SpiritPanelData : SerializedClass
        {
            public uint FightSpiritId;
            public Dictionary<uint, float> UrbanAttrs;
            public float MaxHp;
            public float Dam;
            public float DefDeduct;
        }
        public SpiritPanelData ToSpiritPanelData()
        {
            return new()
            {
                FightSpiritId=TemplateId,
                Dam=10,
                MaxHp=100,
                DefDeduct=10,
                UrbanAttrs = new()
                {
                    {1,10 },
                    {2,10 },
                    {3,10 },
                    {4,10 },
                    {5,10 },
                    {6,10 }
                }
            };
        }
    }
    public class SpiritBattleInfo : SerializedClass
    {
        public bool IsUniqueSkillLocked;

    }
    public class SpiritFightStyleInfo : SerializedClass
    {
     
        public Dictionary<uint, uint> FightStyleInfo;

    }
    public class SpiritTalentInfo : SerializedClass
    {
      
        
        public uint Exp;

        public uint Level;
        public uint TalentPoint;

        public Dictionary<uint, SpiritOrJobTalentNodeInfo> UnlockTalentInfoDict;

        public uint SpentTalentPoint;
    }
    public class SpiritMobileSkinInfo : SerializedClass
    {
        // Fields
        public uint Wallpaper;
      
        public uint Decoration;
     
        public uint Pendant;

    }
    public class PlayerInfoBadge : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, BadgeInfo> Badges;
    
        public Dictionary<uint, BadgeInfo> HistoryBadges;

    }

    public class SpiritJobInfo : SerializedClass
    {
        
        public uint CurrentJob;
        public Dictionary<uint, SpiritJob> AvailableJobs;
        public Dictionary<uint, SpiritJob> HistoryJobs;

    }
    public class SpiritJob : SerializedClass
    {
        // Fields
     
        public uint Job;
      
        public uint Exp;
       
        public byte Level;
    
        public uint RegisterTime;
       
        public uint UnregisterTime;
        
        public SpiritJobTalentInfo TalentInfo;

    }
    public class SpiritJobTalentInfo : SerializedClass
    {
        // Fields
      
        public uint TalentPoint;
      
        public Dictionary<uint, SpiritOrJobTalentNodeInfo> UnlockTalentInfoDict=new();
        
        public uint SpentTalentPoint;

    }
    public class SpiritOrJobTalentNodeInfo : SerializedClass
    {
        // Fields

        public uint TalentId;
      
        public uint Layer;

    }
    public class SpiritUrbanSkill : SerializedClass
    {
       
        public List<int> UrbanAbilities;

    }
    public class SpiritAbilityInfo : SerializedClass
    {
        // Fields
        
        public uint TemplateId;
      
        public uint Exp;
     
        public bool NewLevel;
     
        public uint ConfirmedLevel;
      
        public uint Level;
      
        public List<uint> BuffList;
        
        public List<uint> AbilityBuffConfigIdList;
    }
    public class PlayerInfoArmory : SerializedClass
    {
        // Fields
      
        public List<WeaponData> Weapons;

    }
    public class WeaponDataFlags : SerializedClass
    {
        // Fields
     
        public bool IsTaskWheelWeapon;
    
        public bool ShowRedDot;
       
        public List<int> AdditionalEffectIds;

    }
    public class WeaponDetail : SerializedClass // TypeDefIndex: 29115
    {
        
        public int MagazineAmmo;
      
        public int SourceAgentSpoonId;
     
        public ulong SourceAgentId;
       
        public ulong SourceSceneItemId;

        public uint TemplateId;

        public int Durability;

        public ulong InstanceId;

        public uint EventId;

        public double ReceivedTimeStamp;

        public uint OperatorFlags;

        public string SpecialLabel;

        public WeaponDataFlags WeaponFlags;

        public float SceneItemHp;

        // Constructors
        public WeaponDetail()
        {
            CustomFlagType = 2;
        }
    }
    public class SyncPlayerAllSkillChargeData : SerializedClass
    {

        public ulong spiritId;
        public Dictionary<uint, ChargeData> allChargeDatas;

        public SyncPlayerAllSkillChargeData()
        {
            onlyFields = true;
        }
    }
    public class ChargeData : SerializedClass
    {
        public uint CurrentCharges;
        public float CurrentPercentage;
        public float ChargePeriod;
        public uint MaxCharges;
        public double Timestamp;
    }
   
    public class SyncAgentCharacter : SerializedClass
    {

        public ulong id;
        public AgentCharacterComponent component;
        public SyncAgentCharacter()
        {
            onlyFields = true;
        }
    }
    public class BuffViewData : SerializedClass
    {
        public uint InstanceId;
        public uint Id;
        public ulong ReleaserId;
        public double ExpireTime;
        public uint Tier;
        public bool Permanent;
        public ulong DestructibleId;
        public BuffViewData()
        {
            onlyFields = true;
        }
    }
    public class SyncUnitBuffList : SerializedClass
    {

        public ulong entityId;
        public List<BuffViewData> buffList;
        public SyncUnitBuffList()
        {
            onlyFields = true;
        }
    }

    public class AskSwitchWeapon : SerializedClass
    {

        public int index;
        public AskSwitchWeapon()
        {
            onlyFields = true;
        }
    }
    public class AgentCharacterComponent : SerializedClass
    {
        public uint Portrait;
    }
    public class SpiritWeaponDetail : SerializedClass
    {
        // Fields
       
        public uint SpiritTid;
      
        public ulong SpiritUid;
      
        public ulong CurrentWeaponUid;
    
        public List<WeaponDetail> WeaponSlots;
      
        public WeaponDetail CurrentTempWeapon;
        
        public WeaponWheelData TempWeaponSlots;

    }
    public class WeaponWheelData : SerializedClass
    {
        // Fields
       
        public uint WheelId;
    
        public uint EventId;
     
       
        public List<WeaponDetail> WeaponSlots;

    }
    public class SyncSpiritUnitUrbanAttrs : SerializedClass
    {
        // Fields
        public ulong entityId;
        public Dictionary<uint, float> urbanAttrsvalues;

        // Constructors
        public SyncSpiritUnitUrbanAttrs()
        {
            onlyFields = true;

        }
    }
    public class SyncUnitStates : SerializedClass
    {
        // Fields
        public ulong id;
        public uint[] states;
        public uint effectFreezeState;
        public SyncUnitStates()
        {
            onlyFields = true;

        }
    }
    public class SyncUnitAttrs : SerializedClass
    {
        // Fields
        public ulong entityId;
        public Dictionary<uint, float> values;

        // Constructors
        public SyncUnitAttrs() {
            onlyFields = true;
        
        } 
    }
    public class SyncChangeSkill : SerializedClass
    {
        // Fields
        public ulong spiritId;
        public uint skill;
        public float duration;

        // Constructors
        public SyncChangeSkill()
        {
            onlyFields = true;

        }
    }
    public class WeaponData : SerializedClass
    {

        // Fields
      
        public uint TemplateId;
      
        public int Durability;
      
        public ulong InstanceId;
        
        public uint EventId;
    
        public double ReceivedTimeStamp;
        
        public uint OperatorFlags;
      
        public string SpecialLabel;
       
        public WeaponDataFlags WeaponFlags;
      
        public float SceneItemHp;

        // Constructors
        public WeaponData() {
            CustomFlagType = 1;
        }
    }
    public class PokemonEnemy : SerializedClass
    {
        // Fields
     
        public ulong Id;
   
        public uint Body;
     
        public uint Camp;
    
        public uint Weapon;
       
        public uint LimboChaId;
      
        public uint AcquireTime;
     
        public bool IsLocked;

    }
    public class PlayerInfoPokemon : SerializedClass
    {

        public List<PokemonEnemy> AllPokemons;
  
        public List<ulong> FastFightSquad;
      
        public List<uint> EnabledBodyIds;
       
        public List<uint> EnabledCampIds;
       
        public List<uint> EnabledWeaponIds;

    }
    public class PlayerClientInfoMinor : SerializedClass
    {
        // Fields
        public long Exp;
        public long Fan;
        public uint Fan12;
        public uint Fan123;
        public int YesterdayFan;
        public uint Level;
        public List<uint> LevelRewards;
        public int Questionnaire;
        public Dictionary<uint, DropLimitInfo> DropLimitCount;
        public ChargeActivityClientInfo ChargeInfo;
        public Dictionary<ulong, MapPin> MapPins;
        public MiniGameData MiniGame;
        public PlayerClientInfoGuide PlayerInfoGuide;
        public PlayerClientInfoNpcCultivation InfoNpcCultivation;
        public PlayerClientInfoNpcProfile InfoNpcProfile;
        public PlayerClientInfoAtmosphereGameplay PlayerInfoAtmosphereGameplay;
        public PlayerFashionsInfo PlayerFashionsInfo;
        public HousesInfo housesInfo;
        public PlayerPhoneInfo PlayerPhoneInfo;
        public Dictionary<EventConditionImplModule, ModuleEventProgressInfo> ModuleEventProgressInfoDict;
        public Dictionary<uint, LoadingTextInfo> LoadingTexts;
        public Dictionary<uint, BadgeInfo> Badges;
        public List<SpiritGroupChatInfo> GroupChats;
        public PlayerVehicleInfo VehicleInfo;
        public PlayerMatchInfo MatchInfo;
        public PlayerInfoPopularity PopularityInfoNew;
        public ComputerUnlockInfo ComputerUnlockInfo;
        public PlayerInteractionActionInfo PlayerInteractionActionInfo;
        public PlayerCityPediaInfos PlayerCityPediaInfos;
        public bool DebugReserveGpuDumps;
        public Dictionary<uint, NpcTimeTableInfo> FavorNpcDailyScheduleInfos;
        public Dictionary<uint, string> PlayerInterActionInfo;
        public PlanningBoardInfo PlanningBoardInfo;
        public MallInfo MallInfo;
        public PlayerBattlePassInfo PlayerBattlePassInfo;
        public PlayerLinkPlanningBoardInfo PlayerLinkPlanningBoardInfo;
        public PlayerGachaInfos PlayerGachaInfos;
        public PlayerClientInspireHubInfo PlayerInspireHubInfo;
    }
    public class PlayerClientInspireHubInfo : SerializedClass
    {
        // Fields
        public Dictionary<uint, int> TodayGamePlayJoinCountDict;

    }
    public class PlayerGachaInfos : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, PlayerGachaPoolInfo> PoolInfos;
      
        public Dictionary<uint, PlayerGachaGroupInfo> GroupInfos;
        
        public Dictionary<uint, PlayerGachaPityInfo> PityInfos;

    }
    public class PlayerGachaPityInfo : SerializedClass
    {
        // Fields
      
        public uint DrawCountSinceLastGrandPrize;
        public uint TotalDrawCount;

    }

    public class PlayerGachaGroupInfo : SerializedClass
    {
        // Fields
      
        public uint TotalDrawCount;
      
        public Dictionary<uint, bool> ClaimedMilestoneCounts;

    }
    public class PlayerGachaPoolInfo : SerializedClass
    {

        public uint DrawCount;
    
        public bool HasWonGrandPrize;
       
        public Dictionary<uint, bool> WonFillerPrizeIds;

    }
    public class PlayerLinkPlanningBoardInfo : SerializedClass
    {
        
        public uint EnableMaxMultiPlayerId;
     
        public bool IsSingleGame;
       
        public List<ItemCountInfo> MultiGamePutInKeyCountInfoList;

    }
    public class ItemCountInfo : SerializedClass
    {
        // Fields
     
        public uint TemplateId;
     
        public uint Count;

    }
    public class PlayerBattlePassInfo : SerializedClass
    {
        // Fields
      
        public uint CurrentBattlePassId;
      
        public uint Level;
       
        public uint Exp;
       
        public Dictionary<uint, RewardClaimState> ClaimedLevelRewards;
      
        public BattlePassType CurrentPassType;
      
        public uint LastWeeklyRefresherTime;
      
        public uint UnClaimedExp;
       
        public Dictionary<uint, ChallengeTaskState> ChallengeTaskStates;

    }
    public enum ChallengeTaskState : byte // TypeDefIndex: 29222
    {
        Claimable = 1,
        Claimed = 2
    }
    public enum RewardClaimState : byte // TypeDefIndex: 29221
    {
        None = 0,
        Free = 1,
        Advanced = 2,
        Legacy = 4
    }
    public enum BattlePassType : byte // TypeDefIndex: 29220
    {
        Free = 0,
        Advanced = 1,
        Legacy = 2
    }
    public class MallCommodityInfo : SerializedClass
    {
        // Fields
     
        public uint BoughtCount;
       
        public uint NextRefreshTime;

    }
    public class PlayerMonthCardInfo : SerializedClass
    {
        public uint LastReceiveTime;
        public uint EndTime;

    }
    public class MallInfo : SerializedClass
    {
        // Fields
     
        public Dictionary<uint, MallCommodityInfo> CommodityInfoDict;
     
        public PlayerMonthCardInfo MonthCardInfo;
       
        public List<uint> CommoditySpiritDisplayPreferencesList;

    }
    public class PlanningBoardInfo : SerializedClass
    {
        public Dictionary<uint, byte> StepId2OptionIndexDict;

    }
    public class NpcTimeTableInfo : SerializedClass
    {
        // Fields
     
        public NpcScheduleInfo Schedule0;
       
        public NpcScheduleInfo Schedule1;
       
        public NpcScheduleInfo Schedule2;
       
        public NpcScheduleInfo Schedule3;
      
        public NpcScheduleInfo Schedule4;
       
        public int CurrentSpoonAgentId;
      
        public UXVector3 SpoonPosition;

    }
    public class NpcScheduleInfo : SerializedClass
    {
        // Fields
      
        public uint ActivityId;
       
        public int StartDaySecond;
       
        public UXVector3 Position;
     
        public int SpoonAgentId;
      
        public int EndDaySecond;
      
        public uint RaidId;

    }
    public class PlayerCityPediaInfos : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, bool> CityPedia2IsReadDict;
      
        public CreditInfo CreditInfo;

    }
    public class CreditInfo : SerializedClass
    {
        // Fields
       
        public uint Credit;
      
        public uint Level;
       
        public Dictionary<uint, bool> ClaimedLevelRewards;

    }
    public class PlayerInteractionActionInfo : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, PlayerInteractionActionItem> UnlockActionItemDict;
      
        public bool InvitedNotDisturb;

    }
    public class PlayerInteractionActionItem : SerializedClass
    {
        // Fields
     
        public uint CfgId;
      
        public uint UnlockTime;
      
        public bool ShowRedPoint;

    }

    public class ComputerUnlockInfo : SerializedClass
    {
        // Fields
    
        public Dictionary<uint, ComputerEmail> UnlockEmails;
      
        public Dictionary<uint, ComputerFile> UnlockFiles;
      
        public Dictionary<uint, ComputerDetailInfo> ComputerInfos;

    }
    public class ComputerFile : SerializedClass
    {
        // Fields
       
        public uint CfgId;
      
        public uint UnlockTime;
       
        public bool IsRead;

    }
    public class ComputerDetailInfo : SerializedClass
    {
        // Fields
    
        public uint CfgId;
     
        public uint FirstOpenTime;
     
        public List<uint> DeleteFiles;

        public List<uint> DeleteEmails;

    }

    public class ComputerEmail : SerializedClass
    {
        // Fields
    
        public uint CfgId;
      
        public bool IsRead;
        
        public uint UnlockTime;

    }
    public enum EventConditionImplModule : byte // TypeDefIndex: 29185
    {
        Shop = 0,
        ShopCommodity = 1,
        PhoneContact = 2,
        PhoneContactOption = 3,
        SignInOutline = 4,
        ComputerEmail = 5,
        ComputerFile = 6,
        FashionColor = 7,
        Achievement = 8,
        CityPediaFirstClass = 9,
        CityPediaSecondClass = 10,
        CityPedia = 11,
        NpcProfileTarget = 12,
        NpcCultivation = 13,
        UrbanBadge = 14,
        PoliceDispatch = 15,
        ShopCommodityShow = 16,
        NpcChat = 17,
        PlanningBoardOption = 18,
        Bartender = 19,
        BartenderDrinkMenu = 20,
        BartenderElement = 21,
        MallCommodity = 22,
        AwardActivity = 23,
        CompetitionSeasonChallenge = 24,
        CompetitionSeasonGameplay = 25,
        InspireHubGameplay = 26,
        BattlePassTask = 27,
        Party = 28,
        GangBoss = 29,
        TalentTree = 30,
        UrbanAbilityAddition = 31
    }
    public class ModuleEventProgressInfo : SerializedClass
    {
        public Dictionary<uint, ModuleEventProgressInfoBySpirit> ProgressInfoDict;
    }
    public class ModuleEventProgressInfoBySpirit : SerializedClass
    {
        // Fields
        public Dictionary<uint, EventProgressInfo> EventProgressInfoDict;
        public List<uint> FinishedTemplateIdList;

    }
    public class EventProgressInfo : SerializedClass
    {
        // Fields
        public Dictionary<byte, EventProgress> EventProgressDict;

        public uint Value;

    }
    public class EventProgress : SerializedClass
    {
        // Fields
      
        public uint EventId;
    
        public uint Value;
       
        public Dictionary<uint, uint> ProgressDict;

    }
    public class PlayerInfoPopularity : SerializedClass
    {
        public float Popularity;
        public float UnderflowPopularity;
        public int Version;
        public uint NextPopularityUpdateTime;
        public uint NextUnderflowPopularityUpdateTime;
        public List<PopularityData> HistoryPopularityList;
        public uint LastUnderflowPopularitySpeed;
        public List<PopularityWalletRewardData> WalletRewards;
        public uint TotalLeftMoney;
        public List<PopularityDropData> DropList;
        public List<PopularityChangeInfo> ChangeList;
        public float LastDiff;
        public uint LastPopularityUpdateTime;
        public uint NextYesterdayAvgPopularityUpdateTime;
        public float YesterdayAvgPopularity;
        public uint TodayCoinGet;
        public List<PopularityWalletRewardData> PastHoursCoinRewards;

    }
    public class PopularityData : SerializedClass
    {
        public uint Time;
        public float Value;
    }
    public class PopularityWalletRewardData : SerializedClass
    {
        public uint Date;
        public uint Reward;
    }
    public class PopularityDropData : SerializedClass
    {
        public uint Time;
        public uint DropId;
        public uint Count;
    }
    public class PopularityChangeInfo : SerializedClass
    {
        public uint StartTime;
        public float MaxValue;
        public uint MaxTime;
        public uint Duration;
    }
    public class PlayerMatchInfo : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, uint> GameId2LastPlayTime;
       
        public uint LastInviteAllTime;
       
        public List<uint> AvailablePrepareActions;
      
        public bool InWorldBattle;
      
        public LoadingTypeInfo LoadingTypeInfo;
       
        public LinkDeviceLevel DeviceLevel;
      
        public LinkDeviceLevel CurLinkDeviceLevel;

    }
    public enum LinkDeviceLevel // TypeDefIndex: 29139
    {
        Low = 0,
        Medium = 1,
        High = 2
    }
    public class PlayerVehicleInfo : SerializedClass
    {
        // Fields
      
        public List<PlayerVehicleDetail> UnlockedVehicles;
      
        public int RequisitionVehicleCount;
      
        public uint ParkingVehicleId;

    }
    public class PlayerVehicleDetail : SerializedClass
    {
        // Fields
     
        public uint Id;
    
        public List<PlayerVehiclePartInfo> Parts;
      
        public uint UnlockTime;

    }
    public class PlayerVehiclePartInfo : SerializedClass
    {
        
        public uint VehiclePartId;
       
        public uint VehiclePartTag;

    }
    public class SpiritGroupChatInfo : SerializedClass
    {
        // Fields
    
        public uint Id;
      
        public uint CreateTime;

    }
    public class BadgeInfo : SerializedClass
    {
      
        public uint TemplateId;
       
        public bool Active;
        
        public bool DropSend;

    }
    public class LoadingTextInfo : SerializedClass
    {
       
        public uint TemplateId;
      
        public uint LeftTimes;

    }
    public class PlayerPhoneInfo : SerializedClass
    {
        // Fields
       
        public Dictionary<uint, PhoneInfos> SpiritPhoneInfos;

        public List<uint> DownLoadAppIds;

    }
    public class PhoneInfos : SerializedClass
    {
        public List<PhoneContact> ContactList;
       
        public List<PhoneContactGroup> ContactGroupList;
      
        public List<PhoneContactCallRecord> CallRecordList;
     
        public Dictionary<string, uint> ContactOutgoingCallTimesDict;

    }
    public class PhoneContact : SerializedClass
    {
      
        public string Remark;
        
        public string PhoneNumber;

    }
    public class PhoneContactCallRecord : SerializedClass
    {
        public uint CallTime;
       
        public PhoneContactCallType CallType;
       
        public string PhoneNumber;

        // Constructors
        public PhoneContactCallRecord() { }
        public enum PhoneContactCallType // TypeDefIndex: 29179
        {
            Incoming = 0,
            IncomingMissed = 1,
            Outgoing = 2,
            OutgoingMissed = 3,
            Missed = 4
        }
    }
    public class PhoneContactGroup : SerializedClass
    {
        // Fields
   
        public string Name;
       
        public List<string> PhoneNumberList;

    }
    public class HousesInfo : SerializedClass
    {

        public List<HouseInfo> HouseInfoList;
        public List<uint> NotParkingSpaceVehicleIdList;
        public Dictionary<uint, FurnitureInfo> FurnitureInfoDict;

    }
    public class FurnitureInfo : SerializedClass
    {
        // Fields
       
        public uint FurnitureId;
        
        public uint Count;
      
        public uint PlacedCount;

    }
    public class HouseInfo : SerializedClass
    {
        public uint HouseId;
        public Dictionary<int, uint> ParkingSpaceVehicleIdDict;
        public Dictionary<uint, IndoorBuildInfo> FloorBuildInfoDict;
        public ulong CurPlacedFurnitureInstanceId;

    }
    public class PlacedFurnitureInfo : SerializedClass
    {
        public uint FurnitureId;
        public UXVector3 Position;
        public UXVector3 Rotation;
        public ulong GadgetInstanceId;
        public ulong PlacedInstanceId;
        public Dictionary<ulong, PlacedFurnitureInfo> ChildrenDict;
    }
    public class IndoorBuildInfo : SerializedClass
    {
        public PlacedFurnitureInfo Root;
    }
    public class PlayerFashionsInfo : SerializedClass
    {
        public Dictionary<uint, SpiritFashionsInfo> SpiritFashionsInfoDict;
        public Dictionary<uint, FashionInfo> FashionInfoDict;
        public List<uint> FavoriteFashionIdList;

        public List<uint> FavoriteFashionSuitIdList;

        public bool DefaultSpiritIsInitDefaultFashion;

        public Dictionary<uint, TaskTryFashionInfo> SpiritId2TaskTryWearInfoDict;

    }
    public class TaskTryFashionInfo : SerializedClass
    {
        public uint TaskEventId;
        public uint TaskId;
    }
    public class FashionColoringSchemeInfo : SerializedClass
    {
        public Dictionary<byte, uint> ColoringType2ColorIdDict;
    }
    public class FashionInfo : SerializedClass
    {
        public uint FashionId;
        public uint ExpiredTime;
        public uint GainTime;
        public byte Status;
        public byte ApplyColoringSchemeId;
        public Dictionary<byte, FashionColoringSchemeInfo> ColoringSchemeInfoDict;
    }
    public class SpiritFashionsInfo : SerializedClass
    {
      
   
        public uint SpiritId;
        public FashionCustomSuitSchemeInfo[] FashionCustomSuitSchemeInfos;
        public Dictionary<uint, FashionFunctionSuitSchemeInfo> FashionFunctionSuitSchemeInfoDict;
        public SpiritWearFashionsInfo SpiritWearFashionsInfo;
        public SpiritWearFashionsInfo SpiritPrevWearFashionsInfo;
        public List<uint> FirstGainSuitIdList;
       
        public byte EnableClientTryWearCount;
    }
    public class BaseWearFashionsInfo : SerializedClass
    {
        public List<WearFashionInfo> WearFashionInfoList;
        public List<WearFashionEditInfo> WearFashionEditInfoList;
        public byte HiddenParts;
        public byte EditedHiddenParts;
    }
    public class WearFashionEditInfo : SerializedClass
    {
        public uint FashionId;
        public float Scale;
        public UXVector3 Rotation;
        public UXVector3 Offset;
    }
    public class WearFashionInfo : SerializedClass
    {
        public uint FashionId;
    }
    public class SpiritWearFashionsInfo : SerializedClass
    {
        // Fields

        public uint FunctionSuitId;
        public bool IsTryWear;
        public List<WearFashionInfo> WearFashionInfoList;
       
        public List<WearFashionEditInfo> WearFashionEditInfoList;
       
        public byte HiddenParts;
        
        public byte EditedHiddenParts;
    }
    public class FashionFunctionSuitSchemeInfo : SerializedClass
    {
        // Inherits from BaseWearFashionsInfo in dump, no own fields
        // Fields inherited: WearFashionInfoList, WearFashionEditInfoList, HiddenParts, EditedHiddenParts
        public List<WearFashionInfo> WearFashionInfoList;
        public List<WearFashionEditInfo> WearFashionEditInfoList;
        public byte HiddenParts;
        public byte EditedHiddenParts;
    }
    public class FashionCustomSuitSchemeInfo : SerializedClass
    {
        public List<WearFashionInfo> WearFashionInfoList;
        public List<WearFashionEditInfo> WearFashionEditInfoList;
        public byte HiddenParts;
        public byte EditedHiddenParts;
        public string SchemeName;
        public bool JoinRandomPool;
    }
    public class PlayerClientInfoAtmosphereGameplay : SerializedClass
    {
        // Fields
        public int PartTimeJobDailyRewardTimes;
        public List<uint> PartTimeJobUnlockStore;

    }
    public class PlayerClientInfoNpcProfile : SerializedClass
    {
        // Fields
        public Dictionary<uint, TrustNpcInfo> NpcProfiles;
        public List<uint> ProgressRewards;

    }
    public class TrustNpcInfo : SerializedClass
    {
        // Fields
       
        public uint ProfileId;
        
        public uint TrustValue;
      
        public uint ActivateTime;
       
        public List<uint> GotRewardList;
       
        public List<uint> FinishTargetList;
      
        public bool IsNew;
       
        public bool IsMaxTrustReward;
       
        public List<TrustNpcTargetState> TargetStateList;

    }
    public class TrustNpcTargetState : SerializedClass
    {
        // Fields
      
        public uint TargetId;
        public bool IsNew;

    }
    public class PlayerClientInfoNpcCultivation : SerializedClass
    {
        // Fields
        public List<NpcCardInfo> NpcCardInfos ;
        public List<NpcCardInfo> LockedCardInfos ;
        public List<ClientNpcChatData> NpcChats ;
        public List<ClientNpcGroupChatData> NpcGroupChats ;
        public uint AvailableGiftSendCount = 0;
        public uint InteractPoint = 0;
        public NpcEventQueueList NpcEventQueueList ;

    }
    public class ClientNpcGroupChatData : SerializedClass
    {
        // Fields
        public uint TemplateId;
        public List<NpcChatItem> InviteChatList ;
        public List<NpcChatItem> DialogChatList ;
        public uint[] Members;
        public Dictionary<uint, ChatInfoList> NpcChatListDict ;
        public Dictionary<uint, ChatInfoList> DialogChatListDict ;

    }
    public class NpcEventQueueList : SerializedClass
    {

        public Dictionary<uint, NpcEventQueue> NpcQueues;
       
        public uint TodayTriggeredCount;
       
        public Dictionary<uint, EventIdInfo> IdToNpcDict ;
      
        public uint LastTriggerTime;

    }
    public class NpcEventQueue : SerializedClass
    {

        public uint TodayTriggeredCount;
    
        public List<uint> EventIds;

    }
    public class EventIdInfo : SerializedClass
    {

        public uint Id;
 
        public uint NpcId;
     
        public NpcQueueEventType EventType;

    }
    public enum NpcQueueEventType // TypeDefIndex: 29146
    {
        None = 0,
        NpcChat = 1,
        Phone = 2
    }
    public class ClientNpcChatData : SerializedClass
    {
        // Fields
        public uint TemplateId;
        public List<NpcChatItem> InviteChatList ;
        public List<NpcChatItem> DialogChatList ;
        public Dictionary<uint, ChatInfoList> NpcChatListDict ;
        public Dictionary<uint, ChatInfoList> DialogChatListDict ;

    }
    public class ChatInfoList : SerializedClass
    {
        public List<NpcChatItem> ChatList ;

    }
    public class NpcChatItem : SerializedClass
    {
      
        public uint Timestamp;
       
        public uint ChatId;
        
        public uint NextChatId;
       
        public NpcChatContext ChatContext ;
      
        public bool IsRead;
      
        public uint BelongNpc;

    }
    public class NpcChatContext : SerializedClass
    {
        public uint BubbleId;
        public uint AcquireCfgId;
        public List<EmojiData> EmojiList ;
        public string Url;
        public uint ActivityCfgId;

    }
    public class EmojiData : SerializedClass
    {

        public string Id;
        public uint Count;

    }
    public class NpcCardInfo // TypeDefIndex: 29108
    {
        public uint TemplateId;
        public List<uint> UnlockedVoice;
   
        public uint ActivateTimestamp;
 
        public double Favor;

        public uint InteractDays;
   
        public uint LastInteractTime;

        public List<uint> GroupNpcPhotoPosList;

        public List<uint> SingleNpcPhotoPosList;

        public List<uint> TodayChatPosList;

        public List<uint> FirstChatPosList;

        public uint PreferCfgId;

        public bool AcquireDropReward;
 
        public List<uint> ActiveGiftTags;
  
        public double MaxFavorInHistory;
 
        public uint TodayFavorDialogCount;
  
        public List<uint> InteractedStories;
  
        public bool HasUninteractedNpcVoice;
    
        public List<uint> InteractedVoices;
     
        public int FavorLevelReward;

        public bool HasNoInteractedStory;
 

        public Dictionary<uint, uint> UnlockedStoryDict;
    }
    public class PlayerClientInfoGuide : SerializedClass
    {
        public List<uint> FinishedGuides;
        public List<uint> NewGuideTeachInfos;
        public List<uint> RewardedGuideTeachInfos;
        public List<uint> UnlockSystems;
        public List<ushort> TaskTitleGuideUnlockList;
    }
    public class MiniGameData : SerializedClass
    {
        public List<uint> MiniGame_Bee;

    }
    public class MapPin : SerializedClass
    {
        public uint RaidId;

        public UXVector3 Position;

        public byte Type;
    }
    public class ChargeActivityClientInfo : SerializedClass
    {
        // Fields
        public bool HasFirstCharge;
        public bool HasFirstChargeReward;

    }

    public class DropLimitInfo : SerializedClass
    {
        public uint Count;
        public uint FinishTime;
    }
    public class PlayerClientInfoAchievement : SerializedClass
    {
        public Dictionary<uint, SceneFogMap> SceneFogMaps;
        public List<uint> SceneFogMapPoiIds;
        public List<uint> UnlockedCountryList;
        public List<uint> UnlockedQuestList;
        public Dictionary<uint, uint> CompletedSubQuestCnt;
        public Dictionary<uint, ChallengeRecord> ChallengeRecordInfo;
        public Dictionary<uint, NewChallengeRecord> NewChallengeRecordInfo;
        public List<int> FirstKillEnemyRecord;
        public List<uint> UnlockInvestigateGalleryList;
        public int InvestigateGalleryRedCnt;
        public Dictionary<uint, uint> CountryReputationInfo;
        public Dictionary<uint, FactionInfo> FactionInfoDic;
        public List<uint> OccupiedInfluenceArea;
    }
    public class ChallengeRecord : SerializedClass
    {
        public uint ChallengeId;
        public uint HighestLevel;
        public uint ReceivedRewardLevel;
        public int BestScore;
        public int CurrentScore;
        public uint CurrentRewardLevel;
        public bool CurrentIsNewRewardLevel;
        public Dictionary<int, double> BestStatisticalData;
        public Dictionary<int, double> CurrentStatisticalData;
    }
    public class NewChallengeRecord : SerializedClass
    {
        public uint ChallengeId;
        public uint HighestLevel;
        public uint ReceivedRewardLevel;
        public bool CurrentIsNewRewardLevel;
        public float BestScore;
        public Dictionary<uint, bool> ParamData;
    }
    public class NewClientBoardingInfo : SerializedClass
    {
        // Fields
        public ulong EntityId;
        public BoardingStatus Status;
        public ulong VehicleUId;
        public byte SeatIndex;

        // Constructors
        public NewClientBoardingInfo() { }

        public enum BoardingStatus // TypeDefIndex: 28854
        {
            NotOnVehicle = 0,
            EnterBoardingMoving = 2,
            EnterBoarding = 3,
            OnVehicle = 4,
            ExitBoarding = 5,
            ShiftingSeat = 6,
            InIndoor = 7
        }
    }
    public class SyncPlayerCurrentSpirit : SerializedClass
    {
        public ulong pid;
        public uint templateId;
        public ulong spiritId;
        public bool isAgentSwitch;

        public SyncPlayerCurrentSpirit()
        {
            onlyFields = true;
        }
    }
    public class FactionInfo : SerializedClass
    {
      
        public int Disposition;
     
        public uint DispositionLevel;
     
        public int Influence;
    
        public uint InteractionCount;
        
        public uint GreetCount;
    }
    public class SceneFogMap : SerializedClass
    {
        // Fields
       
        public byte[] FogValue;
        
        public bool All;
      
        public int LockCnt;
       
        public int XSize;
       
        public int ZSize;
    
        public int TileSize;

    }
    public class PlayerClientInfoLogin : SerializedClass
    {
        // Fields
        public int Aid;
        public ulong Pid;
        public string AccountId;
        public string Name;
        public uint Level;
        public SexType Sex;
        public PersonalZoneHeadInfo PzHeadInfo ;
    }
    public class PlayerClientInfoItem : SerializedClass
    {
        // Fields
        public uint Money;
        public uint Gold;
        public uint BindingGold;
        public int FreeGold;
        public List<PlayerItemDayCount> ItemDayCounts ;
        public List<PlayerPackItem> PackItems ;
        public Dictionary<ItemShortcutType, ItemShortcutInfo> ItemShortcutDic;
        public uint DestructibleShortcut;
        public uint TodayGachaCount;
        public Dictionary<uint, int> GachaPoolCount;
        public List<ItemCountLimitInfo> ItemCountLimitInfoList ;
        public uint QuantumWalletStartTime;
        public UXVector3 PortalPosition ;
        public uint PortalRaidId;
    }
    public class ItemShortcutInfo : SerializedClass
    {
        public ulong UniqueId;
        public uint TemplateId;
    }
    public enum ItemShortcutType // TypeDefIndex: 29095
    {
        None = 0,
        Resurrection = 1,
        Wheel1 = 2,
        Wheel2 = 3,
        Wheel3 = 4,
        Wheel4 = 5,
        Wheel5 = 6
    }
    public class ItemCountLimitInfo : SerializedClass
    {
        public uint ItemId;
        public uint Count;
        public uint NextRefreshTime;
    }
    public class PlayerPackItem : SerializedClass
    {
        // Fields
        public ulong UniqueId;
        public uint TemplateId;
        public uint Count;
        public bool IsNew;
        public uint ExpiryTime;
        public RemindState RemindState;
        public uint CDFinishTime;

    }
    public enum RemindState // TypeDefIndex: 28552
    {
        Normal = 0,
        Expiring = 1,
        Expired = 2
    }
    public class PlayerItemDayCount : SerializedClass
    {
        public uint TemplateId;
        public uint Count;
    }

    public class PersonalZoneHeadInfo : SerializedClass
    {
        public PersonalZoneHeadType HeadType; 
        public uint SystemHeadId;
        public enum PersonalZoneHeadType : byte // TypeDefIndex: 28632
        {
            System = 0
        }
    }
    public enum SystemUnlock : uint
    {
        FeiSuoUnlock = 1,              // Metadata: 0x025D71D7
        BattleEUnlock = 2,             // Metadata: 0x025D71D8
        BattleRUnlock = 3,             // Metadata: 0x025D71D9
        MindPowerUnlock = 4,           // Metadata: 0x025D71DA
        ScanUnlock = 5,                // Metadata: 0x025D71DB
        EatFoodUnlock = 6,             // Metadata: 0x025D71DC
        GetOffCar = 7,                 // Metadata: 0x025D71DD
        CarRadio = 8,                  // Metadata: 0x025D71DE
        ClimbJumpUnlock = 9,           // Metadata: 0x025D71DF
        TowerWeakGuideUnlock = 10,     // Metadata: 0x025D71E0
        BattleNormalUnlock = 12,       // Metadata: 0x025D71E1
        TaFeiBattleUnlock = 13,        // Metadata: 0x025D71E2
        BaBa = 14,                     // Metadata: 0x025D71E3
        Jump = 15,                     // Metadata: 0x025D71E4
        Dodge = 17,                    // Metadata: 0x025D71E5
        Swing = 18,                    // Metadata: 0x025D71E6
        EnemyHp = 19,                  // Metadata: 0x025D71E7
        EnemyDisarmBar = 20,           // Metadata: 0x025D71E8
        Drop = 22,                     // Metadata: 0x025D71E9
        BossHp = 23,                   // Metadata: 0x025D71EA
        AirCrush = 24,                 // Metadata: 0x025D71EB
        AirJump = 25,                  // Metadata: 0x025D71EC
        WeaponWheel = 26,              // Metadata: 0x025D71ED
        BlockState = 27,               // Metadata: 0x025D71EE
        UltDot = 28,                   // Metadata: 0x025D71EF
        CarView = 29,                  // Metadata: 0x025D71F0
        TafeiMoto = 30,                // Metadata: 0x025D71F1
        CharEnergyBar = 31,            // Metadata: 0x025D71F2

        ScheduleUnlock = 101,          // Metadata: 0x025D71F3
        GachaUnlock = 102,             // Metadata: 0x025D71F4
        FogMap = 103,                  // Metadata: 0x025D71F5
        InvestigatorUnlock = 105,      // Metadata: 0x025D71F6
        ShopUnlock = 106,              // Metadata: 0x025D71F7
        LinkUnlock = 107,              // Metadata: 0x025D71F8
        DiDi = 108,                    // Metadata: 0x025D71F9
        Cassette = 109,                // Metadata: 0x025D71FA
        Taxi = 110,                    // Metadata: 0x025D71FB
        FoodDeliver = 111,             // Metadata: 0x025D71FC
        StoneUnlock = 112,             // Metadata: 0x025D71FD
        WeaponUnlock = 113,            // Metadata: 0x025D71FE
        TalentUnlock = 114,            // Metadata: 0x025D71FF
        TuiteUnlock = 115,             // Metadata: 0x025D7200
        HouseUnlock = 116,             // Metadata: 0x025D7201
        MilkVehicle = 117,             // Metadata: 0x025D7202
        TaskGuideUnlock = 118,         // Metadata: 0x025D7203
        AchievementUnlock = 119,       // Metadata: 0x025D7204
        PhotoUnlock = 120,             // Metadata: 0x025D7205
        MailUnlock = 121,              // Metadata: 0x025D7206
        MiniMapUnlock = 122,           // Metadata: 0x025D7207
        BigMapUnlock = 123,            // Metadata: 0x025D7208
        TeachUnlock = 124,             // Metadata: 0x025D7209
        MainPanelUnlock = 125,         // Metadata: 0x025D720A
        TaskUnlock = 126,              // Metadata: 0x025D720B
        MovieUnlock = 127,             // Metadata: 0x025D720C
        PackageUnlock = 128,           // Metadata: 0x025D720D
        BaikeUnlock = 129,             // Metadata: 0x025D720F
        ChangeTimeUnlock = 130,        // Metadata: 0x025D7211
        PackageMaterialsTabUnlock = 131,// Metadata: 0x025D7213
        FashionChangeUnlock = 132,     // Metadata: 0x025D7215
        FashionShopUnlock = 133,       // Metadata: 0x025D7217
        CallVehicleUnlock = 134,       // Metadata: 0x025D7219
        AcquisitionLKYUnlock = 135,    // Metadata: 0x025D721B
        AcquisitionLQUnlock = 136,     // Metadata: 0x025D721D
        AcquisitionANMUnlock = 137,    // Metadata: 0x025D721F
        HUDPlayerMotionEntrance = 138, // Metadata: 0x025D7221
        Favorability = 139,            // Metadata: 0x025D7223
        FactionDisposition = 140,      // Metadata: 0x025D7225
        FactionInfluence = 141,        // Metadata: 0x025D7227
        FansDisplayUnlock = 142,       // Metadata: 0x025D7229
        FactionMap = 143,              // Metadata: 0x025D722B
        FactionInfluenceMap = 144,     // Metadata: 0x025D722D
        CharacterGallery = 145,        // Metadata: 0x025D722F
        Message = 146,                 // Metadata: 0x025D7231
        Friend = 147,                  // Metadata: 0x025D7233
        Badge = 148,                   // Metadata: 0x025D7235
        AwardActivity = 149,           // Metadata: 0x025D7237
        TalentTree = 150,              // Metadata: 0x025D7239
        FightSkill = 151,              // Metadata: 0x025D723B
        InspireHub = 152,              // Metadata: 0x025D723D
        Waper = 153,                   // Metadata: 0x025D723F
        FeedbackUnlock = 154,          // Metadata: 0x025D7241
        UrbanAbilityAddition = 155,    // Metadata: 0x025D7243

        WildBossUnlock = 202,          // Metadata: 0x025D7243
        SmallWildEnemyUnlock = 203,    // Metadata: 0x025D7245
        JieAoEntranceUnlock = 204,     // Metadata: 0x025D7247
        MapSituationEvent = 205,       // Metadata: 0x025D7249
        MapRandomEvent = 206,          // Metadata: 0x025D724B
        SeasonRaid = 207,              // Metadata: 0x025D724D
        LiwangBossUnlock = 208,        // Metadata: 0x025D724F
        KesiBossUnlock = 209,          // Metadata: 0x025D7251
        JieaoBossUnlock = 210,         // Metadata: 0x025D7253
        CailiaoRaidUnlockA = 211,      // Metadata: 0x025D7255
        CailiaoRaidUnlockB = 212,      // Metadata: 0x025D7257
        CailiaoRaidUnlockC = 213,      // Metadata: 0x025D7259
        CailiaoRaidUnlockD = 214,      // Metadata: 0x025D725B
        MiTuRaidUnlock = 215,          // Metadata: 0x025D725D
        LiveHouseGame = 216,           // Metadata: 0x025D725F
        PhoneUnlock = 217,             // Metadata: 0x025D7261
        ShouceJueseUnlock = 218,       // Metadata: 0x025D7263
        MidWildEnemyUnlock = 219,      // Metadata: 0x025D7265
        BigWildEnemyUnlock = 220,      // Metadata: 0x025D7267
        MajhongGame = 222,             // Metadata: 0x025D7269
        FerrisWheelUnlock = 223,       // Metadata: 0x025D726B
        PetAnimalUnlock = 224,         // Metadata: 0x025D726D
        Restaurant = 225,              // Metadata: 0x025D726F
        Gym = 226,                     // Metadata: 0x025D7271
        MiniGame = 227,                // Metadata: 0x025D7273
        ClawMachine = 228,             // Metadata: 0x025D7275
        Bengdi = 229,                  // Metadata: 0x025D7277
        BubbleUnlock = 231,            // Metadata: 0x025D7279
        SwitchSpiritWheel = 232,       // Metadata: 0x025D727B

        Police = 303,                  // Metadata: 0x025D727D
        PoliceMission = 30301,         // Metadata: 0x025D727F
        PoliceApp = 30302,             // Metadata: 0x025D7281
        PoliceFake = 30303,            // Metadata: 0x025D7285
        PoliceTalent = 30304,          // Metadata: 0x025D7289
        PoliceShiftStart = 30305,      // Metadata: 0x025D728D

        Hacker = 304,                  // Metadata: 0x025D7291
        Truck = 305,                   // Metadata: 0x025D7295
        ChaosTruck = 306,              // Metadata: 0x025D7297
        Diviner = 307,                 // Metadata: 0x025D7299
        ChaosMaster = 308,             // Metadata: 0x025D729B

        TruckActivity = 311,           // Metadata: 0x025D729D
        Washer = 312,                  // Metadata: 0x025D729F
        DeliveryGuideId = 313,         // Metadata: 0x025D72A1
        ChaosMasterApp = 314,          // Metadata: 0x025D72A3
        ChaosMasterModifySystem = 315, // Metadata: 0x025D72A5
        ChaosMasterModifyBody = 316,   // Metadata: 0x025D72A7
        ChaosMasterModifyWeapon = 317, // Metadata: 0x025D72A9
        ChaosMasterModifyCamp = 318,   // Metadata: 0x025D72AB
        Bartender = 319,               // Metadata: 0x025D72AD
        PoliceArchive = 320,           // Metadata: 0x025D72AF
        BattleTowerEnter = 321,        // Metadata: 0x025D72B1
        BattlePass = 322,              // Metadata: 0x025D72B3
        BattleTraining = 323,          // Metadata: 0x025D72B5
        MallPanel = 324,               // Metadata: 0x025D72B7
        MallFeaturedPage = 325,        // Metadata: 0x025D72B9
        MallSkinSalePage = 326,        // Metadata: 0x025D72BB
        MallMonthlyCardPage = 327,     // Metadata: 0x025D72BD
        MallExclusiveSalePage = 328,   // Metadata: 0x025D72BF
        MallRechargePage = 329,        // Metadata: 0x025D72C1
        InventorGameplay = 330,        // Metadata: 0x025D72C3
        WeakPercent = 331,             // Metadata: 0x025D72C5
        Survey = 332                   // Metadata: 0x025D72C7
    }

    public class SpiritSwitchWeaponAction : SerializedClass
    {
        // Fields
        public ulong SpiritUid;
  
        public ulong WeaponInstanceId;
        public SwitchWeaponReason Reason;

        public enum SwitchWeaponReason // TypeDefIndex: 28569
        {
            Init = 0,
            Designer = 1,
            DesignerChangeWeaponSkill = 2,
            Roulette = 3,
            Armory = 4,
            Disarm = 5,
            PickUp = 6,
            Shop = 7,
            Discard = 8,
            DurabilityDestroy = 9,
            Throw = 10,
            DropAction = 11,
            GM = 12,
            Spoon = 13,
            Remove = 14,
            Lock = 15,
            Unlock = 16,
            Area = 17,
            SwitchAgent = 18,
            Exchange = 19,
            Job = 20
        }
    }

    public class SyncAetherAISetVehicleStatus : SerializedClass
    {
        // Fields
        public ulong vehicleInstanceId;
        public ClientVehicleStatus status;
        public SyncAetherAISetVehicleStatus()
        {
            onlyFields = true;
        }
        public enum ClientVehicleStatus : byte // TypeDefIndex: 28897
        {
            Normal = 0,
            Standby = 1
        }
    }
    public class RaidVehicleSyncData : SerializedClass
    {
        // Fields — core position/orientation (SectorPositionDataNode + EntityOrientationDataNode)
        public ulong Id;
        public UXVector3 Position;
        public float facingDirection;

        // Velocity (PhysicalVelocityDataNode)
        public UXVector3 Velocity;

        // Angular velocity (PhysicalAngVelocityDataNode + VehicleAngVelocityDataNode)
        public UXVector3 AngularVelocity;
        public bool IsSuperDummyAngVel;

        // Steering (VehicleSteeringDataNode)
        public float SteeringAngle;

        // Controls (VehicleControlDataNode)
        public float Throttle;
        public float BrakeInput;
        public float HandbrakeInput;
        public bool Reverse;

        // Legacy bit buffer (kept for backward compatibility with raw byte sync)
        public byte[] Bits;


    }

    public class SyncShieldOn : SerializedClass
    {
        public ulong unitId;
        public SyncShieldOn() { onlyFields = true; }
    }

    public class SyncShieldOff : SerializedClass
    {
        public ulong unitId;
        public SyncShieldOff() { onlyFields = true; }
    }

    public class AskSkillExecuteArgsFull : SerializedClass
    {
        public uint skillId;
        public ulong targetId;
        public UXVector3 targetPosition;
        public AskSkillExecuteArgsFull() { onlyFields = true; }
    }

    public class SyncSwitchSceneFailed : SerializedClass
    {
        public uint raidId;
        public uint errorId;
        public SyncSwitchSceneFailed() { onlyFields = true; }
    }

    public class SyncPrepareSwitchSceneTimeline : SerializedClass
    {
        public bool withoutDefaultTimeline;
        public string replaceTimelineName;
        public SyncPrepareSwitchSceneTimeline() { onlyFields = true; }
    }

    public class SyncSpiritAbilities : SerializedClass
    {
        public ulong id;
        public Dictionary<uint, SpiritAbilityInfo> abilities;
        public SyncSpiritAbilities() { onlyFields = true; }
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

    public class AskEnemyInteractionArgs : SerializedClass
    {
        public ulong enemyId;
        public uint interactionType;
        public AskEnemyInteractionArgs() { onlyFields = true; }
    }

    public class SyncEnemyHp : SerializedClass
    {
        public ulong unitId;
        public float hp;
        public SyncEnemyHp() { onlyFields = true; }
    }
}
