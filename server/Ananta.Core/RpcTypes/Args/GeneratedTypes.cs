// Auto-generated from IL2CPP dump - DO NOT EDIT MANUALLY
// Contains enums and helper classes extracted from UX.Game namespace

using System.Collections.Generic;
using AnantaTestGameServer.Methods.Return;

namespace AnantaTestGameServer.Methods
{
    // ===============================================
    // ENUMS
    // ===============================================

    public enum AINodeEventType
    {
        Push = 0,
        Pop = 1,
        Sync = 2
    }

    public enum AINodeStatus
    {
        Inactive = 0,
        Failure = 1,
        Success = 2,
        Running = 3
    }

    public enum AOIEntityType
    {
        Player = 0,
        Enemy = 1,
        Npc = 2,
        Creation = 3,
        Spirit = 4,
        AttractPoint = 5,
        RaidVehicle = 6,
        SpoonAgentAOIStub = 7
    }

    public enum AetherDangerAreaType
    {
        None = 0,
        VehicleArea = 1,
        PedestrianArea = 2
    }

    public enum AetherServerVehicleStopReason
    {
        Set = 0,
        ReachingVehicle = 1,
        EnteringVehicle = 2,
        Paoku = 3,
        Block = 4,
        BehaviorSet = 5,
        TaxiInteract = 6,
        BorrowAnim = 7,
        AgentControl = 8,
        StoryArrest = 9
    }

    public enum AgentActionVehicleTask
    {
        None = 0,
        Stop = 1,
        RegressToTrafficFlow = 2
    }

    public enum AgentCheckNpcTypeType
    {
        Normal = 0,
        Static = 1,
        Vehicle = 2
    }

    public enum AgentCheckUnitTypeType
    {
        Null = 0,
        Agent = 1,
        Player = 2
    }

    public enum AgentControlReason
    {
        Unknown = 0,
        BeforeAttract = 1,
        AfterAttract = 2,
        Attract = 3,
        AddState = 4,
        PedMoveTask = 5,
        PlotPedMoveStart = 6,
        PlotPedMoveEnd = 7,
        PlotPedMovePause = 8,
        PlotPedMoveResume = 9,
        ConvertToPed = 10,
        Story = 11,
        Formation = 12
    }

    public enum AgentStolenType
    {
        None = 0,
        Money = 1,
        Fan = 2
    }

    public enum AoiAddAndRemoveReason
    {
        None = 0,
        Loaded = 1,
        AOIMove = 2,
        Target = 3,
        TargetCondition = 4,
        Sector = 5,
        Quality = 6,
        Other = 7
    }

    public enum AreaType
    {
        None = 0,
        Interest = 1,
        Boxing = 2
    }

    public enum AttractEntityType
    {
        Both_现在不能配 = 0,
        Battle = 1,
        Crowd = 2
    }

    public enum AttractPerceptionFilter
    {
        None = 0,
        Sight = 1,
        Hearing = 2
    }

    public enum AttractPointViewPriority
    {
        None = 0,
        Normal = 1,
        Special = 2
    }

    public enum BarDiceGameResult
    {
        Win = 0,
        Tie = 1,
        Lose = 2
    }

    public enum BasketballOperatorType
    {
        None = 0,
        PickUp = 1,
        Shoot = 2,
        Steal = 3,
        Block = 4
    }

    public enum BattleMoveActionType
    {
        Unknown = 0,
        Idle = 1,
        WalkFront = 2,
        WalkBack = 3,
        WalkLeft = 4,
        WalkRight = 5,
        Run = 6
    }

    public enum BegBehaviorType
    {
        Start = 0,
        SwitchPose = 1,
        Stop = 2,
        StartWithPromotion = 3
    }

    public enum BehaviorAgentType
    {
        Task = 0,
        Acquisition = 1,
        Hack = 2
    }

    public enum BehaviorEntityType
    {
        All = 0,
        Enemy = 1,
        Empty2 = 2,
        TaskClient = 3,
        Empty4 = 4,
        AetherServer = 5,
        PlayerInteractClient = 6,
        FightGroupServer = 7,
        AetherClient = 8,
        CommonClient = 9
    }

    public enum BehaviorSeqCommandGroupType
    {
        Default = 0,
        SoundControl = 1,
        SoundBeControlled = 2
    }

    public enum BehaviorSeqMoveKind
    {
        Custom = 0,
        Walk = 1,
        Run = 2
    }

    public enum BehaviorSeqSelectionConditionType
    {
        CheckDirection = 0,
        CheckDistance = 1
    }

    public enum BehaviorSeqType
    {
        Patrol = 0,
        Attract = 1,
        SmartObject = 2
    }

    public enum BelongingItemState
    {
        BelongToRaid = 0,
        BelongToPlayer = 1,
        BelongToAgent = 2
    }

    public enum BirdGroupState
    {
        Normal = 0,
        Alert = 1
    }

    public enum BoolOrNull
    {
        Null = 0,
        True = 1,
        False = 2
    }

    public enum BowlingGameType
    {
        Single = 0,
        DoubleAI = 1,
        DoublePlayer = 2
    }

    public enum BubbleTriggerPolicy
    {
        Once = 0,
        RepeatableOnReEnter = 1
    }

    public enum CaptureObjectType
    {
        Npc = 0,
        Enemy = 1
    }

    public enum ChangeSingleTaskReason
    {
        Accept = 0,
        TaskCounterAdd = 1,
        Submit = 2,
        Abort = 3,
        Fail = 4,
        ClearSubmit = 5
    }

    public enum ChatType
    {
        Default = 0,
        Right = 1
    }

    public enum CinemaMovieState
    {
        Normal = 0,
        Like = 1,
        Special = 2
    }

    public enum CinemaShowDialogType
    {
        StartLines = 0,
        EndLines = 1,
        StartComment = 2,
        EndComment = 3
    }

    public enum ClientLoadStep
    {
        Loading = 0,
        SceneLoaded = 1,
        LoadingFinished = 2
    }

    public enum ClientUseLevel
    {
        None = 0,
        ExportLuaAndCSharp = 1,
        ExportLuaOnly = 2
    }

    public enum CloseTwitterPanelType
    {
        PhonePanel = 0,
        TwitterPanel = 1
    }

    public enum ControlFlowDataType
    {
        None = 0,
        Double = 1,
        Unit = 2,
        Vehicle = 3,
        Boolean = 4,
        String = 5,
        Uint = 6,
        Int = 7,
        Vector = 8,
        Ulong = 9,
        Float = 10
    }

    public enum ControlFlowDebugActionType
    {
        Start = 0,
        Complete = 1,
        Error = 2,
        Result = 3
    }

    public enum ControlFlowDebugSpoonType
    {
        Spoon = 0,
        SpoonTask = 1,
        SpoonRaidTask = 2,
        Gadget = 3,
        None = 4
    }

    public enum CreationEventType
    {
        Enter = 0,
        Leave = 1
    }

    public enum CrowdClearZoneType
    {
        None = 0,
        PedNpc = 1,
        StaticNpc = 2
    }

    public enum CurveMoveType
    {
        None = 0,
        Circle = 1,
        Ellipse = 2,
        Straight = 3
    }

    public enum DamageEffect
    {
        Normal = 0,
        Crit = 1,
        Miss = 2,
        Resist = 3,
        Invincible = 4,
        ForceKill = 5,
        Block = 6,
        RealDamage = 7,
        FallDamage = 8
    }

    public enum DartGameType
    {
        Dart_High = 0,
        Dart_301 = 1,
        Dart_501 = 2
    }

    public enum DartTiming
    {
        TurnFinish = 0,
        ExceedScore = 1,
        OverTakenScore = 2,
        Success = 3,
        Fail = 4,
        Bust = 5
    }

    public enum DestroyType
    {
        Normal = 0,
        Distance = 1,
        RunAway = 2,
        DisappearImmediately = 3,
        ConvertCrowd = 4,
        FansGiverConvertCrowd = 5,
        FansGiverDisappearImmediately = 6,
        FansGiverDistance = 7
    }

    public enum DestructibleBrokenType
    {
        None = 0,
        Player = 1,
        Mind = 2,
        Physical = 3,
        Enemy = 4
    }

    public enum DestructibleCreateReason
    {
        None = 0,
        Gm = 1,
        FirstMove = 2,
        Task = 3,
        Agent = 4,
        ScripAction = 5,
        SuperMind = 6,
        Merge = 7,
        Disarm = 8,
        Skill = 9,
        Weapon = 10,
        Item = 11,
        Gadget = 12,
        Plate = 13,
        FishGroup = 14,
        Bowling = 15
    }

    public enum DestructibleDisposeReason
    {
        Gm = 0,
        Update = 1,
        Destroy = 2,
        Pickup = 3,
        BreakCoroutineFinish = 4,
        LivingTimeCoroutineFinish = 5,
        Releaser = 6,
        Symbiosis = 7,
        HookerDie = 8,
        AoiRemoveForce = 9,
        TaskSpoonRemove = 10,
        Design = 11,
        PickUpWeapon = 12,
        RemoveWeapon = 13,
        Gadget = 14,
        Merge = 15,
        FishGroup = 16,
        Bowling = 17
    }

    public enum DestructibleHitType
    {
        None = 0,
        Player = 1,
        Skill = 2,
        Vehicle = 3
    }

    public enum DestructibleLeaveHoldType
    {
        All = 0,
        Exit = 1,
        Throw = 2
    }

    public enum DestructibleMindState
    {
        Q = 0,
        Hold = 1,
        Magnet = 2,
        Free = 3
    }

    public enum DestructibleOperation
    {
        TrusteeDisable = 0,
        Break = 1,
        Destroy = 2,
        EnterHold = 3,
        LeaveHoldExit = 4,
        LeaveHoldThrow = 5,
        Raise = 6,
        Q = 7,
        Move = 8,
        HandHold = 9,
        PutDown = 10
    }

    public enum DestructibleState
    {
        Active = 0,
        Break = 1,
        Dispose = 2
    }

    public enum DialogReason
    {
        Client = 0,
        Gm = 1,
        Design = 2,
        Spoon = 3,
        NpcAction = 4,
        NpcInteract = 5,
        AetherAI = 6,
        Metro = 7,
        Robot = 8,
        Cinema = 9,
        TaskRandom = 10,
        CampRandom = 11
    }

    public enum DieType
    {
        None = 0,
        Normal = 1,
        FallOffCliff = 2,
        Suicide = 3,
        Clear = 4,
        Limbo = 5,
        FourWheelVehicleBurst = 6,
        VehicleLoseControl = 7,
        MotorCollide = 8,
        Drowning = 9
    }

    public enum DiscardWeaponReason
    {
        None = 0,
        Discard = 1,
        NewWeaponDiscardTemp = 2,
        Durability = 3,
        Throw = 4,
        Remove = 5,
        RemoveAndDrop = 6,
        Exchange = 7,
        InteractiveDiscard = 8
    }

    public enum DriveState
    {
        Normal = 0,
        EscapeSuccess = 1,
        CatchFail = 2
    }

    public enum DrivingBehaviorControlType
    {
        PC = 0,
        Gamepad = 1
    }

    public enum DroneHitchState
    {
        Attach = 0,
        Detach = 1
    }

    public enum DynamicGoChangeReason
    {
        Gm = 0,
        Spoon = 1,
        SpoonDelay = 2,
        Condition = 3
    }

    public enum E_AIFollowType
    {
        None = 0,
        TargetOffset = 1,
        TargetSpring = 2,
        Guide = 3
    }

    public enum E_AITargetType
    {
        None = 0,
        Vehicle = 1,
        Unit = 2
    }

    public enum E_PartEvent
    {
        None = 0,
        Sound = 1,
        DoorCollider = 2,
        CharacterClip = 3,
        BranchBone = 4,
        SpecialAnimationOver = 5
    }

    public enum E_TaskVehicleCruiseType
    {
        GoToOneTarget = 0,
        GoToTargetInOrderOnce = 1,
        GoToTargetInOrderLoop = 2,
        GoToTargetInOrderLoopInCount = 3,
        GoToTargetInRandomOnce = 4,
        GoToTargetInRandomOneByOne = 5,
        GoToTargetInRandomOneByOneInCount = 6,
        GoToTargetInRandomAlways = 7
    }

    public enum E_VehiclePartType
    {
        Door = 0,
        Trunk = 1,
        Hood = 2,
        Special01 = 3,
        Special02 = 4,
        Special03 = 5,
        Special04 = 6,
        SpecialEnd = 7
    }

    public enum EditInteractionType
    {
        AvatarPic = 0,
        Background = 1
    }

    public enum EnemyDetectState
    {
        None = 0,
        Idle = 1,
        Suspect = 2,
        Alert = 3,
        Fight = 4,
        Wander = 5,
        Search = 6,
        GoHome = 7
    }

    public enum EntityType
    {
        Player = 0,
        Enemy = 1,
        Npc = 2,
        Creation = 3,
        RaidVehicle = 4,
        AttractPoint = 5
    }

    public enum EscapeState
    {
        Normal = 0,
        Arrest_Countdown = 1,
        Escape_Countdown = 2,
        Escape_Failed = 3,
        Escape_Success = 4,
        Escape_Process = 5
    }

    public enum ExerciseRating
    {
        None = 0,
        Good = 1,
        Great = 2,
        Bad = 3
    }

    public enum ExerciseRatingType
    {
        Empty = 0,
        None = 1,
        Good = 2,
        Great = 3,
        Bad = 4
    }

    public enum FashionStatus
    {
        None = 0,
        RedDot = 1
    }

    public enum FerrisWheelTicketType
    {
        None = 0,
        Single = 1,
        Double = 2,
        All = 3
    }

    public enum FightGameDirection
    {
        Left = 0,
        Right = 1
    }

    public enum GameGroundZoneStartReason
    {
        Single = 0,
        Match = 1
    }

    public enum GameGroundZoneState
    {
        Idle = 0,
        Display = 1,
        GameStart = 2,
        GameOver = 3,
        Dispose = 4
    }

    public enum GameGroundZoneSyncReason
    {
        Enter = 0,
        ReEnter = 1,
        Prepare = 2
    }

    public enum GameGroundZoneType
    {
        Dart = 0,
        Chef = 1,
        Bowling = 2,
        Gomoku = 3
    }

    public enum GamePauseReason
    {
        None = 0,
        UI = 1,
        Guide = 2,
        Spoon = 3,
        GamePlay = 4,
        HitSettlement = 5,
        TimeLine = 6,
        Skill = 7,
        Reconnect = 8,
        GM = 9,
        PlayerGuide = 10
    }

    public enum GeneralCutInEndAction
    {
        None = 0,
        Idle = 1,
        Crouch = 2
    }

    public enum GeneralTeleportType
    {
        Normal = 0,
        Effect = 1,
        Gadget = 2
    }

    public enum GetPostType
    {
        All = 0,
        Player = 1
    }

    public enum GmCommandAuthLevel
    {
        Gm = 0,
        Dev = 1,
        Test = 2
    }

    public enum GmCreateNpcType
    {
        Ped = 0,
        StaticNpc = 1
    }

    public enum GomokuAIDifficulty
    {
        Easy = 0,
        Medium = 1,
        Hard = 2
    }

    public enum GomokuGameType
    {
        EndGame = 0,
        DoubleAI = 1,
        DoublePlayer = 2
    }

    public enum HackerPostState
    {
        New = 0,
        Accepted = 1,
        Completed = 2
    }

    public enum HookEventType
    {
        Destructible = 0,
        Agent = 1
    }

    public enum HookUnitType
    {
        Agent = 0
    }

    public enum IdleType
    {
        None = 0,
        Anim = 1,
        Program = 2,
        Range = 3
    }

    public enum InteractActionPosType
    {
        None = 0,
        Point = 1,
        Circle = 2,
        TwoSide = 3
    }

    public enum InteractPlayerActionType
    {
        None = 0,
        GeneralRotation = 1,
        Touch165cm = 2,
        Touch125cm = 3,
        SquatDown = 4,
        Shelter = 5,
        Observe = 6,
        Sit = 7,
        LoopTouch = 8,
        WallTalk = 9,
        WallOverhear = 10,
        BarStool = 11,
        Stall = 12,
        FoodStand = 13,
        GeneralPoint = 14
    }

    public enum InteractionActionState
    {
        None = 0,
        Inviting = 1,
        Playing = 2,
        CancelDisconnet = 3,
        InvitingTimeout = 4,
        Cancel = 5
    }

    public enum ItemReason
    {
        Unknown = 0,
        Gm = 1,
        Mail = 2,
        TestQuestion = 3,
        BindPhone = 4,
        Config = 5,
        Spoon = 6,
        Task = 7,
        TaskEvent = 8,
        LevelUp = 9,
        SystemUnlock = 10,
        SignIn = 11,
        CompoundItem = 12,
        UseItem = 13,
        JumpTask = 14,
        RecycleItem = 15,
        Achievement = 16,
        Guide = 17,
        Gallery = 18,
        NpcShop = 19,
        Invetigator = 20,
        DiDi = 21,
        Taxi = 22,
        Fashion = 23,
        NpcCultivationFavor = 24,
        NpcChatReward = 25,
        Dialog = 26,
        OverflowReturn = 27,
        Stone = 28,
        Mahjong = 29,
        Collection = 30,
        Challenge = 31,
        BVBBreakthrough = 32,
        AccumulateSignIn = 33,
        ClawMachine = 34,
        MiniGameBee = 35,
        Restaurant = 36,
        Firework = 37,
        MaidTea = 38,
        Cinema = 39,
        LiveHouse = 40,
        OnlineTime = 41,
        UnlockNpc = 42,
        TruckJob = 43,
        SpiritTakeJob = 44,
        SpiritPromoteJob = 45,
        NpcProfile = 46,
        NpcProfileTarget = 47,
        NpcProfileActivate = 48,
        FansChanged = 49,
        FactionChanged = 50,
        FactionAreaOccupy = 51,
        FactionAreaEvent = 52,
        RaidReward = 53,
        CombatTraining = 54,
        Enemy = 55,
        Boss = 56,
        SpiritInit = 57,
        WeaponDefaultSkin = 58,
        Buff = 59,
        PickUp = 60,
        Rob = 61,
        PokemonDecomposition = 62,
        PokemonRebuild = 63,
        RepairWeapon = 64,
        Destructible = 65,
        Gadget = 66,
        Mall = 67,
        Charge = 68,
        FirstCharge = 69,
        MonthCard = 70,
        MonthCardCompensate = 71,
        ItemExchange = 72,
        Gacha = 73,
        MallBundle = 74,
        GymPlay = 75,
        DancePlay = 76,
        RestaurantPlay = 77,
        FerrisWheelPlay = 78,
        SunbathPlay = 79,
        HotSpringPlay = 80,
        Activity = 81,
        WorldTriggerEnemy = 82,
        itemExpired = 83,
        SpiritAddExp = 84,
        ExchangeMoney = 85,
        CinemaTicket = 86,
        RestaurantFood = 87,
        FireworkTicket = 88,
        ClawMachineTicket = 89,
        MiniGameTicket = 90,
        FerrisWheelTicket = 91,
        BuyVehicleFromMass = 92,
        Subway = 93,
        PopularityReward = 94,
        PoliceMission = 95,
        PoliceFine = 96,
        PoliceCase = 97,
        PoliceViolation = 98,
        PoliceReturnInvalidVehicleFine = 99,
        NpcCultivationChat = 100,
        NpcCultivationGift = 101,
        NpcCultivationPhoto = 102,
        SpecificAgentDialog = 103,
        NpcCultivationActionInteract = 104,
        ItemProduct = 105,
        ItemBreakdown = 106,
        TalentActive = 107,
        TalentUpLevel = 108,
        TalentReset = 109,
        TalentConvertCommonSpiritTalentExp = 110,
        Beg = 111,
        BegPromotionCost = 112,
        DoctorCure = 113,
        Cleaning = 114,
        BadgeActive = 115,
        GiveToBegger = 116,
        PhoneContactOptionAction = 117,
        QuantumWallet = 118,
        AutoDropFan = 119,
        Arrest = 120,
        Donate = 121,
        Diviner = 122,
        HouseInit = 123,
        AddHouse = 124,
        BartenderPurchaseElement = 125,
        Bartender = 126,
        Chef = 127,
        Hacker = 128,
        Party = 129,
        CityPediaCreditCollect = 130,
        CityPediaCreditAdd = 131,
        CityPediaCreditLevelUp = 132,
        CompetitionSeason = 133,
        GachaDraw = 134,
        GachaMilestone = 135,
        SocialMedia = 136,
        TakeBattlePassItemsByMail = 137,
        ResetBattlePassItems = 138,
        ClaimBattlePassReward = 139,
        GainBattlePassPurchaseReward = 140,
        BuyBattlePassLevel = 141,
        LinkPlanningBoard = 142,
        LinkMultiPlayerSuccess = 143,
        LinkMultiPlayerFail = 144,
        PlanningBoard = 145,
        SpiritAbilityLevelUp = 146
    }

    public enum LandType
    {
        None = 0,
        Waterside = 1
    }

    public enum MahjongChatType
    {
        SystemText = 0,
        SystemGraffito = 1,
        CustomGraffito = 2
    }

    public enum MahjongGameType
    {
        XLCH = 0,
        Reach = 1
    }

    public enum MahjongRoomState
    {
        Idle = 0,
        Display = 1,
        Begin = 2,
        GameOver = 3
    }

    public enum MahjongRoomType
    {
        Invalid = 0,
        TestAi = 1,
        Friend = 2,
        Pve = 3,
        Npc = 4
    }

    public enum MassHideType
    {
        None = 0,
        CrowdNpc = 1,
        SpoonNpc = 2,
        TaskNpc = 3,
        Metro = 4,
        ECSVehicle = 5,
        StaticECSVehicles = 6,
        TaskSpawnedVehicle = 7,
        MilkCar = 8,
        DriveVehicle = 9,
        All = 10
    }

    public enum MassTrafficIntersectionState
    {
        Start = 0,
        Transition = 1,
        Finishing = 2
    }

    public enum MessageCallbackState
    {
        Confirm = 0,
        Cancel = 1,
        Close = 2
    }

    public enum MessageChannel
    {
        P2P = 0,
        World = 1,
        GPS = 2,
        Room = 3,
        PrivateLink = 4,
        PublicLink = 5,
        MatchLink = 6,
        ChatGroup = 7,
        Team = 8
    }

    public enum MjActionType
    {
        Hu = 0,
        AnGang = 1,
        JiaGang = 2,
        MingGang = 3,
        MaoZhuanYu = 4,
        TuiShui = 5,
        ChaDaJiao = 6,
        ChaHuaZhu = 7,
        Reach = 8,
        Interpret = 9
    }

    public enum MjGameStateEnum
    {
        Begin = 0,
        HuanPai = 1,
        HuanPaiOver = 2,
        DingQue = 3,
        Playing = 4,
        Over = 5
    }

    public enum MjHuPattern
    {
        SevenPairs = 0,
        AllTriplets = 1,
        AllRuns = 2
    }

    public enum MjNpcChatType
    {
        CuiCu = 0,
        DianPao = 1,
        MahjongWin = 2
    }

    public enum MjPCGType
    {
        Peng = 0,
        Chi = 1,
        AnGang = 2,
        MingGang = 3,
        JiaGang = 4
    }

    public enum MjType
    {
        None = 0,
        Tong = 1,
        Tiao = 2,
        Wan = 3,
        Feng = 4
    }

    public enum MonitorEventType
    {
        Other = 0,
        Gm = 1,
        All = 2
    }

    public enum MoveGroundType
    {
        Gadget = 0,
        Metro = 1,
        Vehicle = 2
    }

    public enum MoveToPosType
    {
        Walk = 0,
        Run = 1,
        WalkStrafe = 2,
        WalkStrafe_6D = 3,
        RunStrafe_6D = 4,
        QuickRun = 5,
        WalkAim = 6,
        RunAim = 7,
        Sprint = 8,
        Default = 9
    }

    public enum MovementMethod
    {
        Dynamic = 0,
        Walk = 1,
        Run = 2,
        Flee = 3,
        MatchPlayer = 4,
        Appointed = 5,
        FearWalk = 6,
        VariablePaceMove = 7,
        Scurry = 8,
        Rush = 9
    }

    public enum MovieCommentType
    {
        Single = 0,
        Date = 1,
        Special = 2,
        Like = 3,
        DisLlike = 4
    }

    public enum OnDisMonitorTriggerType
    {
        AwayFrom = 0,
        Approach = 1
    }

    public enum OnEnterOrExitVehicleType
    {
        Enter = 0,
        Exit = 1
    }

    public enum OnInteractWithTwitterType
    {
        Favorite = 0,
        Like = 1,
        Comment = 2
    }

    public enum OnPlayerDisMonitorVehicleType
    {
        SpecificVehicle = 0,
        OwnCar = 1
    }

    public enum OnPlayerEnterOrExitVehicleType
    {
        Start = 0,
        Finish = 1
    }

    public enum OnVehicleBrokenCollisionType
    {
        SpecificVehicle = 0,
        OwnCar = 1,
        RelatedVehicle = 2
    }

    public enum OnVehicleEnterAreaType
    {
        None = 0,
        SpecificVehicle = 1,
        OwnCar = 2
    }

    public enum OnVehicleEnterOrExitVehicleMonitorType
    {
        None = 0,
        SpecificVehicle = 1,
        OwnCar = 2,
        PoliceCar = 3
    }

    public enum OnVehicleLeaveAreaType
    {
        None = 0,
        SpecificVehicle = 1,
        OwnCar = 2
    }

    public enum OnVehicleMoveType
    {
        SpecificVehicle = 0,
        OwnCar = 1
    }

    public enum OnVehicleStateChangeType
    {
        None = 0,
        SpecificVehicle = 1,
        OwnCar = 2,
        PoliceCar = 3
    }

    public enum OutOfStuckTeleportType
    {
        None = 0,
        Task = 1,
        Nearest = 2,
        NearestRebirth = 3,
        DefaultRebirth = 4
    }

    public enum PatrolType
    {
        Idle = 0,
        Loop = 1,
        RandomPatrol = 2
    }

    public enum PlayerBattleCampState
    {
        None = 0,
        Enter = 1,
        Battle = 2,
        Exit = 3
    }

    public enum PlayerPoilceChaseCountDownType
    {
        None = 0,
        Success = 1,
        Fail = 2
    }

    public enum PlayerState
    {
        Online = 0,
        Detached = 1,
        Offline = 2
    }

    public enum PlotCheckPlayerDistanceType
    {
        Less = 0,
        Greater = 1,
        LessOrEqual = 2,
        GreaterOrEqual = 3
    }

    public enum PlotLoadingPanelType
    {
        Default = 0,
        BlackTransition = 1,
        TransparentLoading = 2,
        PureBlackLoading = 3,
        BlackLoading = 4,
        TeleportSilent = 5
    }

    public enum PlotLoadingType
    {
        Dynamic = 0,
        ShowLoading = 1,
        NotShowLoading = 2
    }

    public enum PlotTargetType
    {
        Self = 0,
        Vehicle = 1
    }

    public enum PlotUtilityType
    {
        Both = 0,
        Increase = 1,
        Decrease = 2
    }

    public enum PoliceFakeFileState
    {
        None = 0,
        Unlock = 1,
        AcceptTask = 2,
        SubmitTask = 3
    }

    public enum PoseTriggerType
    {
        Start = 0,
        Loop = 1,
        End = 2
    }

    public enum PreSwitchSpiritType
    {
        NoInteraction = 0,
        SceneInteraction = 1,
        NpcInteraction = 2,
        AirSeamless = 3
    }

    public enum PrepareRoomState
    {
        Confirm = 0,
        Prepare = 1,
        Game = 2,
        Settle = 3
    }

    public enum RPCExportOption
    {
        LuaOnly = 0,
        CSharpOnly = 1,
        LuaAndCSharp = 2
    }

    public enum RaidTaskPlayerIndex
    {
        None = 0,
        P1 = 1,
        P2 = 2,
        P3 = 3,
        P4 = 4
    }

    public enum RedSpotType
    {
        EditorButton = 0,
        Avatar = 1,
        Background = 2
    }

    public enum ReviveType
    {
        Force = 0,
        System = 1,
        Revive = 2,
        TeleportRevive = 3,
        TaskRevive = 4
    }

    public enum SceneItemEntityType
    {
        Gadget = 0,
        Destructible = 1,
        Item = 2,
        Plate = 3
    }

    public enum SceneItemHideType
    {
        None = 0,
        GadgetButModel = 1,
        Gadget = 2,
        Destructible = 3,
        All = 4
    }

    public enum ServerMark
    {
        None = 0,
        Switcher = 1,
        Center = 2,
        Db = 3,
        Login = 4,
        Scene = 5,
        Avatar = 6,
        Game = 7,
        Gate = 8,
        Link = 9,
        Team = 10,
        Minor = 11,
        Mahjong = 12,
        IM = 13,
        Match = 14,
        Public = 15,
        LocalGM = 16,
        GMProxy = 17,
        Test = 18,
        Client = 19,
        All = 20
    }

    public enum ServiceTag
    {
        None = 0,
        GateRouteSwitch = 1,
        Notify = 2,
        GMService = 3,
        ClientDirect = 4
    }

    public enum SetPositionType
    {
        Force = 0,
        RejectSync = 1,
        Gm = 2,
        Client = 3,
        Designer = 4,
        Spoon = 5,
        SpoonNoLoading = 6,
        SpoonPlot = 7,
        Revive = 8,
        Portal = 9,
        Teleport = 10,
        GoHome = 11,
        FallOffCliff = 12,
        FallGround = 13,
        TimelineEnd = 14,
        DoorTransfer = 15,
        Taxi = 16,
        House = 17,
        Vehicle = 18,
        OutOfStuck = 19,
        SwitchSpirit = 20,
        BehaviorTree = 21,
        Recover = 22,
        BVBEnterGame = 23,
        BVBLeaveGame = 24,
        StartWorldBattle = 25
    }

    public enum SimulationType
    {
        Empty = 0,
        Mahjong = 1,
        FerriswheelCity = 2,
        Cinema = 3
    }

    public enum SkillHitType
    {
        ServerSelect = 0,
        SphereCollider = 1,
        CuboidCollider = 2,
        OpenCollider = 3,
        ClientFlyEffect = 4,
        Sector = 5,
        Ring = 6,
        MulCube = 7,
        Dynamic = 8,
        OnTarget = 9,
        Cylinder = 10,
        ExpendDestructible = 11
    }

    public enum SkillServerSignal
    {
        ShortPrecast = 0,
        LongPrecast = 1,
        ShortBackSwing = 2,
        LongBackSwing = 3,
        ShortAttach = 4,
        LongAttach = 5,
        SelfDefineSignal = 6
    }

    public enum SkillVisualMotionEnum
    {
        Param1 = 0,
        Param2 = 1,
        Param3 = 2,
        Param4 = 3,
        Param5 = 4
    }

    public enum SoundTriggerTiming
    {
        Start = 0,
        Complete = 1,
        Error = 2
    }

    public enum SpecialAchievementType
    {
        None = 0,
        EagleEye = 1,
        Baobiao = 2,
        Kongxin = 3
    }

    public enum SpiritJobStateType
    {
        Join = 0,
        Work = 1,
        OffWork = 2,
        Promotion = 3,
        Leave = 4
    }

    public enum StimTargetType
    {
        None = 0,
        Player = 1,
        Agent = 2,
        Destructible = 3,
        Position = 4,
        Vehicle = 5
    }

    public enum SubmitNumTypeEnum
    {
        All = 0,
        Any = 1
    }

    public enum SubmitTypeEnum
    {
        Default = 0,
        Auto = 1
    }

    public enum SurrenderVoteValue
    {
        Yes = 0,
        No = 1
    }

    public enum SwitchAuthLevel
    {
        Test = 0,
        Dev = 1
    }

    public enum TaskEventState
    {
        Locked = 0,
        NotAccept = 1,
        Accepted = 2,
        Submited = 3
    }

    public enum TaskVehicleCruiseConfigFlags
    {
        CF_BreakByPlayerWhenAtFront = 0,
        CF_PauseByPlayerWhenAtFront = 1,
        CF_SlowDownWhenArriveTarget = 2,
        CF_DynamicSpeed = 3
    }

    public enum TaskVehiclePathFindFlags
    {
        None = 0,
        IgnoreAlley = 1,
        IgnoreDirection = 2
    }

    public enum TrailerHitchState
    {
        Attach = 0,
        Detach = 1
    }

    public enum TriggerFansAgentInteraction
    {
        AirGestureInteraction = 0,
        BodyInteraction = 1
    }

    public enum TuiteState
    {
        None = 0,
        Publishing = 1,
        Follow = 2,
        Comment = 3,
        Like = 4,
        Favorite = 5
    }

    public enum TwitterBehavior
    {
        ItemVisible = 0,
        VideoFinished = 1,
        CommentBottom = 2
    }

    public enum TwitterPageType
    {
        HomePage = 0,
        DetailPage = 1,
        MinePage = 2,
        SearchPage = 3,
        CollectPage = 4,
        VideoPlayPage = 5
    }

    public enum UnitCamp
    {
        Unknown = 0,
        MonsterDefault = 1,
        PlayerDefault = 2,
        AllNeutral = 3,
        AllFriend = 4,
        AllEnemy = 5,
        Test = 6,
        BVBFriend = 7,
        BVBEnemy = 8,
        XACD = 9,
        XQianJiTiao = 10,
        XXinAnQu = 11,
        XChengZhongQu = 12,
        XQianBoXiang = 13,
        XQu4 = 14,
        XQu5 = 15,
        XQu6 = 16,
        XQuanMoShe = 17,
        XYanFengLianHe = 18,
        XLongZhiTuan = 19,
        XChaoPinBang = 20,
        XKuangBeiYeZhu = 21,
        XTianQiongAnBao = 22,
        XXunWeiShu = 23,
        XHeiJinZu = 24,
        XMiMianBang = 25,
        XDianShiNao = 26,
        XTongYongGuaiWu = 27,
        XHunE = 28,
        XCriminal = 29
    }

    public enum UnitModelBoundingType
    {
        Capsule = 0,
        Box = 1
    }

    public enum UnitRelation
    {
        Enemy = 0,
        Friend = 1,
        Neutral = 2
    }

    public enum VehicleAIStatus
    {
        Pending = 0,
        Running = 1,
        Success = 2,
        Pause = 3,
        Abort = 4,
        Override = 5
    }

    public enum VehicleComponentStatus
    {
        UnknownStatus = 0,
        Normal = 1,
        Damged = 2,
        Destroyed = 3
    }

    public enum VehicleComponentType
    {
        WheelFrontLeft = 0,
        WheelFrontRight = 1,
        WheelRearLeft = 2,
        WheelRearRight = 3
    }

    public enum VehicleDesiredGetWay
    {
        Mass = 0,
        Drop = 1
    }

    public enum VehicleDestroyType
    {
        Immediately = 0,
        Distance = 1,
        FollowDynamicGo = 2,
        KeepAndDistance = 3
    }

    public enum VehicleDoorStateChangeReason
    {
        Open = 0,
        Destroy = 1
    }

    public enum VehicleEventSourceType
    {
        None = 0,
        SpecificVehicle = 1,
        OwnCar = 2,
        PoliceCar = 3,
        RelatedVehicle = 4
    }

    public enum VehicleGamePlaySignal
    {
        PoliceNormal = 0,
        PoliceEscapeSuccess = 1,
        PoliceCatchFail = 2,
        ChaseTooClose = 3,
        ChaseTooFar = 4,
        ChaseOptimalDistance = 5,
        ChaseUndetected = 6,
        ChaseDetectionStart = 7,
        ChaseLeaveCountdownIdle = 8,
        ChaseLeaveCountdownStart = 9,
        CatchToNormal = 10,
        NormalToCatch = 11,
        NormalToEscape = 12,
        EscapeToNormal = 13,
        PlayerPoliceChaseSuccess = 14,
        PlayerPoliceChaseFail = 15,
        PlayerPoliceChaseStartSuccessCountDown = 16,
        PlayerPoliceChaseStartFailCountDown = 17,
        PlayerPoliceChaseNormal = 18
    }

    public enum VehicleGameplayDamageActionType
    {
        Normal = 0,
        ActionLeft = 1,
        ActionRight = 2
    }

    public enum VehicleKillFlagsReason
    {
        ShootToDeath = 0,
        DamageAction = 1,
        CollisionToDeath = 2,
        LoseControl = 3,
        All = 4
    }

    public enum VehicleKillReason
    {
        ShootToDeath = 0,
        DamageAction = 1,
        CollisionToDeath = 2,
        LoseControl = 3,
        All = 4
    }

    public enum VehicleLaneDataStatus
    {
        Normal = 0,
        LaneChangeToLeft = 1,
        LaneChangeToRight = 2,
        Teleport = 3,
        StandBy = 4
    }

    public enum VehiclePartType
    {
        Trunk = 0,
        EngineCover = 1
    }

    public enum VehicleSeatType
    {
        Driver = 0,
        Passenger = 1,
        PreferDriver = 2,
        PreferPassenger = 3
    }

    public enum VehicleStateSignal
    {
        WaterVehicleGrounded = 0,
        WaterVehicleFloating = 1,
        AIVehicleStuck = 2
    }

    public enum VehicleSummonSlotType
    {
        Normal = 0,
        Milk = 1,
        Hacker = 2
    }

    public enum VehicleTaskDrivingFlags
    {
        DFStopForCars = 0,
        DFStopForPeds = 1,
        DFSwerveAroundAllCars = 2,
        DFSteerAroundStationaryCars = 3,
        DFSteerAroundPeds = 4,
        DFSteerAroundObjects = 5,
        DFDontSteerAroundPlayerPed = 6,
        DFStopAtLights = 7,
        DFGoOffRoadWhenAvoiding = 8,
        DFDriveIntoOncomingTraffic = 9,
        DFDriveInReverse = 10,
        DFUseWanderFallbackInsteadOfStraightLine = 11,
        DFAvoidRestrictedAreas = 12,
        DFPreventBackgroundPathfinding = 13,
        DFAdjustCruiseSpeedBasedOnRoadSpeed = 14,
        DFPreventJoinInRoadDirectionWhenMoving = 15,
        DFDontAvoidTarget = 16,
        DFTargetPositionOverridesEntity = 17,
        DFUseShortCutLinks = 18,
        DFChangeLanesAroundObstructions = 19,
        DFAvoidTargetCoors = 20,
        DFUseSwitchedOffNodes = 21,
        DFPreferNavmeshRoute = 22,
        DFSlowDownAroundObstructions = 23,
        DFPlaneTaxiMode = 24,
        DFForceStraightLine = 25,
        DFUseStringPullingAtJunctions = 26,
        DFAvoidAdverseConditions = 27,
        DFAvoidTurns = 28,
        DFExtendRouteWithWanderResults = 29,
        DFAvoidHighways = 30,
        DFForceJoinInRoadDirection = 31,
        DFDontTerminateTaskWhenAchieved = 32,
        DFLastFlag = 33,
        DModeStopForCars = 34,
        DModeStopForCarsStrict = 35,
        DModeAvoidCars = 36,
        DModeEscapeAvoidCars = 37,
        DModeAvoidCarsReckless = 38,
        DModePloughThrough = 39,
        DModeStopForCarsIgnoreLights = 40,
        DModeAvoidCarsObeyLights = 41,
        DModeAvoidCarsStopForPedsObeyLights = 42,
        DModeEscapeAvoidCarsWithoutStop = 43
    }

    public enum VehicleType
    {
        PlayerControl = 0,
        AiControl = 1,
        All = 2
    }

    public enum WayPointMoveArrivalRangeType
    {
        Distance = 0,
        Accurate = 1
    }

    public enum WayPointPatrolCommandType
    {
        Move = 0,
        Rotate = 1,
        Animation = 2,
        Skill = 3,
        Idle = 4,
        Buff = 5,
        MultiAnimation = 6,
        Group = 7,
        DynamicTag = 8,
        Union = 9,
        Behavior = 10,
        Selection = 11
    }

    public enum WeaponDiscardOperatorMode
    {
        CanDiscardByPlayer = 0,
        CannotDiscardByPlayer = 1
    }

    public enum WeaponDisposeOperatorMode
    {
        None = 0,
        EventBinding = 1
    }

    public enum WeaponHoldOperatorMode
    {
        All = 0,
        TempSlot = 1
    }

    public enum WeaponOperatorMode
    {
        Hold = 0,
        Discard = 1,
        Dispose = 2,
        SpecialLabel = 3
    }

    public enum WeaponSpecialLabelOperatorMode
    {
        None = 0,
        SameLabelIgnore = 1,
        SameLabelReplace = 2
    }

    public enum WebpageTriggerType
    {
        Webpage = 0,
        Resource = 1
    }

    // ===============================================
    // HELPER CLASSES
    // ===============================================

    public class AgentClientActionDefine : SerializedClass
    {
        // Empty data class
    }

    public class AttractGroupInfo : SerializedClass
    {
        public uint[] WaitActions;
    }

    public class AttractPointInfo : SerializedClass
    {
        public UXVector3 Position;
        public BehaviorSeq BehaviorSeq;
        public AttractGroupInfo[] GroupInfos;
    }

    public class AttractPointSoundData : SerializedClass
    {
        public uint VoiceLibraryId;
    }

    public class BehaviorSeq : SerializedClass
    {
        public float Angle;
        public UXVector3 Position;
        public BehaviorSeqMoveCommand[] Moves;
        public BehaviorSeqIdleCommand[] Idles;
        public BehaviorSeqRotateCommand[] Rotates;
        public BehaviorSeqAnimationCommand[] Animations;
        public BehaviorSeqAnimationGroupCommand[] AnimationGroups;
        public BehaviorSeqSkillCommand[] Skills;
        public BehaviorSeqBuffCommand[] Buffs;
        public BehaviorSeqDynamicTagCommand[] DynamicTags;
        public BehaviorSeqUnionCommand[] Unions;
        public BehaviorSeqCommandGroup[] CommandGroups;
        public BehaviorSeqBehaviorCommand[] Behaviors;
        public BehaviorSeqSelectionCommand[] SelectionCommands;
        public Group[] Groups;
    }

    public class BehaviorSeqAddBelongingUsageItem : SerializedClass
    {
        public uint UsageId;
    }

    public class BehaviorSeqAnimationCommand : SerializedClass
    {
        public uint ActionId;
        public float OverrideDuration;
        public int LoopCount;
        public bool OverrideActionGroup;
        public uint ActionGroupId;
        public BehaviorSeqVMotionTarget Target1;
        public BehaviorSeqVMotionTarget Target2;
        public BehaviorSeqVMotionTarget[] Targets;
        public UXVector3 blendActionToTargetPos;
        public BehaviorSeqAddBelongingUsageItem[] AddBelongingUsageItems;
        public BehaviorSeqRemoveBelongingUsageItem[] RemoveBelongingUsageItems;
    }

    public class BehaviorSeqAnimationCommandItem : SerializedClass
    {
        public int AnimationCmdIndex;
        public float Weight;
    }

    public class BehaviorSeqAnimationGroupCommand : SerializedClass
    {
        public List<BehaviorSeqAnimationCommandItem> AnimationInfos;
        public int LoopCount;
    }

    public class BehaviorSeqBehaviorCommand : SerializedClass
    {
        public uint BehaviorId;
    }

    public class BehaviorSeqBuffCommand : SerializedClass
    {
        public uint AddBuffId;
        public uint RemoveBuffId;
    }

    public class BehaviorSeqCommandGroup : SerializedClass
    {
        public BehaviorSeqCommandGroupType GroupType;
        public BehaviorSeqCommand[] Commands;
        public int LoopCount;
    }

    public class BehaviorSeqDynamicTagCommand : SerializedClass
    {
        public uint AddDynamicTagId;
        public uint RemoveDynamicTagId;
    }

    public class BehaviorSeqIdleCommand : SerializedClass
    {
        public float TimeRandomStart;
        public float TimeRandomEnd;
    }

    public class BehaviorSeqMoveCommand : SerializedClass
    {
        public uint ActionId;
        public BehaviorSeqMoveKind Kind;
        public CurveMoveType MoveType;
        public float CircleMoveRadius;
        public bool useEndRotate;
        public float rotateSpeed;
        public float startRoteteDis;
        public float Timeout;
        public bool ArrivalOverried;
        public float ArrivalRange;
        public WayPointMoveArrivalRangeType ArrivalRangeType;
        public bool OverrideActionGroup;
        public uint ActionGroupId;
    }

    public class BehaviorSeqRemoveBelongingUsageItem : SerializedClass
    {
        public uint UsageId;
    }

    public class BehaviorSeqRotateCommand : SerializedClass
    {
        public float SmoothFaceSpeed;
        public bool UseAnimation;
    }

    public class BehaviorSeqSelectionCommand : SerializedClass
    {
        public BehaviorSeqSelectionItem[] SelectionItems;
    }

    public class BehaviorSeqSelectionCondition : SerializedClass
    {
        public BehaviorSeqSelectionConditionType ConditionType;
        public bool IsSameDirection;
        public float Distance;
    }

    public class BehaviorSeqSelectionItem : SerializedClass
    {
        public BehaviorSeqSelectionCondition[] Conditions;
        public BehaviorSeqCommand[] Commands;
    }

    public class BehaviorSeqSkillCommand : SerializedClass
    {
        public uint SkillId;
    }

    public class BehaviorSeqUnionCommand : SerializedClass
    {
        public BehaviorSeqCommand BehaviorSeqCommand;
        public int CountNeeded;
        public float TimeOut;
        public int EventName;
    }

    public class BehaviorSeqVMotionTarget : SerializedClass
    {
        public int Type;
        public UXVector3 Position;
        public UXVector3 Rotation;
    }

    public class CardGroup : SerializedClass
    {
        public string Name;
        public List<uint> SpiritList;
    }

    public class ClientBaseEntityData : SerializedClass
    {
        public ulong Id;
        public UXVector3 Position;
        public float Facing;
    }

    public class DSBuffInfo : SerializedClass
    {
        public uint Id;
        public float StartTime;
        public float Duration;
    }

    public class DSSkillItem : SerializedClass
    {
        public uint SpiritId;
        public uint SkillId;
        public int Index;
        public float StartTime;
    }

    public class DamageSimulationConfiguration : SerializedClass
    {
        public List<uint> SpiritIds;
        public uint LevelCaseId;
        public uint EnemyId;
        public uint EnemyLevel;
        public List<DSBuffInfo> TeamBuffs;
        public List<DSBuffInfo> EnemyBuffs;
        public float EpInitPercent;
        public float ChangeAttackPercent;
        public List<DSSkillItem> SkillSequence;
    }

    public class GameSwitchAttribute : SerializedClass
    {
        // Empty data class
    }

    public class GameSwitchDetail : SerializedClass
    {
        // Empty data class
    }

    public class Group : SerializedClass
    {
        public bool Manual;
        public Point[] Points;
    }

    public class IAgentClientData : SerializedClass
    {
        public ulong Uid;
        public float MaxTime;
        public uint ActionUid;
    }

    public class IntList : SerializedClass
    {
        public List<int> Value;
    }

    public class MulticastGroup : SerializedClass
    {
        public readonly ulong Id;
    }

    public class MulticastGroupManager : SerializedClass
    {
        // Empty data class
    }

    public class MulticastTarget : SerializedClass
    {
        public readonly ulong TargetId;
        public readonly int ConnectId;
    }

    public class PatrolBehaviorSeqInfo : SerializedClass
    {
        public int SpoonAgentId;
        public int SeqIndex;
        public int NewHomeSeqIndex;
        public int HashCode;
    }

    public class PatrolData : SerializedClass
    {
        public PatrolBehaviorSeqInfo[] Infos;
        public BehaviorSeq[] BehaviorSeqList;
    }

    public class Point : SerializedClass
    {
        public UXVector3 Position;
        public float Angle;
        public BehaviorSeqCommand[] Commands;
    }

    public class RPCExpose : SerializedClass
    {
        // Empty data class
    }

    public class RaidBattleUnit : SerializedClass
    {
        public ulong Id;
        public EntityType Type;
        public uint SubType;
        public UXVector3 Position;
        public float FacingDirection;
        public uint ModelId;
        public ulong OwnerId;
        public ulong ManagedPid;
        public uint NavTags;
        public uint Level;
        public ulong RecycleNpcInstanceId;
        public OtherPlayerSpiritWearFashionsInfo wearInfo;
        public int SkillId;
        public int HSummonIndex;
        public uint SuitId;
        public ulong ParentId;
        public ulong SourceWeaponId;
        public uint AgentBornWithWeaponId;
        public bool BattleAiS;
        public bool IsBorn;
        public int SpoonAgentId;
    }

    public class ServiceMetaAnnotation : SerializedClass
    {
        public int GateRouteBackend;
        public int ServiceTag;
        public ServerMark RouteWithPid;
    }

    public class SmartObjectQueueData : SerializedClass
    {
        public string Name;
        public UXVector3[] Positions;
        public UXVector3[] Rotations;
        public BehaviorSeq[] BehaviorSeqs;
    }

    public class SmartObjectSingleData : SerializedClass
    {
        public UXVector3 Position;
        public UXVector3 Rotation;
        public BehaviorSeq BehaviorSeq;
    }

    public class TimeManager : SerializedClass
    {
        public double LastDelaySeconds;
        public Action<double> RequireServerTime;
        public double raidStartTime;
    }

    public class TrafficIntersectionPeriodInfo : SerializedClass
    {
        public byte CurrentPeriodIndex;
        public byte NextPeriodIndex;
        public byte RailPeriodIndex;
    }

    public class UXSerializeAttribute : SerializedClass
    {
        // Empty data class
    }

    public class Uint2UintDictionary : SerializedClass
    {
        public Dictionary<uint,uint> Value;
    }

    public class UlongList : SerializedClass
    {
        public List<ulong> Value;
    }

    public class VehicleDestructiblePartStatus : SerializedClass
    {
        public int partID;
        public VehicleComponentStatus dmgStatus;
    }

    public class VehicleDestructiblePartsDamageInfo : SerializedClass
    {
        public ulong vehicleUId;
        public List<VehicleDestructiblePartStatus> damagedGlassList;
        public List<VehicleDestructiblePartStatus> damagedLightList;
        public List<VehicleDestructiblePartStatus> damagedDoorList;
    }

    // ===============================================
    // ADDITIONAL TYPES (from MassAI/other namespaces)
    // ===============================================

    public enum ZoneGraphTag
    {
        None = 0,
        Default = 1,
        Vehicle = 2,
        Polygon = 3,
        Pedestrian = 4,
        Intersection = 5,
        Freeway = 6,
        City = 7,
        TrunkRoad = 8,
        CapillaryRoad = 9,
        Crosswalk = 10,
        SmallIndoor = 11,
        VehicleMedianDivided = 12,
        VehicleAlley = 13,
        VehicleShoulder = 14,
        SmartObjects = 15,
        OneWayStreet = 16,
        PedestrianPerilousPath = 17,
        VehicleDensity2 = 18,
        VehicleDensity3 = 19,
        Danger = 20,
        ClosedLane = 21,
        WaitingLane = 22,
        Obstacles = 23,
        FreewayOnramp = 24,
        FreewayOfframp = 25
    }

    public enum ZoneLaneLinkType : byte
    {
        None = 0,
        Outgoing = 1,
        Incoming = 2,
        Adjacent = 3,
        JustConnect = 4,
        AlleyOutgoing = 5,
        AlleyIncoming = 6,
        UndirectedConnect = 7,
        All = 8
    }

    public enum SpawnLaneType
    {
        TotalLane = 0,
        Between = 1,
        ClearAllVehicleInArea = 2
    }

    public class TrafficLightDesc : SerializedClass
    {
        public UXVector3 position;
        public int cross_index;
        public int cross_type;
        public int ecotope;
        public int light_type;
        public UXVector3 forward;
        public int sheet_type;
        public UXVector3 zbr_center;
    }

    public class HexCell : SerializedClass
    {
        public int q;
        public int r;
        public int s;
        public bool IsOccupied;
    }

}