using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class SyncMoney4229938
{
    public double money;
    public double gold;
    public double bindingGold;
}

[UxContract(Inline = true)]
internal sealed class SyncMoneyAdd4229938
{
    public double value;
    public int reason;
    public bool silence;
}

[UxContract(Inline = true)]
internal sealed class SyncMoneyRemove4229938
{
    public double value;
}

[UxContract(Inline = true)]
internal sealed class SyncRemoveFashion4229938
{
    public uint fashionId;
}

[UxContract(Inline = true)]
internal sealed class SyncRemoveFashionList4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> fashionIds = [];
}

[UxContract(Inline = true)]
internal sealed class SyncAddFashion4229938
{
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public Auto.FashionInfo fashionInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAddFashionList4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.FashionInfo> fashionInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class AskSetSpiritFashionsWithSource4229938
{
    public uint spiritOrInstanceId;
    public short source;
    public byte reserved;

    public uint functionSuitId;

    public short wearSource;
    public uint wearSourceId;

    public bool isTryWear;

    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<WearFashionInfo> wearFashionInfoList = [];

    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<WearFashionEditInfo>? wearFashionEditInfoList = [];

    public byte hiddenParts;
    public byte editedHiddenParts;
}

[UxContract(Inline = true)]
internal sealed class SyncArmoryAddWeapon4229938
{
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public Auto.WeaponData weapon = new();
}

[UxContract(Inline = true)]
internal sealed class SyncArmoryRemoveWeapon4229938
{
    public ulong id;
}

[UxContract(Inline = true)]
internal sealed class AskDiscardWeaponByInstanceId4229938
{
    public ulong instanceId;
    public uint spiritId;
    public bool confirm;
}

[UxContract(Inline = true)]
internal sealed class AskMallBuyCommodity4229938
{
    public uint commodityId;
    public uint count;
    public bool flag;
}

[UxContract(Inline = true)]
internal sealed class AskBuyCommodity4229938
{
    public uint shopId;
    public uint commodityId;
    public uint count;
}

[UxContract(Inline = true)]
internal sealed class AskNpcShopId4229938
{
    public uint shopId;
}

[UxContract(Inline = true)]
internal sealed class NpcShopCommodityInfo4229938
{
    public uint currentDiscount = 1;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<ShopCommodity4229938> commodityInfoList = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<ShopCommodity4229938> buybackCommodityInfoList = [];

    
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public ShopRefreshState4229938 refreshState = new();
}

[UxContract]
internal sealed class ShopRefreshState4229938
{
    public byte SpawnType;
    public uint EventId;
}

[UxContract]
internal sealed class ShopCommodity4229938
{
    public uint id;
    public uint commodityId;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> prices = [];
}

[UxContract(Inline = true)]
internal sealed class AskGetVehicleRadioContent4229938
{
    public uint radioId;
    public uint index;
}

[UxContract(Inline = true)]
internal sealed class AskSwitchVehicleRadio4229938
{
    public uint radioId;
}

[UxContract(Inline = true)]
internal sealed class SyncAddRadioSong4229938
{
    public uint songId;
}

[UxContract]
internal sealed class MetroInfo4229938
{
    public int Id;
    public uint LineId;
    public float ElapsedTime;
    public bool IsFinalTrain;
}

[UxContract(Inline = true)]
internal sealed class SyncRunningMetroInfos4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<MetroInfo4229938> metroInfos = [];
}

[UxContract(Inline = true)]
internal sealed class SyncDestroyMetroInfos4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> metroInfos = [];
}

[UxContract(Inline = true)]
internal sealed class NpcAgentPosDict4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, NpcAgentPos4229938> npcPosDict = new();
}

[UxContract]
internal sealed class NpcAgentPos4229938
{
    public uint RaidId;
    public Auto.UXVector3 Position = new();
}

[UxContract(Inline = true)]
internal sealed class AskSetMobileSkinPart4229938
{
    public uint part0;
    public uint part1;
    public uint part2;
}

[UxContract(Inline = true)]
internal sealed class AskInstallMobileApp4229938
{
    public uint appId;
}

[UxContract(Inline = true)]
internal sealed class AskActiveDynamicGo4229938
{
    public uint id;
    public byte flag0;
    public byte flag1;
}

[UxContract(Inline = true)]
internal sealed class SyncSubwayFare4229938
{
    public uint fare;
}

[UxContract(Inline = true)]
internal sealed class SyncPrepareMapEntrance4229938
{
    public uint entrance;
}

[UxContract(Inline = true)]
internal sealed class SyncSceneFogMapAllUnlock4229938{
    public uint sceneId;
    public bool unlock;
}

[UxContract(Inline = true)]
internal sealed class SyncSceneFogMapValue4229938
{
    public uint sceneId;
    public int value;
}

[UxContract(Inline = true)]
internal sealed class SyncMapEntrance4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> openEntrance = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> displayableEntrances = [];
}

[UxContract(Inline = true)]
internal sealed class SyncNewAchievement4229938
{
    public uint id;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public AchievementDetail4229938 detail = new();
}

[UxContract]
internal sealed class AchievementDetail4229938
{
    public double AchieveTime;
    public byte Status;
}

[UxContract(Inline = true)]
internal sealed class SyncNewCityPediaInfo4229938
{
    public uint cityPediaId;
}

[UxContract]
internal sealed class ShopCommodityRow4229938
{
    public uint TemplateId;
    public int Count;
    public uint RefreshTime;
    public byte Status;
    public uint Discount;
    public uint DiscountPrice;
    public uint MaxBuyCount;
}

[UxContract(Inline = true)]
internal sealed class SyncCommodityInfos4229938
{
    public uint shopId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<ShopCommodityRow4229938> infos = [];
}

[UxContract]
internal sealed class ShopRefreshStateRow4229938
{
    public uint SellRefreshTime;
    public uint BuybackRefreshTime;
    public uint ManualRefreshCountResetTime;
    public uint SellManualRefreshCount;
    public uint BuybackManualRefreshCount;
    public uint SellRotationIndex;
    public uint BuybackRotationIndex;
}

[UxContract(Inline = true)]
internal sealed class SyncShopRefreshState4229938
{
    public uint shopId;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public ShopRefreshStateRow4229938 refreshState = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAddHouse4229938
{
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public HouseInfo4229938 houseInfo = new();
}

[UxContract]
internal sealed class HouseInfo4229938
{
    public uint HouseId;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public Dictionary<int, uint> ParkingSpaceVehicleIdDict = new();

    [UxCollection(Count = UxCountEncoding.Int32, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, HouseFloorBuildInfo4229938> FloorBuildInfoDict = new();

    public ulong CurPlacedFurnitureInstanceId;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public HouseWallInfo4229938? WallInfo;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public HouseConfiguration4229938? Configuration;

    [UxCollection(Count = UxCountEncoding.Int32, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<ulong, HouseFashionShowcase4229938> FashionShowcaseDict = new();

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public HousePlacementStatistics4229938? PlacementStatistics;
}

[UxContract]
internal sealed class HouseFloorBuildInfo4229938
{
    public uint FloorId;
}

[UxContract]
internal sealed class HouseWallInfo4229938
{
    public uint WallId;
}

[UxContract]
internal sealed class HouseConfiguration4229938
{
    public uint ConfigId;
}

[UxContract]
internal sealed class HouseFashionShowcase4229938
{
    public uint SlotId;
}

[UxContract]
internal sealed class HousePlacementStatistics4229938
{
    public uint PlacedCount;
}

[UxContract]
internal sealed class MobileSkinInfo4229938
{
    public uint Wallpaper;
    public uint Decoration;
    public uint Pendant;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritMobileSkinPartInfo4229938
{
    public uint spiritId;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public MobileSkinInfo4229938 mobileSkinInfo = new();

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> availableSkinParts = [];
}

[UxContract(Inline = true)]
internal sealed class FactionChangeInfo4229938
{
    public uint FactionId;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public FactionInfo4229938? NewInfo;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public FactionInfo4229938? OldInfo;
}

[UxContract]
internal sealed class FactionInfo4229938
{
    public int Disposition;
    public uint DispositionLevel;
    public int Influence;
    public uint InteractionCount;
    public uint GreetCount;
    public bool IsUnlock;
}

[UxContract(Inline = true)]
internal sealed class SyncFactionInfosChange4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<FactionChangeInfo4229938> changeInfos = [];

    public uint dropTextId;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritCombatPowerChanged4229938
{
    public uint spiritId;
    public float combatPower;
}

[UxContract(Inline = true)]
internal sealed class SyncFashionInfoDict4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, Auto.FashionInfo> fashionInfoDict = new();
}

[UxContract(Inline = true)]
internal sealed class UpdateMapEntrance4229938
{
    public uint mapEntranceId;
    public bool isOpen;
    public bool isShow;
}

[UxContract]
internal sealed class SpiritPhoneInfos4229938
{
    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpiritContact4229938> ContactList = [];

    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpiritContactGroup4229938> ContactGroupList = [];

    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpiritCallRecord4229938> CallRecordList = [];

    [UxCollection(Count = UxCountEncoding.Int32)]
    public Dictionary<string, uint> ContactOutgoingCallTimesDict = new();
}

[UxContract]
internal sealed class SpiritContact4229938
{
    public string? Remark;
    public string? PhoneNumber;
}

[UxContract]
internal sealed class SpiritContactGroup4229938
{
    public string? Name;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<string> PhoneNumberList = [];
}

[UxContract]
internal sealed class SpiritCallRecord4229938
{
    public uint CallTime;
    public byte CallType;
    public string? PhoneNumber;
}

[UxContract(Inline = true)]
internal sealed class AddSpiritPhoneInfos4229938
{
    public uint spiritId;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public SpiritPhoneInfos4229938 phoneInfos = new();
}

[UxContract(Inline = true)]
internal sealed class AskActivateNpcProfile4229938
{
    public uint profileId;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerNpcProfileActivate4229938
{
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public Auto.TrustNpcInfo profileInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerNpcProfileTrustValueChanged4229938
{
    public uint ProfileId;
    public uint TrustValue;
    public int Reason;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerNpcProfileRewardGot4229938
{
    public uint profileId;
    public uint rewardId;
}

[UxContract]
internal sealed class SpiritBadgeInfo4229938
{
    public uint TemplateId;
    public bool Active;
    public bool DropSend;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritBadgeInfo4229938
{
    public uint spiritId;
    public uint badgeId;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public SpiritBadgeInfo4229938 badgeInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncTeleport4229938
{
    public ulong teleportId;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;
    public bool IsSwitchScene;
    public bool WaitTaskResource;
}
