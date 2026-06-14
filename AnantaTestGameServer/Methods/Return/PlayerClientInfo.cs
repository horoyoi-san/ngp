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
        public byte[] Config; // 0x10
        public PlayerClientInfoLogin InfoLogin; // 0x18
        public PlayerClientInfoItem InfoItem; // 0x20

        public PlayerClientInfoSpirit InfoSpirit; // 0x28
        
        public PlayerClientInfoMinor InfoMinor; // 0x30
        public PlayerClientInfoAchievement InfoAchievement; // 0x38


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
        public int Id; // 0x10
        public UXVector3 Position; // 0x14
        public int ActionId; // 0x20
        public int LaneHandle; // 0x24
        public float DistanceAlongLane; // 0x28
        public int NextLaneHandle; // 0x2C
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
        public List<SpiritInfo> Spirits; // 0x10
        public PlayerInfoPokemon InfoPokemon; // 0x18
        public List<uint> AvailableSkinParts; // 0x20
        public PlayerInfoArmory InfoArmory; // 0x28
        public uint ActiveSpirit; // 0x30
        public Dictionary<uint, DisableBadgeInfo> DisableBadgeInfoDict; // 0x38
        public PlayerInfoFightStyle InfoFightStyle; // 0x40
        public uint CommonSpiritTalentExp; // 0x48
    }
    public class PlayerInfoFightStyle : SerializedClass
    {
      
        public Dictionary<uint, bool> FightStyleIsUnLocked; // 0x10

        // Constructors
        public PlayerInfoFightStyle() { } // 0x000000018C3B1930-0x000000018C3B1960
    }
    public class DisableBadgeInfo : SerializedClass
    {
       
        public Dictionary<uint, int> BadgeId2CountDict; // 0x10

        // Constructors
        public DisableBadgeInfo() { } // 0x000000018C3ADFD0-0x000000018C3AE000
    }
    public class SpiritInfo : SerializedClass
    {
        public ulong Id; // 0x10
        public uint TemplateId; // 0x18
        public uint PossessTime; // 0x1C
        public float HpRate; // 0x20
        public SpiritUrbanSkill SpiritUrbanSkill; // 0x28
        public Dictionary<uint, SpiritAbilityInfo> SpiritAbilities; // 0x30
        public SpiritJobInfo SpiritJobInfo; // 0x38
        public Dictionary<uint, float> PermanentAddAttributes; // 0x40
        public PlayerInfoBadge InfoBadge; // 0x48
        public SpiritMobileSkinInfo MobileSkinInfo; // 0x50
        public List<WeaponData> WeaponSlots; // 0x58
        public bool EverSwitched; // 0x60
        public uint CurrentJobId; // 0x64
        public SpiritBattleInfo SpiritBattleInfo; // 0x68
        public SpiritTalentInfo TalentInfo; // 0x70
        public SpiritFightStyleInfo SpiritFightStyle; // 0x78
        public bool Blocked; // 0x80
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
        public bool IsUniqueSkillLocked; // 0x10

        // Constructors
        public SpiritBattleInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class SpiritFightStyleInfo : SerializedClass
    {
     
        public Dictionary<uint, uint> FightStyleInfo; // 0x10

    }
    public class SpiritTalentInfo : SerializedClass
    {
      
        
        public uint Exp; // 0x28

        public uint Level; // 0x2C
        public uint TalentPoint; // 0x10

        public Dictionary<uint, SpiritOrJobTalentNodeInfo> UnlockTalentInfoDict; // 0x18

        public uint SpentTalentPoint; // 0x20
        // Constructors
        public SpiritTalentInfo() { } // 0x000000018C3B14C0-0x000000018C3B1510
    }
    public class SpiritMobileSkinInfo : SerializedClass
    {
        // Fields
        public uint Wallpaper; // 0x10
      
        public uint Decoration; // 0x14
     
        public uint Pendant; // 0x18

        // Constructors
        public SpiritMobileSkinInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerInfoBadge : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, BadgeInfo> Badges; // 0x10
    
        public Dictionary<uint, BadgeInfo> HistoryBadges; // 0x18

        // Constructors
        public PlayerInfoBadge() { } // 0x000000018C3B1370-0x000000018C3B13E0
    }

    public class SpiritJobInfo : SerializedClass
    {
        
        public uint CurrentJob; // 0x10
        public Dictionary<uint, SpiritJob> AvailableJobs; // 0x18
        public Dictionary<uint, SpiritJob> HistoryJobs; // 0x20

        // Constructors
        public SpiritJobInfo() { } // 0x000000018C3B13E0-0x000000018C3B1450
    }
    public class SpiritJob : SerializedClass
    {
        // Fields
     
        public uint Job; // 0x10
      
        public uint Exp; // 0x14
       
        public byte Level; // 0x18
    
        public uint RegisterTime; // 0x1C
       
        public uint UnregisterTime; // 0x20
        
        public SpiritJobTalentInfo TalentInfo; // 0x28

        // Constructors
        public SpiritJob() { } // 0x000000018C3B1450-0x000000018C3B14C0
    }
    public class SpiritJobTalentInfo : SerializedClass
    {
        // Fields
      
        public uint TalentPoint; // 0x10
      
        public Dictionary<uint, SpiritOrJobTalentNodeInfo> UnlockTalentInfoDict=new(); // 0x18
        
        public uint SpentTalentPoint; // 0x20

        // Constructors
        public SpiritJobTalentInfo() { } // 0x000000018C3B14C0-0x000000018C3B1510
    }
    public class SpiritOrJobTalentNodeInfo : SerializedClass
    {
        // Fields

        public uint TalentId; // 0x10
      
        public uint Layer; // 0x14

        // Constructors
        public SpiritOrJobTalentNodeInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class SpiritUrbanSkill : SerializedClass
    {
       
        public List<int> UrbanAbilities; // 0x10

    }
    public class SpiritAbilityInfo : SerializedClass
    {
        // Fields
        
        public uint TemplateId; // 0x10
      
        public uint Exp; // 0x14
     
        public bool NewLevel; // 0x18
     
        public uint ConfirmedLevel; // 0x1C
      
        public uint Level; // 0x20
      
        public List<uint> BuffList; // 0x28
        
        public List<uint> AbilityBuffConfigIdList; // 0x30
    }
    public class PlayerInfoArmory : SerializedClass
    {
        // Fields
      
        public List<WeaponData> Weapons; // 0x10

        // Constructors
        public PlayerInfoArmory() { } // 0x000000018C3B1850-0x000000018C3B1930
    }
    public class WeaponDataFlags : SerializedClass
    {
        // Fields
     
        public bool IsTaskWheelWeapon; // 0x10
    
        public bool ShowRedDot; // 0x11
       
        public List<int> AdditionalEffectIds; // 0x18

        // Constructors
        public WeaponDataFlags() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class WeaponDetail : SerializedClass // TypeDefIndex: 29115
    {
        
        public int MagazineAmmo; // 0x50
      
        public int SourceAgentSpoonId; // 0x54
     
        public ulong SourceAgentId; // 0x58
       
        public ulong SourceSceneItemId; // 0x60


        public uint TemplateId; // 0x10

        public int Durability; // 0x14

        public ulong InstanceId; // 0x18

        public uint EventId; // 0x20

        public double ReceivedTimeStamp; // 0x28

        public uint OperatorFlags; // 0x30

        public string SpecialLabel; // 0x38

        public WeaponDataFlags WeaponFlags; // 0x40

        public float SceneItemHp; // 0x48


        // Constructors
        public WeaponDetail()
        {
            CustomFlagType = 2;
        } // 0x000000018C3B2030-0x000000018C3B2060
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
        public uint CurrentCharges; // 0x10
        public float CurrentPercentage; // 0x14
        public float ChargePeriod; // 0x18
        public uint MaxCharges; // 0x1C
        public double Timestamp; // 0x20
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
        public uint InstanceId; // 0x00
        public uint Id; // 0x04
        public ulong ReleaserId; // 0x08
        public double ExpireTime; // 0x10
        public uint Tier; // 0x18
        public bool Permanent; // 0x1C
        public ulong DestructibleId; // 0x20
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
        public uint Portrait; // 0x10
    }
    public class SpiritWeaponDetail : SerializedClass
    {
        // Fields
       
        public uint SpiritTid; // 0x10
      
        public ulong SpiritUid; // 0x18
      
        public ulong CurrentWeaponUid; // 0x20
    
        public List<WeaponDetail> WeaponSlots; // 0x28
      
        public WeaponDetail CurrentTempWeapon; // 0x30
        
        public WeaponWheelData TempWeaponSlots; // 0x38

        // Constructors
        public SpiritWeaponDetail() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class WeaponWheelData : SerializedClass
    {
        // Fields
       
        public uint WheelId; // 0x10
    
        public uint EventId; // 0x14
     
       
        public List<WeaponDetail> WeaponSlots; // 0x18

        // Constructors
        public WeaponWheelData() { } // 0x000000018C3B2060-0x000000018C3B2140
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
      
        public uint TemplateId; // 0x10
      
        public int Durability; // 0x14
      
        public ulong InstanceId; // 0x18
        
        public uint EventId; // 0x20
    
        public double ReceivedTimeStamp; // 0x28
        
        public uint OperatorFlags; // 0x30
      
        public string SpecialLabel; // 0x38
       
        public WeaponDataFlags WeaponFlags; // 0x40
      
        public float SceneItemHp; // 0x48


        // Constructors
        public WeaponData() {
            CustomFlagType = 1;
        } // 0x000000018C3B2030-0x000000018C3B2060
    }
    public class PokemonEnemy : SerializedClass
    {
        // Fields
     
        public ulong Id; // 0x10
   
        public uint Body; // 0x18
     
        public uint Camp; // 0x1C
    
        public uint Weapon; // 0x20
       
        public uint LimboChaId; // 0x24
      
        public uint AcquireTime; // 0x28
     
        public bool IsLocked; // 0x2C

        // Constructors
        public PokemonEnemy() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerInfoPokemon : SerializedClass
    {

        public List<PokemonEnemy> AllPokemons; // 0x10
  
        public List<ulong> FastFightSquad; // 0x18
      
        public List<uint> EnabledBodyIds; // 0x20
       
        public List<uint> EnabledCampIds; // 0x28
       
        public List<uint> EnabledWeaponIds; // 0x30

        // Constructors
        public PlayerInfoPokemon() { } // 0x000000018C3B15E0-0x000000018C3B1850
    }
    public class PlayerClientInfoMinor : SerializedClass
    {
        // Fields
        public long Exp; // 0x10
        public long Fan; // 0x18
        public uint Fan12; // 0x20
        public uint Fan123; // 0x24
        public int YesterdayFan; // 0x28
        public uint Level; // 0x2C
        public List<uint> LevelRewards; // 0x30
        public int Questionnaire; // 0x38
        public Dictionary<uint, DropLimitInfo> DropLimitCount; // 0x40
        public ChargeActivityClientInfo ChargeInfo; // 0x48
        public Dictionary<ulong, MapPin> MapPins; // 0x50
        public MiniGameData MiniGame; // 0x58
        public PlayerClientInfoGuide PlayerInfoGuide; // 0x60
        public PlayerClientInfoNpcCultivation InfoNpcCultivation; // 0x68
        public PlayerClientInfoNpcProfile InfoNpcProfile; // 0x70
        public PlayerClientInfoAtmosphereGameplay PlayerInfoAtmosphereGameplay; // 0x78
        public PlayerFashionsInfo PlayerFashionsInfo; // 0x80
        public HousesInfo housesInfo; // 0x88
        public PlayerPhoneInfo PlayerPhoneInfo; // 0x90
        public Dictionary<EventConditionImplModule, ModuleEventProgressInfo> ModuleEventProgressInfoDict; // 0x98
        public Dictionary<uint, LoadingTextInfo> LoadingTexts; // 0xA0
        public Dictionary<uint, BadgeInfo> Badges; // 0xA8
        public List<SpiritGroupChatInfo> GroupChats; // 0xB0
        public PlayerVehicleInfo VehicleInfo; // 0xB8
        public PlayerMatchInfo MatchInfo; // 0xC0
        public PlayerInfoPopularity PopularityInfoNew; // 0xC8
        public ComputerUnlockInfo ComputerUnlockInfo; // 0xD0
        public PlayerInteractionActionInfo PlayerInteractionActionInfo; // 0xD8
        public PlayerCityPediaInfos PlayerCityPediaInfos; // 0xE0
        public bool DebugReserveGpuDumps; // 0xE8
        public Dictionary<uint, NpcTimeTableInfo> FavorNpcDailyScheduleInfos; // 0xF0
        public Dictionary<uint, string> PlayerInterActionInfo; // 0xF8
        public PlanningBoardInfo PlanningBoardInfo; // 0x100
        public MallInfo MallInfo; // 0x108
        public PlayerBattlePassInfo PlayerBattlePassInfo; // 0x110
        public PlayerLinkPlanningBoardInfo PlayerLinkPlanningBoardInfo; // 0x118
        public PlayerGachaInfos PlayerGachaInfos; // 0x120
        public PlayerClientInspireHubInfo PlayerInspireHubInfo; // 0x128
    }
    public class PlayerClientInspireHubInfo : SerializedClass
    {
        // Fields
        public Dictionary<uint, int> TodayGamePlayJoinCountDict; // 0x10

    }
    public class PlayerGachaInfos : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, PlayerGachaPoolInfo> PoolInfos; // 0x10
      
        public Dictionary<uint, PlayerGachaGroupInfo> GroupInfos; // 0x18
        
        public Dictionary<uint, PlayerGachaPityInfo> PityInfos; // 0x20

        // Constructors
        public PlayerGachaInfos() { } // 0x000000018C3ADF30-0x000000018C3ADFD0
    }
    public class PlayerGachaPityInfo : SerializedClass
    {
        // Fields
      
        public uint DrawCountSinceLastGrandPrize; // 0x10
        public uint TotalDrawCount; // 0x14

        // Constructors
        public PlayerGachaPityInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }

    public class PlayerGachaGroupInfo : SerializedClass
    {
        // Fields
      
        public uint TotalDrawCount; // 0x10
      
        public Dictionary<uint, bool> ClaimedMilestoneCounts; // 0x18

        // Constructors
        public PlayerGachaGroupInfo() { } // 0x000000018C3B3A60-0x000000018C3B3A90
    }
    public class PlayerGachaPoolInfo : SerializedClass
    {

        public uint DrawCount; // 0x10
    
        public bool HasWonGrandPrize; // 0x14
       
        public Dictionary<uint, bool> WonFillerPrizeIds; // 0x18

        // Constructors
        public PlayerGachaPoolInfo() { } // 0x000000018C3B3A60-0x000000018C3B3A90
    }
    public class PlayerLinkPlanningBoardInfo : SerializedClass
    {
        
        public uint EnableMaxMultiPlayerId; // 0x10
     
        public bool IsSingleGame; // 0x14
       
        public List<ItemCountInfo> MultiGamePutInKeyCountInfoList; // 0x18

        // Constructors
        public PlayerLinkPlanningBoardInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class ItemCountInfo : SerializedClass
    {
        // Fields
     
        public uint TemplateId; // 0x10
     
        public uint Count; // 0x14

        // Constructors
        public ItemCountInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerBattlePassInfo : SerializedClass
    {
        // Fields
      
        public uint CurrentBattlePassId; // 0x10
      
        public uint Level; // 0x14
       
        public uint Exp; // 0x18
       
        public Dictionary<uint, RewardClaimState> ClaimedLevelRewards; // 0x20
      
        public BattlePassType CurrentPassType; // 0x28
      
        public uint LastWeeklyRefresherTime; // 0x2C
      
        public uint UnClaimedExp; // 0x30
       
        public Dictionary<uint, ChallengeTaskState> ChallengeTaskStates; // 0x38

        // Constructors
        public PlayerBattlePassInfo() { } // 0x000000018C3ADEB0-0x000000018C3ADF30
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
     
        public uint BoughtCount; // 0x10
       
        public uint NextRefreshTime; // 0x14

        // Constructors
        public MallCommodityInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerMonthCardInfo : SerializedClass
    {
        public uint LastReceiveTime; // 0x10
        public uint EndTime; // 0x14

        // Constructors
        public PlayerMonthCardInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class MallInfo : SerializedClass
    {
        // Fields
     
        public Dictionary<uint, MallCommodityInfo> CommodityInfoDict; // 0x10
     
        public PlayerMonthCardInfo MonthCardInfo; // 0x18
       
        public List<uint> CommoditySpiritDisplayPreferencesList; // 0x20

        // Constructors
        public MallInfo() { } // 0x000000018C3ADDE0-0x000000018C3ADEB0
    }
    public class PlanningBoardInfo : SerializedClass
    {
        public Dictionary<uint, byte> StepId2OptionIndexDict; // 0x10

        // Constructors
        public PlanningBoardInfo() { } // 0x000000018C3ADDB0-0x000000018C3ADDE0
    }
    public class NpcTimeTableInfo : SerializedClass
    {
        // Fields
     
        public NpcScheduleInfo Schedule0; // 0x10
       
        public NpcScheduleInfo Schedule1; // 0x18
       
        public NpcScheduleInfo Schedule2; // 0x20
       
        public NpcScheduleInfo Schedule3; // 0x28
      
        public NpcScheduleInfo Schedule4; // 0x30
       
        public int CurrentSpoonAgentId; // 0x38
      
        public UXVector3 SpoonPosition; // 0x3C

        // Constructors
        public NpcTimeTableInfo() { } // 0x000000018C3B3A90-0x000000018C3B3B30
    }
    public class NpcScheduleInfo : SerializedClass
    {
        // Fields
      
        public uint ActivityId; // 0x10
       
        public int StartDaySecond; // 0x14
       
        public UXVector3 Position; // 0x18
     
        public int SpoonAgentId; // 0x24
      
        public int EndDaySecond; // 0x28
      
        public uint RaidId; // 0x2C

        // Constructors
        public NpcScheduleInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerCityPediaInfos : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, bool> CityPedia2IsReadDict; // 0x10
      
        public CreditInfo CreditInfo; // 0x18

        // Constructors
        public PlayerCityPediaInfos() { } // 0x000000018C3ADD40-0x000000018C3ADDB0
    }
    public class CreditInfo : SerializedClass
    {
        // Fields
       
        public uint Credit; // 0x10
      
        public uint Level; // 0x14
       
        public Dictionary<uint, bool> ClaimedLevelRewards; // 0x18

        // Constructors
        public CreditInfo() { } // 0x000000018C3B3A60-0x000000018C3B3A90
    }
    public class PlayerInteractionActionInfo : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, PlayerInteractionActionItem> UnlockActionItemDict; // 0x10
      
        public bool InvitedNotDisturb; // 0x18

        // Constructors
        public PlayerInteractionActionInfo() { } // 0x000000018C3ADCF0-0x000000018C3ADD40
    }
    public class PlayerInteractionActionItem : SerializedClass
    {
        // Fields
     
        public uint CfgId; // 0x10
      
        public uint UnlockTime; // 0x14
      
        public bool ShowRedPoint; // 0x18

        // Constructors
        public PlayerInteractionActionItem() { } // 0x00000001871763E0-0x00000001871763F0
    }

    public class ComputerUnlockInfo : SerializedClass
    {
        // Fields
    
        public Dictionary<uint, ComputerEmail> UnlockEmails; // 0x10
      
        public Dictionary<uint, ComputerFile> UnlockFiles; // 0x18
      
        public Dictionary<uint, ComputerDetailInfo> ComputerInfos; // 0x20

        // Constructors
        public ComputerUnlockInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class ComputerFile : SerializedClass
    {
        // Fields
       
        public uint CfgId; // 0x10
      
        public uint UnlockTime; // 0x14
       
        public bool IsRead; // 0x18

        // Constructors
        public ComputerFile() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class ComputerDetailInfo : SerializedClass
    {
        // Fields
    
        public uint CfgId; // 0x10
     
        public uint FirstOpenTime; // 0x14
     
        public List<uint> DeleteFiles; // 0x18

        public List<uint> DeleteEmails; // 0x20

        // Constructors
        public ComputerDetailInfo() { } // 0x000000018C3B2CB0-0x000000018C3B2D80
    }

    public class ComputerEmail : SerializedClass
    {
        // Fields
    
        public uint CfgId; // 0x10
      
        public bool IsRead; // 0x14
        
        public uint UnlockTime; // 0x18

        // Constructors
        public ComputerEmail() { } // 0x00000001871763E0-0x00000001871763F0
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
        public Dictionary<uint, ModuleEventProgressInfoBySpirit> ProgressInfoDict; // 0x10
    }
    public class ModuleEventProgressInfoBySpirit : SerializedClass
    {
        // Fields
        public Dictionary<uint, EventProgressInfo> EventProgressInfoDict; // 0x10
        public List<uint> FinishedTemplateIdList; // 0x18

        // Constructors
        public ModuleEventProgressInfoBySpirit() { } // 0x000000018C3B3290-0x000000018C3B3340
    }
    public class EventProgressInfo : SerializedClass
    {
        // Fields
        public Dictionary<byte, EventProgress> EventProgressDict; // 0x10

        public uint Value; // 0x18

        // Constructors
        public EventProgressInfo() { } // 0x000000018C3B31F0-0x000000018C3B3240
    }
    public class EventProgress : SerializedClass
    {
        // Fields
      
        public uint EventId; // 0x10
    
        public uint Value; // 0x14
       
        public Dictionary<uint, uint> ProgressDict; // 0x18

        // Constructors
        public EventProgress() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerInfoPopularity : SerializedClass
    {
        public float Popularity; // 0x10
        public float UnderflowPopularity; // 0x14
        public int Version; // 0x18
        public uint NextPopularityUpdateTime; // 0x1C
        public uint NextUnderflowPopularityUpdateTime; // 0x20
        public List<PopularityData> HistoryPopularityList; // 0x28
        public uint LastUnderflowPopularitySpeed; // 0x30
        public List<PopularityWalletRewardData> WalletRewards; // 0x38
        public uint TotalLeftMoney; // 0x40
        public List<PopularityDropData> DropList; // 0x48
        public List<PopularityChangeInfo> ChangeList; // 0x50
        public float LastDiff; // 0x58
        public uint LastPopularityUpdateTime; // 0x5C
        public uint NextYesterdayAvgPopularityUpdateTime; // 0x60
        public float YesterdayAvgPopularity; // 0x64
        public uint TodayCoinGet; // 0x68
        public List<PopularityWalletRewardData> PastHoursCoinRewards; // 0x70

        // Constructors
        public PlayerInfoPopularity() { } // 0x000000018C3AD910-0x000000018C3ADCF0
    }
    public class PopularityData : SerializedClass
    {

    }
    public class PopularityWalletRewardData : SerializedClass
    {

    }
    public class PopularityDropData : SerializedClass
    {

    }
    public class PopularityChangeInfo : SerializedClass
    {

    }
    public class PlayerMatchInfo : SerializedClass
    {
        // Fields
      
        public Dictionary<uint, uint> GameId2LastPlayTime; // 0x10
       
        public uint LastInviteAllTime; // 0x18
       
        public List<uint> AvailablePrepareActions; // 0x20
      
        public bool InWorldBattle; // 0x28
      
        public LoadingTypeInfo LoadingTypeInfo; // 0x30
       
        public LinkDeviceLevel DeviceLevel; // 0x38
      
        public LinkDeviceLevel CurLinkDeviceLevel; // 0x3C

        // Constructors
        public PlayerMatchInfo() { } // 0x000000018C3AD860-0x000000018C3AD910
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
      
        public List<PlayerVehicleDetail> UnlockedVehicles; // 0x10
      
        public int RequisitionVehicleCount; // 0x18
      
        public uint ParkingVehicleId; // 0x1C

        // Constructors
        public PlayerVehicleInfo() { } // 0x000000018C3AD780-0x000000018C3AD860
    }
    public class PlayerVehicleDetail : SerializedClass
    {
        // Fields
     
        public uint Id; // 0x10
    
        public List<PlayerVehiclePartInfo> Parts; // 0x18
      
        public uint UnlockTime; // 0x20

        // Constructors
        public PlayerVehicleDetail() { } // 0x000000018C3AF7B0-0x000000018C3AF890
    }
    public class PlayerVehiclePartInfo : SerializedClass
    {
        
        public uint VehiclePartId; // 0x10
       
        public uint VehiclePartTag; // 0x14

        // Constructors
        public PlayerVehiclePartInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class SpiritGroupChatInfo : SerializedClass
    {
        // Fields
    
        public uint Id; // 0x10
      
        public uint CreateTime; // 0x14

        // Constructors
        public SpiritGroupChatInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class BadgeInfo : SerializedClass
    {
      
        public uint TemplateId; // 0x10
       
        public bool Active; // 0x14
        
        public bool DropSend; // 0x15

        // Constructors
        public BadgeInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class LoadingTextInfo : SerializedClass
    {
       
        public uint TemplateId; // 0x10
      
        public uint LeftTimes; // 0x14

        // Constructors
        public LoadingTextInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerPhoneInfo : SerializedClass
    {
        // Fields
       
        public Dictionary<uint, PhoneInfos> SpiritPhoneInfos; // 0x10

        public List<uint> DownLoadAppIds; // 0x18

        // Constructors
        public PlayerPhoneInfo() { } // 0x000000018C3B3140-0x000000018C3B31F0
    }
    public class PhoneInfos : SerializedClass
    {
        public List<PhoneContact> ContactList; // 0x10
       
        public List<PhoneContactGroup> ContactGroupList; // 0x18
      
        public List<PhoneContactCallRecord> CallRecordList; // 0x20
     
        public Dictionary<string, uint> ContactOutgoingCallTimesDict; // 0x28

        // Constructors
        public PhoneInfos() { } // 0x000000018C3B2E60-0x000000018C3B3140
    }
    public class PhoneContact : SerializedClass
    {
      
        public string Remark; // 0x10
        
        public string PhoneNumber; // 0x18

        // Constructors
        public PhoneContact() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PhoneContactCallRecord : SerializedClass
    {
        public uint CallTime; // 0x10
       
        public PhoneContactCallType CallType; // 0x14
       
        public string PhoneNumber; // 0x18

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
   
        public string Name; // 0x10
       
        public List<string> PhoneNumberList; // 0x18

        // Constructors
        public PhoneContactGroup() { } // 0x000000018C3B2D80-0x000000018C3B2E60
    }
    public class HousesInfo : SerializedClass
    {

        public List<HouseInfo> HouseInfoList; // 0x10
        public List<uint> NotParkingSpaceVehicleIdList; // 0x18
        public Dictionary<uint, FurnitureInfo> FurnitureInfoDict; // 0x20

        // Constructors
        public HousesInfo() { } // 0x000000018C3B2A80-0x000000018C3B2BF0
    }
    public class FurnitureInfo : SerializedClass
    {
        // Fields
       
        public uint FurnitureId; // 0x10
        
        public uint Count; // 0x14
      
        public uint PlacedCount; // 0x18

        // Constructors
        public FurnitureInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class HouseInfo : SerializedClass
    {
        public uint HouseId; // 0x10
        public Dictionary<int, uint> ParkingSpaceVehicleIdDict; // 0x18
        public Dictionary<uint, IndoorBuildInfo> FloorBuildInfoDict; // 0x20
        public ulong CurPlacedFurnitureInstanceId; // 0x28

        // Constructors
        public HouseInfo() { } // 0x000000018C3B2A10-0x000000018C3B2A80
    }
    public class IndoorBuildInfo : SerializedClass
    {
        // Fields
        //[FieldIndex(2)]
        // public PlacedFurnitureInfo Root; // 0x10

        // Constructors
        public IndoorBuildInfo() { } // 0x000000018C3B2C40-0x000000018C3B2CB0
    }
    public class PlayerFashionsInfo : SerializedClass
    {
        public Dictionary<uint, SpiritFashionsInfo> SpiritFashionsInfoDict; // 0x10
        public Dictionary<uint, FashionInfo> FashionInfoDict; // 0x18
        public List<uint> FavoriteFashionIdList; // 0x20

        public List<uint> FavoriteFashionSuitIdList; // 0x28

        public bool DefaultSpiritIsInitDefaultFashion; // 0x30

        public Dictionary<uint, TaskTryFashionInfo> SpiritId2TaskTryWearInfoDict; // 0x38

        // Constructors
        public PlayerFashionsInfo() { } // 0x00000001887022D0-0x0000000188702430
    }
    public class TaskTryFashionInfo : SerializedClass
    {

    }
    public class FashionInfo : SerializedClass
    {

    }
    public class SpiritFashionsInfo : SerializedClass
    {
      
   
        public uint SpiritId; // 0x10
        public FashionCustomSuitSchemeInfo[] FashionCustomSuitSchemeInfos; // 0x18
        public Dictionary<uint, FashionFunctionSuitSchemeInfo> FashionFunctionSuitSchemeInfoDict; // 0x20
        public SpiritWearFashionsInfo SpiritWearFashionsInfo; // 0x28
        public SpiritWearFashionsInfo SpiritPrevWearFashionsInfo; // 0x30
        public List<uint> FirstGainSuitIdList; // 0x38
       
        public byte EnableClientTryWearCount; // 0x40
    }
    public class BaseWearFashionsInfo : SerializedClass
    {
        public List<WearFashionInfo> WearFashionInfoList; // 0x10
        public List<WearFashionEditInfo> WearFashionEditInfoList; // 0x18
        public byte HiddenParts; // 0x20
        public byte EditedHiddenParts; // 0x21
    }
    public class WearFashionEditInfo : SerializedClass
    {

    }
    public class WearFashionInfo : SerializedClass
    {

    }
    public class SpiritWearFashionsInfo : SerializedClass
    {
        // Fields

        public uint FunctionSuitId; // 0x28
        public bool IsTryWear; // 0x2C
        public List<WearFashionInfo> WearFashionInfoList; // 0x10
       
        public List<WearFashionEditInfo> WearFashionEditInfoList; // 0x18
       
        public byte HiddenParts; // 0x20
        
        public byte EditedHiddenParts; // 0x21
        // Constructors
        public SpiritWearFashionsInfo() { } // 0x000000018C3AF980-0x000000018C3AF990
    }
    public class FashionFunctionSuitSchemeInfo : SerializedClass
    {

    }
    public class FashionCustomSuitSchemeInfo : SerializedClass
    {
       
       /* public List<WearFashionInfo> WearFashionInfoList; // 0x10
      
        public List<WearFashionEditInfo> WearFashionEditInfoList; // 0x18
        public byte HiddenParts; // 0x20
        public byte EditedHiddenParts; // 0x21
        public string SchemeName; // 0x28
       
        public bool JoinRandomPool; // 0x30

        // Constructors
        public FashionCustomSuitSchemeInfo() { } // 0x000000018C3AF980-0x000000018C3AF990*/
    }
    public class PlayerClientInfoAtmosphereGameplay : SerializedClass
    {
        // Fields
        public int PartTimeJobDailyRewardTimes; // 0x10
        public List<uint> PartTimeJobUnlockStore; // 0x18

        // Constructors
        public PlayerClientInfoAtmosphereGameplay() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerClientInfoNpcProfile : SerializedClass
    {
        // Fields
        public Dictionary<uint, TrustNpcInfo> NpcProfiles; // 0x10
        public List<uint> ProgressRewards; // 0x18

        // Constructors
        public PlayerClientInfoNpcProfile() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class TrustNpcInfo : SerializedClass
    {
        // Fields
       
        public uint ProfileId; // 0x10
        
        public uint TrustValue; // 0x14
      
        public uint ActivateTime; // 0x18
       
        public List<uint> GotRewardList; // 0x20
       
        public List<uint> FinishTargetList; // 0x28
      
        public bool IsNew; // 0x30
       
        public bool IsMaxTrustReward; // 0x31
       
        public List<TrustNpcTargetState> TargetStateList; // 0x38

        // Constructors
        public TrustNpcInfo() { } // 0x000000018C3B38B0-0x000000018C3B3A60
    }
    public class TrustNpcTargetState : SerializedClass
    {
        // Fields
      
        public uint TargetId; // 0x10
        public bool IsNew; // 0x14

        // Constructors
        public TrustNpcTargetState() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerClientInfoNpcCultivation : SerializedClass
    {
        // Fields
        public List<NpcCardInfo> NpcCardInfos ; // 0x10
        public List<NpcCardInfo> LockedCardInfos ; // 0x18
        public List<ClientNpcChatData> NpcChats ; // 0x20
        public List<ClientNpcGroupChatData> NpcGroupChats ; // 0x28
        public uint AvailableGiftSendCount = 0; // 0x30
        public uint InteractPoint = 0; // 0x34
        public NpcEventQueueList NpcEventQueueList ; // 0x38

    }
    public class ClientNpcGroupChatData : SerializedClass
    {
        // Fields
        public uint TemplateId; // 0x10
        public List<NpcChatItem> InviteChatList ; // 0x18
        public List<NpcChatItem> DialogChatList ; // 0x20
        public uint[] Members; // 0x28
        public Dictionary<uint, ChatInfoList> NpcChatListDict ; // 0x30
        public Dictionary<uint, ChatInfoList> DialogChatListDict ; // 0x38

        // Constructors
        public ClientNpcGroupChatData() { } // 0x000000018AF7B660-0x000000018AF7B880
    }
    public class NpcEventQueueList : SerializedClass
    {

        public Dictionary<uint, NpcEventQueue> NpcQueues; // 0x10
       
        public uint TodayTriggeredCount; // 0x18
       
        public Dictionary<uint, EventIdInfo> IdToNpcDict ; // 0x20
      
        public uint LastTriggerTime; // 0x28

        // Constructors
        public NpcEventQueueList() { } // 0x000000018C3B21C0-0x000000018C3B2240
    }
    public class NpcEventQueue : SerializedClass
    {

        public uint TodayTriggeredCount; // 0x10
    
        public List<uint> EventIds; // 0x18

        // Constructors
        public NpcEventQueue() { } // 0x00000001885E7C70-0x00000001885E7CE0
    }
    public class EventIdInfo : SerializedClass
    {

        public uint Id; // 0x10
 
        public uint NpcId; // 0x14
     
        public NpcQueueEventType EventType; // 0x18

        // Constructors
        public EventIdInfo() { } // 0x00000001871763E0-0x00000001871763F0
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
        public uint TemplateId; // 0x10
        public List<NpcChatItem> InviteChatList ; // 0x18
        public List<NpcChatItem> DialogChatList ; // 0x20
        public Dictionary<uint, ChatInfoList> NpcChatListDict ; // 0x28
        public Dictionary<uint, ChatInfoList> DialogChatListDict ; // 0x30

    }
    public class ChatInfoList : SerializedClass
    {
        public List<NpcChatItem> ChatList ; // 0x10

        // Constructors
        public ChatInfoList() { } // 0x000000018AF9D5E0-0x000000018AF9D6C0
    }
    public class NpcChatItem : SerializedClass
    {
      
        public uint Timestamp; // 0x10
       
        public uint ChatId; // 0x14
        
        public uint NextChatId; // 0x18
       
        public NpcChatContext ChatContext ; // 0x20
      
        public bool IsRead; // 0x28
      
        public uint BelongNpc; // 0x2C

    }
    public class NpcChatContext : SerializedClass
    {
        public uint BubbleId; // 0x10
        public uint AcquireCfgId; // 0x14
        public List<EmojiData> EmojiList ; // 0x18
        public string Url; // 0x20
        public uint ActivityCfgId; // 0x28

        // Constructors
        public NpcChatContext() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class EmojiData : SerializedClass
    {

        public string Id; // 0x10
        public uint Count; // 0x18

    }
    public class NpcCardInfo // TypeDefIndex: 29108
    {
        public uint TemplateId; // 0x10
        public List<uint> UnlockedVoice; // 0x18
   
        public uint ActivateTimestamp; // 0x20
 
        public double Favor; // 0x28

        public uint InteractDays; // 0x30
   
        public uint LastInteractTime; // 0x34

        public List<uint> GroupNpcPhotoPosList; // 0x38

        public List<uint> SingleNpcPhotoPosList; // 0x40

        public List<uint> TodayChatPosList; // 0x48

        public List<uint> FirstChatPosList; // 0x50

        public uint PreferCfgId; // 0x58

        public bool AcquireDropReward; // 0x5C
 
        public List<uint> ActiveGiftTags; // 0x60
  
        public double MaxFavorInHistory; // 0x68
 
        public uint TodayFavorDialogCount; // 0x70
  
        public List<uint> InteractedStories; // 0x78
  
        public bool HasUninteractedNpcVoice; // 0x80
    
        public List<uint> InteractedVoices; // 0x88
     
        public int FavorLevelReward; // 0x90

        public bool HasNoInteractedStory; // 0x94
 

        public Dictionary<uint, uint> UnlockedStoryDict; // 0x98
    }
    public class PlayerClientInfoGuide : SerializedClass
    {
        public List<uint> FinishedGuides; // 0x10
        public List<uint> NewGuideTeachInfos; // 0x18
        public List<uint> RewardedGuideTeachInfos; // 0x20
        public List<uint> UnlockSystems; // 0x28
        public List<ushort> TaskTitleGuideUnlockList; // 0x30
    }
    public class MiniGameData : SerializedClass
    {
        public List<uint> MiniGame_Bee; // 0x10

    }
    public class MapPin : SerializedClass
    {
        public uint RaidId; // 0x10

        public UXVector3 Position; // 0x14

        public byte Type; // 0x20
    }
    public class ChargeActivityClientInfo : SerializedClass
    {
        // Fields
        public bool HasFirstCharge; // 0x10
        public bool HasFirstChargeReward; // 0x11

    }

    public class DropLimitInfo : SerializedClass
    {
        public uint Count; // 0x10
        public uint FinishTime; // 0x14
    }
    public class PlayerClientInfoAchievement : SerializedClass
    {
        public Dictionary<uint, SceneFogMap> SceneFogMaps; // 0x10
        public List<uint> SceneFogMapPoiIds; // 0x18
        public List<uint> UnlockedCountryList; // 0x20
        public List<uint> UnlockedQuestList; // 0x28
        public Dictionary<uint, uint> CompletedSubQuestCnt; // 0x30
        public Dictionary<uint, ChallengeRecord> ChallengeRecordInfo; // 0x38
        public Dictionary<uint, NewChallengeRecord> NewChallengeRecordInfo; // 0x40
        public List<int> FirstKillEnemyRecord; // 0x48
        public List<uint> UnlockInvestigateGalleryList; // 0x50
        public int InvestigateGalleryRedCnt; // 0x58
        public Dictionary<uint, uint> CountryReputationInfo; // 0x60
        public Dictionary<uint, FactionInfo> FactionInfoDic; // 0x68
        public List<uint> OccupiedInfluenceArea; // 0x70
    }
    public class ChallengeRecord : SerializedClass
    {

    }
    public class NewChallengeRecord : SerializedClass
    {

    }
    public class NewClientBoardingInfo : SerializedClass
    {
        // Fields
        public ulong EntityId; // 0x10
        public BoardingStatus Status; // 0x18
        public ulong VehicleUId; // 0x20
        public byte SeatIndex; // 0x28

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
      
        public int Disposition; // 0x10
     
        public uint DispositionLevel; // 0x14
     
        public int Influence; // 0x18
    
        public uint InteractionCount; // 0x1C
        
        public uint GreetCount; // 0x20
    }
    public class SceneFogMap : SerializedClass
    {
        // Fields
       
        public byte[] FogValue; // 0x10
        
        public bool All; // 0x18
      
        public int LockCnt; // 0x1C
       
        public int XSize; // 0x20
       
        public int ZSize; // 0x24
    
        public int TileSize; // 0x28

        // Constructors
        public SceneFogMap() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class PlayerClientInfoLogin : SerializedClass
    {
        // Fields
        public int Aid; // 0x10
        public ulong Pid; // 0x18
        public string AccountId; // 0x20
        public string Name; // 0x28
        public uint Level; // 0x30
        public SexType Sex; // 0x34
        public PersonalZoneHeadInfo PzHeadInfo ; // 0x38
    }
    public class PlayerClientInfoItem : SerializedClass
    {
        // Fields
        public uint Money; // 0x10
        public uint Gold; // 0x14
        public uint BindingGold; // 0x18
        public int FreeGold; // 0x1C
        public List<PlayerItemDayCount> ItemDayCounts ; // 0x20
        public List<PlayerPackItem> PackItems ; // 0x28
        public Dictionary<ItemShortcutType, ItemShortcutInfo> ItemShortcutDic; // 0x30
        public uint DestructibleShortcut; // 0x38
        public uint TodayGachaCount; // 0x3C
        public Dictionary<uint, int> GachaPoolCount; // 0x40
        public List<ItemCountLimitInfo> ItemCountLimitInfoList ; // 0x48
        public uint QuantumWalletStartTime; // 0x50
        public UXVector3 PortalPosition ; // 0x54
        public uint PortalRaidId; // 0x60
    }
    public class ItemShortcutInfo : SerializedClass
    {
        public ulong UniqueId; // 0x10
        public uint TemplateId; // 0x18
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
        public uint ItemId; // 0x10
        public uint Count; // 0x14
        public uint NextRefreshTime; // 0x18
    }
    public class PlayerPackItem : SerializedClass
    {
        // Fields
        public ulong UniqueId; // 0x10
        public uint TemplateId; // 0x18
        public uint Count; // 0x1C
        public bool IsNew; // 0x20
        public uint ExpiryTime; // 0x24
        public RemindState RemindState; // 0x28
        public uint CDFinishTime; // 0x2C

    }
    public enum RemindState // TypeDefIndex: 28552
    {
        Normal = 0,
        Expiring = 1,
        Expired = 2
    }
    public class PlayerItemDayCount : SerializedClass
    {
        public uint TemplateId; // 0x10
        public uint Count; // 0x14
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
        public ulong SpiritUid; // 0x10
  
        public ulong WeaponInstanceId; // 0x18
        public SwitchWeaponReason Reason; // 0x20

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
        // Fields
        public ulong Id; // 0x10
        public UXVector3 Position; // 0x18
        public float facingDirection; // 0x24
        public UXVector3 Velocity; // 0x28
        public byte[] Bits; // 0x38

        
    }
}
