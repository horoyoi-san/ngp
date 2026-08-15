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
        private static readonly uint[] Spirit15020992FashionIds = {
            11130003, 
            11130004, 
            11130006, 
        };


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
                        FashionInfoDict = new()
                        {
                            { 11100000, new FashionInfo() },
                            { 11100002, new FashionInfo() },
                            { 11100003, new FashionInfo() },
                            { 11100004, new FashionInfo() },
                            { 11100005, new FashionInfo() },
                            { 11100006, new FashionInfo() },
                            { 11100007, new FashionInfo() },
                            { 11100008, new FashionInfo() },
                            { 11100009, new FashionInfo() },
                            { 11100010, new FashionInfo() },
                            { 11100012, new FashionInfo() },
                            { 11100014, new FashionInfo() },
                            { 11100015, new FashionInfo() },
                            { 11100016, new FashionInfo() },
                            { 11100018, new FashionInfo() },
                            { 11100019, new FashionInfo() },
                            { 11100021, new FashionInfo() },
                            { 11100022, new FashionInfo() },
                            { 11100023, new FashionInfo() },
                            { 11100031, new FashionInfo() },
                            { 11100032, new FashionInfo() },
                            { 11100033, new FashionInfo() },
                            { 11100034, new FashionInfo() },
                            { 11100038, new FashionInfo() },
                            { 11100039, new FashionInfo() },
                            { 11100040, new FashionInfo() },
                            { 11100041, new FashionInfo() },
                            { 11100042, new FashionInfo() },
                            { 11100043, new FashionInfo() },
                            { 11100044, new FashionInfo() },
                            { 11100045, new FashionInfo() },
                            { 11100048, new FashionInfo() },
                            { 11100049, new FashionInfo() },
                            { 11100050, new FashionInfo() },
                            { 11100051, new FashionInfo() },
                            { 11100052, new FashionInfo() },
                            { 11100053, new FashionInfo() },
                            { 11100056, new FashionInfo() },
                            { 11100057, new FashionInfo() },
                            { 11100058, new FashionInfo() },
                            { 11100059, new FashionInfo() },
                            { 11100060, new FashionInfo() },
                            { 11100061, new FashionInfo() },
                            { 11100062, new FashionInfo() },
                            { 11100064, new FashionInfo() },
                            { 11100065, new FashionInfo() },
                            { 11100066, new FashionInfo() },
                            { 11100067, new FashionInfo() },
                            { 11100068, new FashionInfo() },
                            { 11100074, new FashionInfo() },
                            { 11100075, new FashionInfo() },
                            { 11100076, new FashionInfo() },
                            { 11100077, new FashionInfo() },
                            { 11100085, new FashionInfo() },
                            { 11100087, new FashionInfo() },
                            { 11100090, new FashionInfo() },
                            { 11100091, new FashionInfo() },
                            { 11100092, new FashionInfo() },
                            { 11100093, new FashionInfo() },
                            { 11100094, new FashionInfo() },
                            { 11100095, new FashionInfo() },
                            { 11100097, new FashionInfo() },
                            { 11100098, new FashionInfo() },
                            { 11100099, new FashionInfo() },
                            { 11100104, new FashionInfo() },
                            { 11120000, new FashionInfo() },
                            { 11120001, new FashionInfo() },
                            { 11120002, new FashionInfo() },
                            { 11120003, new FashionInfo() },
                            { 11120004, new FashionInfo() },
                            { 11120005, new FashionInfo() },
                            { 11120006, new FashionInfo() },
                            { 11120007, new FashionInfo() },
                            { 11120008, new FashionInfo() },
                            { 11120009, new FashionInfo() },
                            { 11120010, new FashionInfo() },
                            { 11120012, new FashionInfo() },
                            { 11120013, new FashionInfo() },
                            { 11120014, new FashionInfo() },
                            { 11120016, new FashionInfo() },
                            { 11120017, new FashionInfo() },
                            { 11120018, new FashionInfo() },
                            { 11120021, new FashionInfo() },
                            { 11120022, new FashionInfo() },
                            { 11120024, new FashionInfo() },
                            { 11120025, new FashionInfo() },
                            { 11120026, new FashionInfo() },
                            { 11120027, new FashionInfo() },
                            { 11120028, new FashionInfo() },
                            { 11120029, new FashionInfo() },
                            { 11120030, new FashionInfo() },
                            { 11120031, new FashionInfo() },
                            { 11120032, new FashionInfo() },
                            { 11120034, new FashionInfo() },
                            { 11120036, new FashionInfo() },
                            { 11120038, new FashionInfo() },
                            { 11120039, new FashionInfo() },
                            { 11120040, new FashionInfo() },
                            { 11120041, new FashionInfo() },
                            { 11120042, new FashionInfo() },
                            { 11120043, new FashionInfo() },
                            { 11120047, new FashionInfo() },
                            { 11120048, new FashionInfo() },
                            { 11120049, new FashionInfo() },
                            { 11120050, new FashionInfo() },
                            { 11120051, new FashionInfo() },
                            { 11120052, new FashionInfo() },
                            { 11120053, new FashionInfo() },
                            { 11120061, new FashionInfo() },
                            { 11120062, new FashionInfo() },
                            { 11120063, new FashionInfo() },
                            { 11120064, new FashionInfo() },
                            { 11120065, new FashionInfo() },
                            { 11120066, new FashionInfo() },
                            { 11120067, new FashionInfo() },
                            { 11120068, new FashionInfo() },
                            { 11120069, new FashionInfo() },
                            { 11120070, new FashionInfo() },
                            { 11120072, new FashionInfo() },
                            { 11120073, new FashionInfo() },
                            { 11120074, new FashionInfo() },
                            { 11120075, new FashionInfo() },
                            { 11120079, new FashionInfo() },
                            { 11120081, new FashionInfo() },
                            { 11120082, new FashionInfo() },
                            { 11120083, new FashionInfo() },
                            { 11120084, new FashionInfo() },
                            { 11120085, new FashionInfo() },
                            { 11120086, new FashionInfo() },
                            { 11120087, new FashionInfo() },
                            { 11120088, new FashionInfo() },
                            { 11120089, new FashionInfo() },
                            { 11120090, new FashionInfo() },
                            { 11120091, new FashionInfo() },
                            { 11120092, new FashionInfo() },
                            { 11120097, new FashionInfo() },
                            { 11120098, new FashionInfo() },
                            { 11120099, new FashionInfo() },
                            { 11120100, new FashionInfo() },
                            { 11120101, new FashionInfo() },
                            { 11120102, new FashionInfo() },
                            { 11120103, new FashionInfo() },
                            { 11120104, new FashionInfo() },
                            { 11120105, new FashionInfo() },
                            { 11120106, new FashionInfo() },
                            { 11120107, new FashionInfo() },
                            { 11120108, new FashionInfo() },
                            { 11120110, new FashionInfo() },
                            { 11120111, new FashionInfo() },
                            { 11120112, new FashionInfo() },
                            { 11120113, new FashionInfo() },
                            { 11120114, new FashionInfo() },
                            { 11120115, new FashionInfo() },
                            { 11120116, new FashionInfo() },
                            { 11120117, new FashionInfo() },
                            { 11120118, new FashionInfo() },
                            { 11120119, new FashionInfo() },
                            { 11120120, new FashionInfo() },
                            { 11120121, new FashionInfo() },
                            { 11120122, new FashionInfo() },
                            { 11120123, new FashionInfo() },
                            { 11120124, new FashionInfo() },
                            { 11120125, new FashionInfo() },
                            { 11120127, new FashionInfo() },
                            { 11120128, new FashionInfo() },
                            { 11120129, new FashionInfo() },
                            { 11120130, new FashionInfo() },
                            { 11120132, new FashionInfo() },
                            { 11120133, new FashionInfo() },
                            { 11120134, new FashionInfo() },
                            { 11120135, new FashionInfo() },
                            { 11120136, new FashionInfo() },
                            { 11120137, new FashionInfo() },
                            { 11120138, new FashionInfo() },
                            { 11120139, new FashionInfo() },
                            { 11120140, new FashionInfo() },
                            { 11120141, new FashionInfo() },
                            { 11120142, new FashionInfo() },
                            { 11120143, new FashionInfo() },
                            { 11120144, new FashionInfo() },
                            { 11120145, new FashionInfo() },
                            { 11120150, new FashionInfo() },
                            { 11120151, new FashionInfo() },
                            { 11120152, new FashionInfo() },
                            { 11120154, new FashionInfo() },
                            { 11120155, new FashionInfo() },
                            { 11120156, new FashionInfo() },
                            { 11120157, new FashionInfo() },
                            { 11120158, new FashionInfo() },
                            { 11120159, new FashionInfo() },
                            { 11120160, new FashionInfo() },
                            { 11120161, new FashionInfo() },
                            { 11120162, new FashionInfo() },
                            { 11120163, new FashionInfo() },
                            { 11120164, new FashionInfo() },
                            { 11120165, new FashionInfo() },
                            { 11120166, new FashionInfo() },
                            { 11120167, new FashionInfo() },
                            { 11120168, new FashionInfo() },
                            { 11120169, new FashionInfo() },
                            { 11120170, new FashionInfo() },
                            { 11120171, new FashionInfo() },
                            { 11120172, new FashionInfo() },
                            { 11120173, new FashionInfo() },
                            { 11120174, new FashionInfo() },
                            { 11120175, new FashionInfo() },
                            { 11120176, new FashionInfo() },
                            { 11120177, new FashionInfo() },
                            { 11120179, new FashionInfo() },
                            { 11120180, new FashionInfo() },
                            { 11120181, new FashionInfo() },
                            { 11120182, new FashionInfo() },
                            { 11120183, new FashionInfo() },
                            { 11120184, new FashionInfo() },
                            { 11120185, new FashionInfo() },
                            { 11120186, new FashionInfo() },
                            { 11120187, new FashionInfo() },
                            { 11120188, new FashionInfo() },
                            { 11120190, new FashionInfo() },
                            { 11120191, new FashionInfo() },
                            { 11120192, new FashionInfo() },
                            { 11120193, new FashionInfo() },
                            { 11120194, new FashionInfo() },
                            { 11120195, new FashionInfo() },
                            { 11120196, new FashionInfo() },
                            { 11120197, new FashionInfo() },
                            { 11120198, new FashionInfo() },
                            { 11120199, new FashionInfo() },
                            { 11120200, new FashionInfo() },
                            { 11120201, new FashionInfo() },
                            { 11120203, new FashionInfo() },
                            { 11120204, new FashionInfo() },
                            { 11120205, new FashionInfo() },
                            { 11120206, new FashionInfo() },
                            { 11120207, new FashionInfo() },
                            { 11120208, new FashionInfo() },
                            { 11120209, new FashionInfo() },
                            { 11120210, new FashionInfo() },
                            { 11120211, new FashionInfo() },
                            { 11120212, new FashionInfo() },
                            { 11120213, new FashionInfo() },
                            { 11120214, new FashionInfo() },
                            { 11120215, new FashionInfo() },
                            { 11120216, new FashionInfo() },
                            { 11120217, new FashionInfo() },
                            { 11120218, new FashionInfo() },
                            { 11120219, new FashionInfo() },
                            { 11120220, new FashionInfo() },
                            { 11120221, new FashionInfo() },
                            { 11120222, new FashionInfo() },
                            { 11120223, new FashionInfo() },
                            { 11120224, new FashionInfo() },
                            { 11120225, new FashionInfo() },
                            { 11120226, new FashionInfo() },
                            { 11120227, new FashionInfo() },
                            { 11120228, new FashionInfo() },
                            { 11120229, new FashionInfo() },
                            { 11120230, new FashionInfo() },
                            { 11120231, new FashionInfo() },
                            { 11120232, new FashionInfo() },
                            { 11120233, new FashionInfo() },
                            { 11120234, new FashionInfo() },
                            { 11120235, new FashionInfo() },
                            { 11120236, new FashionInfo() },
                            { 11120237, new FashionInfo() },
                            { 11120238, new FashionInfo() },
                            { 11120239, new FashionInfo() },
                            { 11120240, new FashionInfo() },
                            { 11120241, new FashionInfo() },
                            { 11120242, new FashionInfo() },
                            { 11120243, new FashionInfo() },
                            { 11120244, new FashionInfo() },
                            { 11120245, new FashionInfo() },
                            { 11120246, new FashionInfo() },
                            { 11120247, new FashionInfo() },
                            { 11120248, new FashionInfo() },
                            { 11120249, new FashionInfo() },
                            { 11120250, new FashionInfo() },
                            { 11120251, new FashionInfo() },
                            { 11120252, new FashionInfo() },
                            { 11120253, new FashionInfo() },
                            { 11120254, new FashionInfo() },
                            { 11120255, new FashionInfo() },
                            { 11120256, new FashionInfo() },
                            { 11120257, new FashionInfo() },
                            { 11120258, new FashionInfo() },
                            { 11120259, new FashionInfo() },
                            { 11120260, new FashionInfo() },
                            { 11120261, new FashionInfo() },
                            { 11120262, new FashionInfo() },
                            { 11120267, new FashionInfo() },
                            { 11120268, new FashionInfo() },
                            { 11120269, new FashionInfo() },
                            { 11120270, new FashionInfo() },
                            { 11120271, new FashionInfo() },
                            { 11120272, new FashionInfo() },
                            { 11120273, new FashionInfo() },
                            { 11120274, new FashionInfo() },
                            { 11120275, new FashionInfo() },
                            { 11120276, new FashionInfo() },
                            { 11120277, new FashionInfo() },
                            { 11120278, new FashionInfo() },
                            { 11120279, new FashionInfo() },
                            { 11120280, new FashionInfo() },
                            { 11120281, new FashionInfo() },
                            { 11120282, new FashionInfo() },
                            { 11120283, new FashionInfo() },
                            { 11120284, new FashionInfo() },
                            { 11120285, new FashionInfo() },
                            { 11120286, new FashionInfo() },
                            { 11120288, new FashionInfo() },
                            { 11120289, new FashionInfo() },
                            { 11120290, new FashionInfo() },
                            { 11120291, new FashionInfo() },
                            { 11120292, new FashionInfo() },
                            { 11120293, new FashionInfo() },
                            { 11120294, new FashionInfo() },
                            { 11120295, new FashionInfo() },
                            { 11120296, new FashionInfo() },
                            { 11120297, new FashionInfo() },
                            { 11120298, new FashionInfo() },
                            { 11120299, new FashionInfo() },
                            { 11120300, new FashionInfo() },
                            { 11120301, new FashionInfo() },
                            { 11120302, new FashionInfo() },
                            { 11120303, new FashionInfo() },
                            { 11120304, new FashionInfo() },
                            { 11120305, new FashionInfo() },
                            { 11120306, new FashionInfo() },
                            { 11120307, new FashionInfo() },
                            { 11120308, new FashionInfo() },
                            { 11120309, new FashionInfo() },
                            { 11120310, new FashionInfo() },
                            { 11120313, new FashionInfo() },
                            { 11120314, new FashionInfo() },
                            { 11120315, new FashionInfo() },
                            { 11120316, new FashionInfo() },
                            { 11120317, new FashionInfo() },
                            { 11120318, new FashionInfo() },
                            { 11120319, new FashionInfo() },
                            { 11120320, new FashionInfo() },
                            { 11120321, new FashionInfo() },
                            { 11120322, new FashionInfo() },
                            { 11120323, new FashionInfo() },
                            { 11120324, new FashionInfo() },
                            { 11120325, new FashionInfo() },
                            { 11120326, new FashionInfo() },
                            { 11120327, new FashionInfo() },
                            { 11120328, new FashionInfo() },
                            { 11120329, new FashionInfo() },
                            { 11120330, new FashionInfo() },
                            { 11120331, new FashionInfo() },
                            { 11120351, new FashionInfo() },
                            { 11130000, new FashionInfo() },
                            { 11130001, new FashionInfo() },
                            { 11130002, new FashionInfo() },
                            { 11130003, new FashionInfo() },
                            { 11130004, new FashionInfo() },
                            { 11130006, new FashionInfo() },
                            { 11130007, new FashionInfo() },
                            { 11130008, new FashionInfo() },
                            { 11130009, new FashionInfo() },
                            { 11130010, new FashionInfo() },
                            { 11130011, new FashionInfo() },
                            { 11130012, new FashionInfo() },
                            { 11130013, new FashionInfo() },
                            { 11130014, new FashionInfo() },
                            { 11130015, new FashionInfo() },
                            { 11130016, new FashionInfo() },
                            { 11130017, new FashionInfo() },
                            { 11130018, new FashionInfo() },
                            { 11130019, new FashionInfo() },
                            { 11130020, new FashionInfo() },
                            { 11130021, new FashionInfo() },
                            { 11130022, new FashionInfo() },
                            { 11130023, new FashionInfo() },
                            { 11130024, new FashionInfo() },
                            { 11130025, new FashionInfo() },
                            { 11130026, new FashionInfo() },
                            { 11130027, new FashionInfo() },
                            { 11130028, new FashionInfo() },
                            { 11130041, new FashionInfo() },
                            { 11130042, new FashionInfo() },
                            { 11130043, new FashionInfo() },
                            { 11130044, new FashionInfo() },
                            { 11130045, new FashionInfo() },
                            { 11130046, new FashionInfo() },
                            { 11130047, new FashionInfo() },
                            { 11130048, new FashionInfo() },
                            { 11130049, new FashionInfo() },
                            { 11130050, new FashionInfo() },
                            { 11130051, new FashionInfo() },
                            { 11130052, new FashionInfo() },
                            { 11130053, new FashionInfo() },
                            { 11130054, new FashionInfo() },
                            { 11130055, new FashionInfo() },
                            { 11130056, new FashionInfo() },
                            { 11130057, new FashionInfo() },
                            { 11130058, new FashionInfo() },
                            { 11130059, new FashionInfo() },
                            { 11130060, new FashionInfo() },
                            { 11130061, new FashionInfo() },
                            { 11130062, new FashionInfo() },
                            { 11130063, new FashionInfo() },
                            { 11130064, new FashionInfo() },
                            { 11130065, new FashionInfo() },
                            { 11130066, new FashionInfo() },
                            { 11130067, new FashionInfo() },
                            { 11130068, new FashionInfo() },
                            { 11130069, new FashionInfo() },
                            { 11130070, new FashionInfo() },
                            { 11130071, new FashionInfo() },
                            { 11130072, new FashionInfo() },
                            { 11130073, new FashionInfo() },
                            { 11130074, new FashionInfo() },
                            { 11130075, new FashionInfo() },
                            { 11130080, new FashionInfo() },
                            { 11130081, new FashionInfo() },
                            { 11130082, new FashionInfo() },
                            { 11130083, new FashionInfo() },
                            { 11130084, new FashionInfo() },
                            { 11130085, new FashionInfo() },
                            { 11130086, new FashionInfo() },
                            { 11130087, new FashionInfo() },
                            { 11130088, new FashionInfo() },
                            { 11130089, new FashionInfo() },
                            { 11130090, new FashionInfo() },
                            { 11130091, new FashionInfo() },
                            { 11130092, new FashionInfo() },
                            { 11130093, new FashionInfo() },
                            { 11130096, new FashionInfo() },
                            { 11130097, new FashionInfo() },
                            { 11130100, new FashionInfo() },
                            { 11130101, new FashionInfo() },
                            { 11130102, new FashionInfo() },
                            { 11130103, new FashionInfo() },
                            { 11130104, new FashionInfo() },
                            { 11130105, new FashionInfo() },
                            { 11130106, new FashionInfo() },
                            { 11130107, new FashionInfo() },
                            { 11130108, new FashionInfo() },
                            { 11130109, new FashionInfo() },
                            { 11130110, new FashionInfo() },
                            { 11130115, new FashionInfo() },
                            { 11130116, new FashionInfo() },
                            { 11130117, new FashionInfo() },
                            { 11130118, new FashionInfo() },
                            { 11130123, new FashionInfo() },
                            { 11130124, new FashionInfo() },
                            { 11130125, new FashionInfo() },
                            { 11130141, new FashionInfo() },
                            { 11130142, new FashionInfo() },
                            { 11130143, new FashionInfo() },
                            { 11130144, new FashionInfo() },
                            { 11198000, new FashionInfo() }
                        },
                        FavoriteFashionIdList = new(),
                        FavoriteFashionSuitIdList = new()
                        {
                            11190001,
                            11190002,
                            11190003,
                            11190004,
                            11190005,
                            11190008,
                            11190010,
                            11190011,
                            11190012,
                            11190013,
                            11190014,
                            11190015,
                            11190017,
                            11190018,
                            11190020,
                            11190022,
                            11190023,
                            11190024,
                            11190025,
                            11190026,
                            11190027,
                            11190029,
                            11190031,
                            11190032,
                            11190034,
                            11190036,
                            11190037,
                            11190038,
                            11190039,
                            11190040,
                            11190041,
                            11190042,
                            11190044,
                            11190045,
                            11190047,
                            11190048,
                            11190049,
                            11190050,
                            11190051,
                            11190052,
                            11190053,
                            11190054,
                            11190055,
                            11190056,
                            11190057,
                            11190058,
                            11190059,
                            11190060,
                            11190061,
                            11190064,
                            11190065,
                            11190066,
                            11190067,
                            11190068,
                            11190069,
                            11190070,
                            11190072,
                            11190073,
                            11190074,
                            11190075,
                            11190076,
                            11190078,
                            11190080,
                            11190081,
                            11190083,
                            11190084,
                            11190085,
                            11190086,
                            11190087,
                            11190088,
                            11190089,
                            11190091,
                            11190092,
                            11190094,
                            11190095,
                            11190097,
                            11190098,
                            11190099,
                            11190100,
                            11190101,
                            11190102,
                            11190104,
                            11190105,
                            11190107,
                            11190108,
                            11190109,
                            11190110,
                            11190111,
                            11190112,
                            11190114,
                            11190115,
                            11190116,
                            11190117,
                            11190119,
                            11190121,
                            11190122,
                            11190124,
                            11190900,
                            11190901,
                            11190902
                        },

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
                            {15020992, new SpiritFashionsInfo()
                            {
                                FashionFunctionSuitSchemeInfoDict=new(),
                                FirstGainSuitIdList=new(),
                                SpiritId=15020992,

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
                            }},
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
                    AvailableSkinParts = new()
                    {
                        11100000,
                        11100002,
                        11100003,
                        11100004,
                        11100005,
                        11100006,
                        11100007,
                        11100008,
                        11100009,
                        11100010,
                        11100012,
                        11100014,
                        11100015,
                        11100016,
                        11100018,
                        11100019,
                        11100021,
                        11100022,
                        11100023,
                        11100031,
                        11100032,
                        11100033,
                        11100034,
                        11100038,
                        11100039,
                        11100040,
                        11100041,
                        11100042,
                        11100043,
                        11100044,
                        11100045,
                        11100048,
                        11100049,
                        11100050,
                        11100051,
                        11100052,
                        11100053,
                        11100056,
                        11100057,
                        11100058,
                        11100059,
                        11100060,
                        11100061,
                        11100062,
                        11100064,
                        11100065,
                        11100066,
                        11100067,
                        11100068,
                        11100074,
                        11100075,
                        11100076,
                        11100077,
                        11100085,
                        11100087,
                        11100090,
                        11100091,
                        11100092,
                        11100093,
                        11100094,
                        11100095,
                        11100097,
                        11100098,
                        11100099,
                        11100104,
                        11120000,
                        11120001,
                        11120002,
                        11120003,
                        11120004,
                        11120005,
                        11120006,
                        11120007,
                        11120008,
                        11120009,
                        11120010,
                        11120012,
                        11120013,
                        11120014,
                        11120016,
                        11120017,
                        11120018,
                        11120021,
                        11120022,
                        11120024,
                        11120025,
                        11120026,
                        11120027,
                        11120028,
                        11120029,
                        11120030,
                        11120031,
                        11120032,
                        11120034,
                        11120036,
                        11120038,
                        11120039,
                        11120040,
                        11120041,
                        11120042,
                        11120043,
                        11120047,
                        11120048,
                        11120049,
                        11120050,
                        11120051,
                        11120052,
                        11120053,
                        11120061,
                        11120062,
                        11120063,
                        11120064,
                        11120065,
                        11120066,
                        11120067,
                        11120068,
                        11120069,
                        11120070,
                        11120072,
                        11120073,
                        11120074,
                        11120075,
                        11120079,
                        11120081,
                        11120082,
                        11120083,
                        11120084,
                        11120085,
                        11120086,
                        11120087,
                        11120088,
                        11120089,
                        11120090,
                        11120091,
                        11120092,
                        11120097,
                        11120098,
                        11120099,
                        11120100,
                        11120101,
                        11120102,
                        11120103,
                        11120104,
                        11120105,
                        11120106,
                        11120107,
                        11120108,
                        11120110,
                        11120111,
                        11120112,
                        11120113,
                        11120114,
                        11120115,
                        11120116,
                        11120117,
                        11120118,
                        11120119,
                        11120120,
                        11120121,
                        11120122,
                        11120123,
                        11120124,
                        11120125,
                        11120127,
                        11120128,
                        11120129,
                        11120130,
                        11120132,
                        11120133,
                        11120134,
                        11120135,
                        11120136,
                        11120137,
                        11120138,
                        11120139,
                        11120140,
                        11120141,
                        11120142,
                        11120143,
                        11120144,
                        11120145,
                        11120150,
                        11120151,
                        11120152,
                        11120154,
                        11120155,
                        11120156,
                        11120157,
                        11120158,
                        11120159,
                        11120160,
                        11120161,
                        11120162,
                        11120163,
                        11120164,
                        11120165,
                        11120166,
                        11120167,
                        11120168,
                        11120169,
                        11120170,
                        11120171,
                        11120172,
                        11120173,
                        11120174,
                        11120175,
                        11120176,
                        11120177,
                        11120179,
                        11120180,
                        11120181,
                        11120182,
                        11120183,
                        11120184,
                        11120185,
                        11120186,
                        11120187,
                        11120188,
                        11120190,
                        11120191,
                        11120192,
                        11120193,
                        11120194,
                        11120195,
                        11120196,
                        11120197,
                        11120198,
                        11120199,
                        11120200,
                        11120201,
                        11120203,
                        11120204,
                        11120205,
                        11120206,
                        11120207,
                        11120208,
                        11120209,
                        11120210,
                        11120211,
                        11120212,
                        11120213,
                        11120214,
                        11120215,
                        11120216,
                        11120217,
                        11120218,
                        11120219,
                        11120220,
                        11120221,
                        11120222,
                        11120223,
                        11120224,
                        11120225,
                        11120226,
                        11120227,
                        11120228,
                        11120229,
                        11120230,
                        11120231,
                        11120232,
                        11120233,
                        11120234,
                        11120235,
                        11120236,
                        11120237,
                        11120238,
                        11120239,
                        11120240,
                        11120241,
                        11120242,
                        11120243,
                        11120244,
                        11120245,
                        11120246,
                        11120247,
                        11120248,
                        11120249,
                        11120250,
                        11120251,
                        11120252,
                        11120253,
                        11120254,
                        11120255,
                        11120256,
                        11120257,
                        11120258,
                        11120259,
                        11120260,
                        11120261,
                        11120262,
                        11120267,
                        11120268,
                        11120269,
                        11120270,
                        11120271,
                        11120272,
                        11120273,
                        11120274,
                        11120275,
                        11120276,
                        11120277,
                        11120278,
                        11120279,
                        11120280,
                        11120281,
                        11120282,
                        11120283,
                        11120284,
                        11120285,
                        11120286,
                        11120288,
                        11120289,
                        11120290,
                        11120291,
                        11120292,
                        11120293,
                        11120294,
                        11120295,
                        11120296,
                        11120297,
                        11120298,
                        11120299,
                        11120300,
                        11120301,
                        11120302,
                        11120303,
                        11120304,
                        11120305,
                        11120306,
                        11120307,
                        11120308,
                        11120309,
                        11120310,
                        11120313,
                        11120314,
                        11120315,
                        11120316,
                        11120317,
                        11120318,
                        11120319,
                        11120320,
                        11120321,
                        11120322,
                        11120323,
                        11120324,
                        11120325,
                        11120326,
                        11120327,
                        11120328,
                        11120329,
                        11120330,
                        11120331,
                        11120351,
                        11130000,
                        11130001,
                        11130002,
                        11130003,
                        11130004,
                        11130006,
                        11130007,
                        11130008,
                        11130009,
                        11130010,
                        11130011,
                        11130012,
                        11130013,
                        11130014,
                        11130015,
                        11130016,
                        11130017,
                        11130018,
                        11130019,
                        11130020,
                        11130021,
                        11130022,
                        11130023,
                        11130024,
                        11130025,
                        11130026,
                        11130027,
                        11130028,
                        11130041,
                        11130042,
                        11130043,
                        11130044,
                        11130045,
                        11130046,
                        11130047,
                        11130048,
                        11130049,
                        11130050,
                        11130051,
                        11130052,
                        11130053,
                        11130054,
                        11130055,
                        11130056,
                        11130057,
                        11130058,
                        11130059,
                        11130060,
                        11130061,
                        11130062,
                        11130063,
                        11130064,
                        11130065,
                        11130066,
                        11130067,
                        11130068,
                        11130069,
                        11130070,
                        11130071,
                        11130072,
                        11130073,
                        11130074,
                        11130075,
                        11130080,
                        11130081,
                        11130082,
                        11130083,
                        11130084,
                        11130085,
                        11130086,
                        11130087,
                        11130088,
                        11130089,
                        11130090,
                        11130091,
                        11130092,
                        11130093,
                        11130096,
                        11130097,
                        11130100,
                        11130101,
                        11130102,
                        11130103,
                        11130104,
                        11130105,
                        11130106,
                        11130107,
                        11130108,
                        11130109,
                        11130110,
                        11130115,
                        11130116,
                        11130117,
                        11130118,
                        11130123,
                        11130124,
                        11130125,
                        11130141,
                        11130142,
                        11130143,
                        11130144,
                        11198000
                    },
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
                VehicleConfigId = 81004002,
                Interactable = true,
                ControllerPid=conn.Pid,
                IsDynamicGo=true,
                
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

        [Handler(MethodId.AskPlayerStartEnterOrExitVehicle)]
        public static void AskPlayerStartEnterOrExitVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlayerStartEnterOrExitVehicle,
            };

            conn.SendPacket(rsp);
        }
    }
}

