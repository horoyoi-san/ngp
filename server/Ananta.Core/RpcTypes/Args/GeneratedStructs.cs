using System.Collections.Generic;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using static AnantaTestGameServer.Methods.RPCMethodArgsRequestCreateRoleEx;

namespace AnantaTestGameServer.Methods
{
	public class AIDebugParameter : SerializedClass
	{
		public ulong Id;
		public string BtName;
		public string BtMD5;
		public bool ForceDrive;
		public int Tick;
		public bool Paused;
		public BehaviorEntityType EntityType;
		public List<AINodeData> Nodes;
		public List<AISharedVariableInfo> Variables;
		public AINodeEvent Event;
	}

	public class AINodeData : SerializedClass
	{
		public int TaskId;
		public int TaskIndex;
		public bool Reevaluate;
		public bool Interrupted;
		public AINodeStatus ExecutionStatus;
		public string ErrorMessage;
		public string InfoMessage;
	}

	public class AINodeEvent : SerializedClass
	{
		public AINodeEventType Type;
		public int TaskId;
	}

	public class AISharedVariableInfo : SerializedClass
	{
		public string Key;
		public string Value;
	}

	public class AcceptedTruckOrderInfo : SerializedClass
	{
		public List<TruckJobOrderWrap> Orders;
		public Dictionary<uint, ulong> EventToAgent;
		public AcceptedTruckOrderInfo() { onlyFields = true; }
	}

	public class AccumulateSignInActivityCommonInfo : CommonActivityInfo
	{
		public List<uint> Rewards;
		public List<uint> DisplayReward;
		public AccumulateSignInActivityCommonInfo() { onlyFields = true; }
	}

	public class AccumulateSignInActivityData : ActivityDataBase
	{
		public List<AccumulateSignInData> SignInList;
		public AccumulateSignInActivityData() { onlyFields = true; }
	}

	public class AccumulateSignInData : SerializedClass
	{
		public uint SignInTime;
		public bool IsGot;
		public AccumulateSignInData() { onlyFields = true; }
	}

	public class AchievementCategory : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class AchievementDetail : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class AchievementViewData : SerializedClass
	{
		// No fields found in dump for AchievementViewData
	}

	public class ActivityDataBase : SerializedClass
	{
		public uint CfgId;
		public bool ShowRedPoint;
		public bool IsOutOfDate;
		public ActivityDataBase() { onlyFields = true; }
	}

	public class AddPlacedFurnitureInfo : SerializedClass
	{
		public ulong ParentPlacedInstanceId;
		public uint FurnitureId;
		public UXVector3 Position;
		public UXVector3 Rotation;
	}

	public class AgentCrimeData : SerializedClass
	{
		public uint[] CrimeRecord;
		public uint[] DefaultItems;
		public uint[] DefaultDrugs;
		public int Alcohol;
	}

	public class AgentDestructibleData : DynamicDestructibleData
	{
		public ulong AgentId;
	}

	public class AgentFormationData : SerializedClass
	{
		public uint row;
		public uint col;
		public float rowSpacing;
		public float colSpacing;
	}

	public class AgentPlotDestroyConfig : SerializedClass
	{
		public DestroyType Type;
		public List<UXVector3> RunAwayPositionList;
		public int Distance;
		public float Speed;
	}

	public class AgentPoliceExamAOIData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class AgentQueryDetailInfo : SerializedClass
	{
		public string AgentSpawnType;
		public bool UseForwardGroup;
		public bool ForceFullAoi;
	}

	public class AnimalClientInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class AreaColliderParams : SerializedClass
	{
		public BoxAreaParams BoxAreaParams;
	}

	public class AttractPointSyncInfo : SerializedClass
	{
		public ulong Uid;
		public uint TemplateId;
		public UXVector3 Position;
		public float FacingDirection;
		public AttractPointViewPriority Priority;
		public List<ulong> BsIngAgents;
	}

	public class BVBBattleAgentStatistics : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BVBBonus : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BVBBuffCandidate : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BVBBuffData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BVBPlayerBasicInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BVBPlayerData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BVBSelectPokemonData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BartenderCustomerNormalInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BartenderCustomerSuperInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BartenderCustomerSyncInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BartenderElementInfos : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BartenderGameInfos : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class BasketballAskOperatorParam : SerializedClass
	{
		public BasketballOperatorType OperatorType;
		public ulong BallUid;
		public ulong ActiveUid;
		public ulong PassiveUid;
		public BasketballSyncDelayActionSpecialParam DelayParam;
		public BasketballSyncShootSpecialParam ShootParam;
	}

	public class BasketballSyncDelayActionSpecialParam : SerializedClass
	{
		public float delay;
	}

	public class BasketballSyncOperatorParam : SerializedClass
	{
		public BasketballOperatorType OperatorType;
		public ulong BallUid;
		public ulong ActiveUid;
		public ulong PassiveUid;
		public bool IsSuccess;
		public BasketballSyncDelayActionSpecialParam DelayParam;
		public BasketballSyncShootSpecialParam ShootParam;
	}

	public class BasketballSyncOwnerInfo : SerializedClass
	{
		public Dictionary<ulong, ulong> full;
		public Dictionary<ulong, ulong> addOrUpdate;
		public List<ulong> remove;
	}

	public class BasketballSyncShootSpecialParam : SerializedClass
	{
		public UXVector3 startPos;
		public UXVector3 shootVelocity;
		public float moveTime;
	}

	public class BegBehaviorData : SerializedClass
	{
		// No fields found in dump for BegBehaviorData
	}

	public class BehaviorSeqCommand : SerializedClass
	{
		public WayPointPatrolCommandType Type;
		public int CommandIndex;
	}

	public class BelongItemInfo : SerializedClass
	{
		public ulong InstanceId;
		public uint ConfigId;
		public BelongingItemState BelongingItemState;
		public ulong OwnerId;
		public UXVector3 Position;
		public float Facing;
	}

	public class BelongingDebugInfo : SerializedClass
	{
		public uint AgentId;
	}

	public class BestNpcInfo : SerializedClass
	{
		public uint Id;
		public int Favor;
		public uint Index;
		public bool ShowFavorLevel;
		public bool ShowFavorTime;
		public uint InteractDays;
	}

	public class BillInfo : SerializedClass
	{
		public ulong Pid;
		public int Aid;
		public uint OrderTime;
		public uint ShipTime;
		public uint ChargeId;
		public string GoodsId;
		public string SN;
		public string ConsumeSN;
		public string PayChannel;
		public string AppChannel;
		public string PayMethod;
		public string Platform;
		public string Udid;
		public int GoodsCount;
		public string PayMoney;
		public string FreeMoney;
		public string PayCurrency;
		public int Deduct;
		public string DeductPercent;
		public int FreeYuanBao;
		public int PayYuanBao;
		public int Status;
	}

	public class BirdGroupData : SerializedClass
	{
		public int Id;
		public BirdGroupState State;
		public uint StateStartTime;
	}

	public class BowlingClientInfo : SerializedClass
	{
		public int Type;
		public string Data;
	}

	public class BowlingParticipantInfo : SerializedClass
	{
		// No fields found in dump for BowlingParticipantInfo
	}

	public class BowlingParticipantScoreInfo : SerializedClass
	{
		public List<int> ThrowScores;
		public List<int> FrameScores;
	}

	public class BowlingScoreInfo : SerializedClass
	{
		public Dictionary<int, BowlingParticipantScoreInfo> BowlingScoreDict;
		public int Winner;
	}

	public class BowlingZoneInfo : GameGroundZoneInfo
	{
		public BowlingGameType GameType;
		public uint CurrentRound;
		public uint CurrentSubRound;
		public int CurrentTurn;
		public BowlingScoreInfo ScoreInfo;
		public List<ulong> BowlingPinSceneItemIdList;
		public List<ulong> BowlingBallSceneItemIdList;
	}

	public class BoxAreaParams : SerializedClass
	{
		public UXVector3 Center;
		public UXVector3 Extents;
		public SerializeQuaternion InversedRotation;
	}

	public class BuyFoodInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class ByteAngle : SerializedClass
	{
		public byte Value;
	}

	public class CargoInfo : SerializedClass
	{
		public uint CargoId;
		public TruckPosInfo StartPos;
		public int Integrity;
		public CargoInfo() { onlyFields = true; }
	}

	public class CentripetalVelocityData : SerializedClass
	{
		public UXVector3 Center;
		public float Speed;
	}

	public class ChallengeResult : SerializedClass
	{
		// No fields found in dump for ChallengeResult
	}

	public class ChangePlacedFurnitureInfo : SerializedClass
	{
		public ulong PlacedInstanceId;
		public bool IsChangeParentNode;
		public ulong ParentPlacedInstanceId;
		public UXVector3 Position;
		public UXVector3 Rotation;
	}

	public class ChaosTagInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class CharacterBelongingItem : SerializedClass
	{
		public ulong InstanceId;
		public uint ConfigId;
		public float Hp;
	}

	public class ChargeDeliveryResult : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class ChaseParameters : VehicleAITaskParameters
	{
		public E_AITargetType TargetType;
		public ulong TargetUid;
		public float MaxSpeed;
		public string chaseFormationName;
		public float enterChaseFormationDistance;
		public float exitChaseFormationDistance;
		public float targetSlowdownDistanceMaxThreshold;
		public float targetSlowdownDistanceMinThreshold;
		public float targetSlowdownSpeedThreshold;
		public float throttleRatioWhenTargetSlowDown;
		public VehicleRamMove vehicleRamMove;
		public VehicleBlockMove vehicleBlockMove;
		public bool enableDelayTarget;
		public float minClosetDistanceUpdateTargetTime;
		public float maxClosetDistanceUpdateTargetTime;
		public float straightLineDistanceInCloseDistance;
		public float straightLineDistanceInPursue;
	}

	public class ChatGroupClient : SerializedClass
	{
		public ulong Id;
		public uint CreateTime;
		public ulong Owner;
		public List<ulong> Members;
		public string Name;
		public bool RejectMsg;
	}

	public class ChatHint : SerializedClass
	{
		public NameCard NameCard;
		public int Count;
	}

	public class ChatMessage : SerializedClass
	{
		public ulong MessageId;
		public MessageChannel Channel;
		public ulong Pid;
		public ulong Receiver;
		public uint Time;
		public bool IsAudio;
		public string Content;
		public int SystemMessageId;
	}

	public class ChatMessagesBlob : SerializedClass
	{
		public List<ChatMessage> Messages;
	}

	public class CheckAgentDistanceInfo : SerializedClass
	{
		public List<int> Distance;
	}

	public class CheckPointAction : SerializedClass
	{
		public int wayPointIndex;
		public int opType;
		public float duration;
		public uint aetherActionId;
		public uint conversationId;
		public string[] dialogueSpeakers;
		public ulong[] dialogueBindUnits;
		public bool wayLeaderDontWait;
		public MovementMethod targetPace;
	}

	public class ChefParticipantInfo : SerializedClass
	{
		// No fields found in dump for ChefParticipantInfo
	}

	public class ChefZoneInfo : SerializedClass
	{
		// No fields found in dump for ChefZoneInfo
	}

	public class CinemaMultiTicketInfo : SerializedClass
	{
		public uint LocationId;
		public uint CinemaId;
	}

	public class CinemaTicketInfo : SerializedClass
	{
		public uint LocationId;
		public uint CinemaId;
		public uint MovieId;
		public uint CompanionNpcId;
		public uint CinemaNpcId;
		public ulong InviteNpcId;
		public bool IsDate;
		public MovieCommentType CommentType;
		public uint StartTime;
		public uint EndTime;
		public CinemaMovieState State;
		public bool IsTask;
	}

	public class ClawDateClientInfo : SerializedClass
	{
		public uint HideNpcId;
		public int FailTimes;
		public uint FavorToyId;
		public uint DateNpcId;
		public ClawDateClientInfo() { onlyFields = true; }
	}

	public class ClawSettlementInfo : SerializedClass
	{
		public uint ClawToyId;
		public uint NpcId;
		public bool Date;
		public ClawSettlementInfo() { onlyFields = true; }
	}

	public class ClientActionAgentAnimation : ClientActionParameter
	{
		public ClientActionTarget Target;
		public uint animId;
		public int selectedActionIndex;
		public float speed;
	}

	public class ClientActionAgentAvoidDangerMove : ClientActionParameter
	{
		public ClientActionTarget Target;
		public float dangerRadius;
		public float dangerDuration;
		public float updatePosTolerance;
		public float dangerDirRefreshLaneTime;
		public float dangerDirHalfAngle;
		public int specificMethod;
		public float speed;
		public float runChasingDistance;
	}

	public class ClientActionAgentAvoidVehicleMove : ClientActionAgentMove
	{
		public ulong Vehicle;
		public float exitWaitTime;
	}

	public class ClientActionAgentCanSeeTarget : ClientConditionalParameter
	{
		public ClientActionTarget Target;
		public float distance;
		public float halfAngle;
		public bool useHead;
	}

	public class ClientActionAgentCheckVehicleCollisionImpulse : ClientConditionalParameter
	{
		public ulong vehicle;
		public int operation;
		public float rightFloat;
	}

	public class ClientActionAgentFaceTo : ClientActionParameter
	{
		public ClientActionTarget Target;
		public float tolerance;
	}

	public class ClientActionAgentFavorInteract : ClientActionParameter
	{
		public ulong PlayerId;
		public uint SingleInteractType;
		public uint MultiInteractType;
	}

	public class ClientActionAgentFocusOn : ClientActionParameter
	{
		public ClientActionTarget Target;
		public int focusLevel;
		public float focusTime;
		public float tolerance;
	}

	public class ClientActionAgentFollow : ClientActionAgentNavigationMove
	{
		public float comfortRange;
		public bool towardTarget;
		public List<RangeMoveType> distances;
	}

	public class ClientActionAgentGetInVehicle : ClientActionParameter
	{
		public ulong vehicle;
		public byte seatIndex;
		public bool HasDoorInteract;
		public List<RangeMoveType> distances;
	}

	public class ClientActionAgentGetSitUp : SerializedClass
	{
		// No fields found in dump for ClientActionAgentGetSitUp
	}

	public class ClientActionAgentHitSomething : ClientActionAgentAnimation
	{
		public float hitForce;
		public float hitRadius;
		public int hitPart;
		public int secondHitPart;
		public int hitLayer;
		public PlotMinMaxRange hitTiming;
	}

	public class ClientActionAgentIKMotion : ClientActionAgentAnimation
	{
		public int IKTargetBone;
	}

	public class ClientActionAgentInteract2 : ClientActionParameter
	{
		public ClientActionTarget Target;
		public uint InteractType;
	}

	public class ClientActionAgentIsVehicleBlockedByPlayer : ClientConditionalParameter
	{
		public ulong vehicle;
	}

	public class ClientActionAgentLookAt : ClientActionParameter
	{
		public ClientActionTarget Target;
		public bool isOn;
		public int targetType;
		public UXVector3 targetPosition;
		public bool isKeep;
		public bool isFinishOnEnd;
		public float duration;
		public int ikPriority;
		public int lookAtIKType;
		public int agentTargetPart;
	}

	public class ClientActionAgentMove : ClientActionParameter
	{
		public ClientActionTarget Target;
		public float arriveDistance;
		public int SpecificMethod;
		public float directionTolerance;
		public bool tryMatchStep;
		public bool keepUpdateTargetPosition;
		public float runChasingDistance;
		public float speed;
		public uint moveActionId;
		public uint moveActionGroup;
		public bool notTowardToTarget;
	}

	public class ClientActionAgentMoveToVehicle : ClientActionParameter
	{
		public ulong vehicle;
		public int seatIndex;
		public List<RangeMoveType> distances;
	}

	public class ClientActionAgentNavigationMove : ClientActionAgentMove
	{
		public float navigationTolerance;
		public float selfNavigationTolerance;
		public bool failedWhenNavigationFailed;
	}

	public class ClientActionAgentOstrichMove : ClientActionParameter
	{
		public UXVector3[] Positions;
	}

	public class ClientActionAgentSelectedActionAnimation : ClientActionParameter
	{
		public ClientActionTarget Target;
		public uint[] animationIds;
		public PlotTargetType baseObject;
		public ulong baseVehicle;
		public int targetType;
		public bool reverse;
		public int selectAngleType;
		public float[] angleRange;
	}

	public class ClientActionAgentTargetIsRunning : ClientConditionalParameter
	{
		public ClientActionTarget Target;
	}

	public class ClientActionAgentTaskMove : ClientActionParameter
	{
		public ClientActionTarget targetObject;
		public float arriveDistance;
		public UXVector3 targetPosition;
		public UXVector3 targetDirection;
		public int SpecificMethod;
		public float directionTolerance;
		public bool tryMatchStep;
		public float runChasingDistance;
		public float speed;
		public uint moveActionId;
		public uint moveActionGroup;
		public bool noRootMotion;
		public bool towardTarget;
	}

	public class ClientActionAgentTaskWayPointMove : ClientActionParameter
	{
		public MovementMethod SpecificMethod;
		public float speed;
		public uint moveActionId;
		public bool noRootMotion;
		public uint moveActionGroup;
		public List<UXVector3> wayPoints;
	}

	public class ClientActionAgentTurn : ClientActionParameter
	{
		public ClientActionTarget Target;
		public float directionTolerance;
	}

	public class ClientActionAgentXAgentMultiInteract : ClientActionParameter
	{
		public ulong AnotherAgentId;
		public uint MultiInteractType;
	}

	public class ClientActionBehaviorTree : ClientActionParameter
	{
		public string BehaviorTree;
	}

	public class ClientActionBreak : SerializedClass
	{
		public ulong AgentId;
		public ulong Token;
		public string Debug;
	}

	public class ClientActionCheckNpcAnimState : ClientConditionalParameter
	{
		public int npcAnimState;
	}

	public class ClientActionCheckPointPathMove : ClientActionParameter
	{
		public UXVector3[] wayPoints;
		public CheckPointAction[] checkPointActions;
		public MovementMethod specificMethod;
		public MovementMethod startPace;
		public float startPaceDuration;
		public uint animationSetId;
		public float speed;
		public uint moveActionId;
		public uint moveActionGroupId;
		public bool notOnGround;
		public bool tryUseRootMotion;
	}

	public class ClientActionGetOutVehicle : SerializedClass
	{
		// No fields found in dump for ClientActionGetOutVehicle
	}

	public class ClientActionLeadingWayMove : ClientActionParameter
	{
		public ulong partner;
		public bool isDirector;
		public UXVector3[] wayPoints;
		public CheckPointAction[] checkPointActions;
		public MovementMethod moveMethod;
		public MovementMethod startPace;
		public float startPaceDuration;
		public uint animationSetId;
		public float speed;
		public uint moveActionId;
		public uint moveActionGroupId;
		public bool notOnGround;
		public bool tryUseRootMotion;
		public bool leadingBreakTurn;
		public bool isLeadingWay;
		public bool dontLimitExtraMove;
		public bool dontLimitBasicMove;
		public uint waitingDialogId;
		public float minDialogDuration;
		public LeadingWayUrging[] leadingWayUrgings;
		public uint leadingWayCfgId;
	}

	public class ClientActionParameter : SerializedClass
	{
		public ulong AgentId;
		public ulong Token;
		public string Debug;
	}

	public class ClientActionPoliceAssistCloseVehicleDoor : ClientActionParameter
	{
		public ulong vehicle;
		public byte seatIndex;
		public List<RangeMoveType> distances;
	}

	public class ClientActionPoliceAssistOpenVehicleDoor : ClientActionParameter
	{
		public ulong vehicle;
		public byte seatIndex;
		public List<RangeMoveType> distances;
	}

	public class ClientActionReactTraitFree : SerializedClass
	{
		// No fields found in dump for ClientActionReactTraitFree
	}

	public class ClientActionShowConversation : ClientActionParameter
	{
		public uint dialogueId;
		public bool lookTarget;
		public string[] dialogueSpeakers;
		public ulong[] dialogueBindUnits;
		public bool isRestart;
		public float resumeDelay;
		public bool isGeneralDialog;
		public bool clearPreDialogueTasks;
		public float yawAngleLimit;
		public float pitchAngleLimit;
	}

	public class ClientActionTarget : SerializedClass
	{
		public ulong Id;
		public UXVector3 Position;
		public StimTargetType Type;
	}

	public class ClientActionTruckUAVAutoDrive : ClientActionParameter
	{
		public UXVector3 Destination;
	}

	public class ClientActionTruckUAVPutDown : SerializedClass
	{
		// No fields found in dump for ClientActionTruckUAVPutDown
	}

	public class ClientActionTruckUAVPutUp : SerializedClass
	{
		// No fields found in dump for ClientActionTruckUAVPutUp
	}

	public class ClientActionUAVFollow : ClientActionParameter
	{
		public ulong Target;
		public float ArriveDistance;
		public float Speed;
	}

	public class ClientActionVehicleRequisition : ClientActionParameter
	{
		public ulong VehicleId;
		public byte BorrowedSeatIndex;
		public byte NpcSeatIndex;
	}

	public class ClientActivityInfo : SerializedClass
	{
		public CommonActivityInfo BaseActivityInfo;
		public ActivityDataBase ActivityData;
		public ClientActivityInfo() { onlyFields = true; }
	}

	public class ClientAgentBubbleConfig : SerializedClass
	{
		public uint BubbleId;
		public BubbleTriggerPolicy TriggerPolicy;
		public int Priority;
		public float Cooldown;
	}

	public class ClientAgentBubbleConfigs : SerializedClass
	{
		public ulong EntityId;
		public ClientAgentBubbleSensorRange SensorRange;
		public List<ClientAgentBubbleConfig> Configs;
	}

	public class ClientAgentBubbleSensorRange : SerializedClass
	{
		public float HeightDiff;
		public float RadiusSq;
		public float ExpandRadiusSq;
		public float LeftAngleBorder;
		public float RightAngleBorder;
	}

	public class ClientBoardingInfo : SerializedClass
	{
		public ulong EntityId;
		public ulong VehicleUId;
		public byte SeatIndex;
		public UXVector3 PositionOffset;
		public UXVector3 RotationOffset;
		public bool CanBeEjected;
		public bool UseSpecificAction;
		public uint ActionGroup;
		public uint ActionId;
	}

	public class ClientCommandData : SerializedClass
	{
		public string Name;
		public string Sign;
		public string Comment;
	}

	public class ClientCompetitionSeasonInfo : SerializedClass
	{
		public CommonCompetitionSeasonInfo CommonSeasonInfo;
		public CompetitionSeasonInfo SeasonInfo;
		public ClientCompetitionSeasonInfo() { onlyFields = true; }
	}

	public class ClientConditionalParameter : SerializedClass
	{
		public ulong AgentId;
		public ulong Token;
	}

	public class ClientCustomData : SerializedClass
	{
		public int Type;
		public double[] ParametersDouble;
		public ulong[] ParametersULong;
		public uint[] ParametersUInt;
		public UXVector3[] ParametersVector3;
		public double ExpireTime;
	}

	public class ClientDangerAreaData : SerializedClass
	{
		public ulong Id;
		public UXVector3 Center;
		public UXVector3 Extents;
		public float Duration;
		public float RemoveRadiusSq;
		public bool IsOBB;
		public UXVector3 OBBExtents;
		public UXVector3 InverseRotation;
		public float Radius;
	}

	public class ClientDetectEventData : SerializedClass
	{
		public ulong detectorPid;
		public ulong detectedPid;
		public int detectValue;
		public UXVector3 Position;
	}

	public class ClientFinishedTruckOrderView : SerializedClass
	{
		// No fields found in dump for ClientFinishedTruckOrderView
	}

	public class ClientFormationMember : SerializedClass
	{
		public ulong InstanceId;
		public UXVector3 Offset;
	}

	public class ClientFormationStructureUpdate : SerializedClass
	{
		public ulong Id;
		public UXVector3 Position;
		public float Facing;
		public MovementMethod TraceType;
		public List<ClientFormationMember> Members;
	}

	public class ClientFpsInfo : SerializedClass
	{
		public string fps_list;
		public string fps3_list;
		public string fps99_list;
		public string list_item_format;
	}

	public class ClientIntersectionDebugData : SerializedClass
	{
		public ulong Id;
		public int ZoneIndex;
		public int PeriodCount;
		public int CurrentPeriodIndex;
		public int NextPeriodIndex;
		public MassTrafficIntersectionState CurrentState;
		public UXVector3 Position;
		public List<int> LaneHandlesOpen;
		public List<ClientLaneVehicleCountDebugData> LaneVehicleCountDebugData;
	}

	public class ClientLaneVehicleCountDebugData : SerializedClass
	{
		public bool PedLane;
		public int LaneHandle;
		public int Count;
	}

	public class ClientNpcDebugDensityStatistics : SerializedClass
	{
		public float PedArea;
		public float NonScaleExceptedPedNum;
		public float ExceptedPedNum;
		public float ActualPedNum;
		public float ExceptedStaticNum;
		public float ActualStaticNum;
		public float ActualVehicleNpcNum;
		public float ActualMetroNpcNum;
	}

	public class ClientNpcMoveData : SerializedClass
	{
		public ulong InstanceId;
		public UXVector3 Position;
		public float Facing;
	}

	public class ClientNpcPlayAnimationData : SerializedClass
	{
		public ulong Id;
		public uint PoiActionId;
		public double StartTime;
	}

	public class ClientPedData : SerializedClass
	{
		public int Id;
		public uint NpcFormworkId;
		public UXVector3 Position;
		public int ActionId;
	}

	public class ClientQualitySetting : SerializedClass
	{
		public string setting;
	}

	public class ClientTeamInfo : SerializedClass
	{
		// No fields found in dump for ClientTeamInfo
	}

	public class ClientTrafficIntersectionPeriodUpdateInfo : TrafficIntersectionPeriodInfo
	{
		public ulong IntersectionIndex;
		public MassTrafficIntersectionState CurrentState;
	}

	public class ClientTruckOrderView : SerializedClass
	{
		public List<TruckOrderWrap> Orders;
		public int RewardPointSum;
		public float CustomerSatisfactionAverage;
		public uint CurrentOrderId;
		public bool TruckGuideClicked;
		public Dictionary<uint, ulong> EventIdToAgent;
		public bool AutoAccept;
		public uint DefaultVehicleId;
		public int TotalIncome;
	}

	public class TruckOrderWrap : SerializedClass
	{
		public TruckOrderInfo OrderInfo;
		public uint UniqueId;
		public uint OrderInfoStartTime;
		public TruckAcceptInfo AcceptInfo;
		public TruckResultInfo ResultInfo;
		public bool CargoPickedUp;
		public float CargoIntegrity;
	}

	public class TruckOrderInfo : SerializedClass
	{
		public TruckWayPointInfo StartPos;
		public TruckWayPointInfo EndPos;
		public uint CargoId;
		public TruckDeliveryNpcInfo DeliveryNpc;
		public bool IsEmergency;
		public int LimitAcceptSeconds;
		public int LimitFinishSeconds;
		public int EstimatedFinishSeconds;
		public List<TruckCargoInfo> CargoInfoList;
		public int BasePointReward;
		public float DropCoefficient;
		public int DropMoney;
		public uint SpecialOrderId;
		public int SpecialPointReward;
		public float AddDropCoefficient;
		public uint ActivityIndex;
		public bool IsHighValue;
		public uint RandomOrderId;
		public bool IsDailyOrder;
		public uint OrderType;
	}

	public class TruckAcceptInfo : SerializedClass
	{
		public uint AcceptedEventId;
		public uint AcceptTime;
	}

	public class TruckResultInfo : SerializedClass
	{
		public uint FinishTime;
		public int CargoIntegrity;
		public uint DropId;
		public float DropCoefficient;
		public int RewardPoint;
		public byte Evaluation;
		public float CustomerSatisfaction;
		public int DropMoney;
		public bool Dropped;
		public bool IsCargoNear;
		public List<uint> AddBuffList;
		public List<uint> RemoveBuffList;
		public uint OrderDeliverUpSetId;
		public uint DeliverUpset;
	}

	public class TruckWayPointInfo : SerializedClass
	{
		public int WpId;
		public uint ConfigId;
		public UXVector3 Pos;
		public UXVector3 Rot;
		public ulong GadgetUId;
	}

	public class TruckDeliveryNpcInfo : SerializedClass
	{
		public uint NpcId;
		public uint ConsigneeId;
		public uint RudeId;
		public uint CharacterId;
	}

	public class TruckCargoInfo : SerializedClass
	{
		public uint CargoId;
		public TruckWayPointInfo StartPos;
		public int Integrity;
		public bool IsCargoNear;
		public ulong UniqueId;
	}

	public class ClientVehicleBuffData : SerializedClass
	{
		public ulong InstanceId;
		public uint BuffConfigId;
		public double EffectChangeEndTime;
		public double ExpireTime;
	}

	public class ClientVehicleDebugData : SerializedClass
	{
		public ulong Id;
		public string VehicleLogicType;
		public string CurrentVehicleStatus;
		public int CurrentLaneHandle;
		public int NextLaneHandle;
		public float DistanceToAvoid;
		public ulong NextVehicleId;
		public ulong NextMergingVehicleId;
		public ulong NextSplittingVehicleId;
		public List<uint> FindIdList;
	}

	public class ClientVehicleLaneChangeData : SerializedClass
	{
		public ClientVehicleLaneData VehicleLaneData;
		public int LaneHandleInitial;
		public int LaneHandleFinal;
		public float BeginDistanceAloneLaneInitial;
		public float BeginDistanceAloneLaneFinal;
		public float EndDistanceAlongLaneFinal;
		public float DistanceBetweenLanes;
	}

	public class ClientVehicleLaneData : SerializedClass
	{
		public ulong Id;
		public int LaneHandle;
		public float DistanceAlongLane;
		public VehicleLaneDataStatus Status;
	}

	public class ClientVehicleLaneDebugData : SerializedClass
	{
		public int LaneHandle;
		public UXVector3 Position;
		public float LaneLength;
		public float SpaceAvailable;
		public int NumVehicleOnLane;
	}

	public class ClientVehiclePartStatus : SerializedClass
	{
		public VehiclePartType PartType;
		public bool OpenOrClose;
	}

	public class ClientZoneGraphPath : SerializedClass
	{
		public ulong Id;
		public ZoneGraphTargetLocationReason TargetLocationReason;
		public ushort ActionId;
		public List<ClientZoneGraphPathPoint> Points;
	}

	public class ClientZoneGraphPathFollowDown : SerializedClass
	{
		public ulong Id;
		public ushort ActionId;
	}

	public class CommonActivityInfo : SerializedClass
	{
		public uint CfgId;
		public uint StartTime;
		public uint EndTime;
		public CommonActivityInfo() { onlyFields = true; }
	}

	public class CommonCompetitionSeasonInfo : SerializedClass
	{
		public uint CfgId;
		public uint StartTime;
		public uint EndTime;
		public CommonCompetitionSeasonInfo() { onlyFields = true; }
	}

	public class CompetitionSeasonChallengeInfo : SerializedClass
	{
		public uint ChallengeCfgId;
		public int HistoryHighestStars;
		public int LastStars;
		public CompetitionSeasonChallengeInfo() { onlyFields = true; }
	}

	public class CompetitionSeasonGamePlayInfo : SerializedClass
	{
		public uint GamePlayCfgId;
		public Dictionary<uint, CompetitionSeasonChallengeInfo> ChallengeDict;
		public int Stars;
		public CompetitionSeasonGamePlayInfo() { onlyFields = true; }
	}

	public class CompetitionSeasonInfo : SerializedClass
	{
		public uint CfgId;
		public Dictionary<uint, CompetitionSeasonGamePlayInfo> GameplayDict;
		public List<uint> AwardList;
		public bool IsFinish;
		public CompetitionSeasonInfo() { onlyFields = true; }
	}

	public class ControlFlowData : SerializedClass
	{
		public int PortId;
	}

	public class ControlFlowDataBoolean : ControlFlowData
	{
		public bool V;
	}

	public class ControlFlowDataCustom : ControlFlowData
	{
		public string V;
		public ControlFlowDataType Type;
	}

	public class ControlFlowDataDebug : SerializedClass
	{
		public int Index;
		public List<int> CurrentNodeIds;
		public List<int> CompleteNodeIds;
		public List<int> ErrorNodeIds;
		public Dictionary<int, string> ResultNodeIds;
	}

	public class ControlFlowDataDouble : ControlFlowData
	{
		public double V;
	}

	public class ControlFlowDataInteger : ControlFlowData
	{
		public int V;
	}

	public class ControlFlowDataString : ControlFlowData
	{
		public string V;
	}

	public class ControlFlowDataUInteger : ControlFlowData
	{
		public uint V;
	}

	public class ControlFlowDataUlong : ControlFlowData
	{
		public ulong V;
	}

	public class ControlFlowDataUnit : ControlFlowData
	{
		public ulong V;
	}

	public class ControlFlowDataVector : ControlFlowData
	{
		public UXVector3 V;
	}

	public class ControlFlowDataVehicle : ControlFlowData
	{
		public ulong V;
	}

	public class CreationEnterLeave : SerializedClass
	{
		public ulong TargetId;
		public ulong CreationId;
		public CreationEventType EventType;
	}

	public class CreationHitData : SerializedClass
	{
		public ulong CreationId;
		public ulong TargetId;
		public ulong TargetDestructible;
		public int ShieldDefendIndex;
		public uint HurtStiffId;
		public float StiffTime;
		public uint HurtEffectId;
	}

	public class CreationMoveData : SerializedClass
	{
		public ulong CreationId;
		public UXVector3 Position;
		public UXVector3 Rotation;
	}

	public class CruiseParameters : VehicleAITaskParameters
	{
		public List<UXVector3> TargetPointList;
		public E_TaskVehicleCruiseType CruiseType;
		public int Count;
		public TaskVehicleCruiseConfigFlags configFlags;
		public TaskVehiclePathFindFlags pathFindFlags;
		public E_AITargetType TargetType;
		public ulong TargetUid;
		public bool checkClose;
		public bool checkFar;
		public float closeRange;
		public float farawayRange;
		public float accelerateScale;
		public float decelerateScale;
		public float minSpeed;
		public float maxSpeed;
		public float ArrivalDistance;
	}

	public class CubeCoord : SerializedClass
	{
		public int q;
		public int r;
		public int s;
	}

	public class CurveMoveData : SerializedClass
	{
		public CurveMoveType CurveType;
		public UXVector3 StartPoint;
		public UXVector3 AuxiliaryPoint;
		public UXVector3 EndPoint;
		public float CircleMoveRadius;
		public int MoveId;
		public uint ActionId;
	}

	public class DSBuffData : SerializedClass
	{
		public uint BuffId;
		public double StartTime;
		public double EndTime;
	}

	public class DSDamageData : SerializedClass
	{
		public List<DSSpiritDamageData> SpiritDatas;
		public List<DSElementDamageData> ElementDatas;
	}

	public class DSElementDamageData : SerializedClass
	{
		public uint ElementId;
		public double StartTime;
		public double EndTime;
		public float Damage;
	}

	public class DSSkillHitDamageData : SerializedClass
	{
		public double HitTime;
		public uint SkillId;
		public uint SpiritId;
		public int TriggerIndex;
		public float Damage;
		public bool IsCritical;
		public uint Error;
		public float[] Attrs;
		public uint[] Buffs;
	}

	public class DSSkillHitDataList : SerializedClass
	{
		public uint SKillId;
		public List<DSSkillHitDamageData> SkillDamageList;
	}

	public class DSSpiritDamageData : SerializedClass
	{
		public uint SpiritId;
		public float TotalDamage;
		public Dictionary<int, DSSkillHitDataList> SkillDamageRecords;
		public Dictionary<uint, DSBuffData> BuffRecords;
	}

	public class DailyHackerCounts : SerializedClass
	{
		public int Money;
		public int Fan;
	}

	public class DamageData : SerializedClass
	{
		public float SourceAmount;
		public EntityType FromType;
		public uint SourceTemplateId;
		public uint SkillId;
		public uint CreationId;
		public int TriggerIndex;
		public uint BuffId;
		public DamageEffect SpecialEffects;
		public UXVector3 ClientHitPosition;
		public uint ElementType;
		public int HitIndex;
		public float HpDecreased;
		public float Amount;
		public float ShieldDecreased;
		public int ShieldIndex;
	}

	public class DancePlayResult : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class DartParticipantInfo : GameGroundParticipantInfo
	{
		public uint DartId;
	}

	public class DartScoreInfo : SerializedClass
	{
		public Dictionary<int, int> ParticipantScoreDic;
		public int CurrentScoreIndex;
		public int CurrentScore;
		public UXVector3 CurrentScorePos;
		public int Winner;
	}

	public class DartZoneInfo : GameGroundZoneInfo
	{
		public DartGameType GameType;
		public uint CurrentRound;
		public int CurrentTurn;
		public DartScoreInfo ScoreInfo;
	}

	public class DebugBattleElementData : SerializedClass
	{
		public uint ElementId;
		public float Damage;
		public int Count;
		public float DamageMin;
		public float DamageMax;
	}

	public class DebugBattleSpiritData : SerializedClass
	{
		public uint SpiritId;
		public float TotalDamage;
		public double FightStateTime;
		public double FightBeginTime;
		public double ActiveTime;
		public double ActiveBeginTime;
		public Dictionary<uint, float> SkillDamages;
		public Dictionary<uint, int> SkillCounts;
		public Dictionary<uint, int> SkillDamageCounts;
		public Dictionary<uint, float> SkillDamagesMin;
		public Dictionary<uint, float> SkillDamagesMax;
		public Dictionary<uint, float> ExtraBuffDamages;
		public Dictionary<uint, double> BuffTimes;
		public Dictionary<uint, double> BuffBeginTimes;
		public Dictionary<uint, int> BuffRefCounts;
	}

	public class DebugBattleStatistics : SerializedClass
	{
		public double Now;
		public List<DebugBattleSpiritData> Spirits;
		public List<DebugBattleElementData> Elements;
	}

	public class DebugFileDescription : SerializedClass
	{
		public string FullPath;
		public string Name;
		public bool IsDirectory;
		public long Size;
		public uint CreateTime;
		public uint WriteTime;
		public uint AccessTime;
	}

	public class DebugFileResult : SerializedClass
	{
		public DebugFileDescription PersistentDataPath;
		public DebugFileDescription TemporaryCachePath;
		public DebugFileDescription StreamingAssetsPath;
		public DebugFileDescription DataPath;
		public DebugFileDescription ConsoleLogPath;
		public DebugFileDescription VirtualFileSystem;
	}

	public class DebugNpcBvbSelectPokemonData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class DeriveCreationData : SerializedClass
	{
		public ulong CreationId;
		public uint DeriveId;
		public UXVector3 Position;
		public float Facing;
	}

	public class DestructibleBrokenInfo : SerializedClass
	{
		public ulong InstanceId;
		public uint Stage;
		public DestructibleBrokenType BrokenType;
		public UXVector3 Position;
		public UXVector3 Facing;
	}

	public class DestructibleGridAOIIncrease : SerializedClass
	{
		public GridIndex PlayerStandardIndex;
		public List<AoiDestructibleInfo> addInfos;
		public List<GridIndex> indexList;
		public List<ulong> addUniqueIds;
		public List<ulong> removeIds;
		public AoiAddAndRemoveReason reason;
	}

	public class DestructibleSyncInfo : SerializedClass
	{
		public ulong Id;
		public uint Frame;
		public UXVector3 Position;
		public UXVector3 Facing;
		public UXVector3 Speed;
		public float Hp;
		public DestructibleMindState mindState;
		public ulong HookUnitId;
		public uint SceneItemType;
		public ulong HostPlayerID;
		public uint ClientLocalTime;
		public byte[] CompressSceneItemData;
		public int CompressSceneItemDataLength;
	}

	public class DialogAreaInfo : SerializedClass
	{
		public List<UXVector3> VertexPoints;
		public UXVector3 CenterPos;
		public float SphereRadius;
		public float XMagnitude;
		public float YMagnitude;
		public float ZMagnitude;
	}

	public class DialogParameter : SerializedClass
	{
		public DialogReason Reason;
		public uint NpcTemplateId;
		public ulong NpcInstanceId;
		public UXVector3 AgentPosition;
		public bool BlackContinue;
		public uint FromTaskId;
		public uint FromEventId;
		public bool FromClient;
		public uint DialogCameraSpawnId;
		public int SpoonNodeId;
	}

	public class DivinerCustomerInfo : SerializedClass
	{
		// No fields found in dump for DivinerCustomerInfo
	}

	public class DivinerPersuasionResult : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class DoctorCheckCureData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class DoctorCheckData : SerializedClass
	{
		// No fields found in dump for DoctorCheckData
	}

	public class DrivingBehaviorRecord : SerializedClass
	{
		public float TimeStamp;
		public UXVector3 Position;
		public float RotationX;
		public float RotationY;
		public float RotationZ;
		public float RotationW;
		public UXVector3 Velocity;
		public UXVector3 AngVelocity;
		public float SteerInput;
		public float ThrottleInput;
		public float BrakeInput;
		public float HandbrakeInput;
	}

	public class DrivingBehaviorRecords : SerializedClass
	{
		public uint VehicleConfigId;
		public DrivingBehaviorControlType ControlType;
		public List<DrivingBehaviorRecord> Records;
		public uint TaskId;
	}

	public class DropBelongingData : SerializedClass
	{
		public uint BelongingId;
		public ulong OwnerId;
		public UXVector3 Position;
	}

	public class DynamicDestructibleData : SerializedClass
	{
		public int PathId;
		public ulong ReleaserId;
		public UXVector3 Position;
		public UXVector3 Facing;
		public float LivingTime;
	}

	public class DynamicDestructibleInfo : DestructibleInfo
	{
		public PackedDestructibleInfo Pack;
		public ulong ReleaserId;
		public ulong CreateAgentInstanceId;
		public int CreateSkillInstanceId;
		public int CreateIndex;
		public ulong MergeAgentInstanceId;
		public bool NoSleep;
	}

	public class EdictDebugInfo : SerializedClass
	{
		public bool isShort;
		public ulong ownerId;
		public double giveTime;
		public double canGiveTime;
		public bool needRemove;
	}

	public class EffectSyncData : SerializedClass
	{
		public byte[] Bytes;
	}

	public class EndItemDropInfo : SerializedClass
	{
		public ulong enemyInstanceId;
		public int bindItemsIndex;
		public UXVector3 itemRotation;
		public UXVector3 itemPosition;
	}

	public class EnemyDieInfo : SerializedClass
	{
		public bool HasDieAnimation;
		public bool HasDieEffect;
		public uint DieEffectId;
		public float DelayDestroyDistance;
		public uint LastHitHurtEffect;
		public uint DeadlySkillId;
		public ulong Killer;
		public bool HasPlayedDeathSkill;
		public ulong WeaponDropDestructibleId;
		public DieType DieType;
	}

	public class EnemyItemDropInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class EnemyMoveFinishData : SerializedClass
	{
		public ulong EnemyId;
		public int MoveId;
		public bool IsFailure;
	}

	public class EnemyWeaponState : SerializedClass
	{
		public ulong Pid;
		public bool IsHoldingWeapon;
	}

	public class FansAutoGiveHistory : SerializedClass
	{
		// No fields found in dump for FansAutoGiveHistory
	}

	public class FashionColoringInfo : SerializedClass
	{
		public Dictionary<byte, uint> ColoringType2ColorIdDict;
	}

	public class FightGamePlayerSimpleInfo : SerializedClass
	{
		public bool WithAi;
		public ulong Pid;
		public bool IsObserver;
		public bool Is1P;
		public bool IsMaster;
		public FightGameUnitInfo PlayerUnitInfo;
		public FightGameUnitInfo AiUnitInfo;
	}

	public class FightGameResult : SerializedClass
	{
		public int WinnerIndex;
		public int RoundLeft;
		public uint WaitEndTime;
		public bool IsWithAi;
		public bool IsAiWin;
		public bool IsPlayerWin;
	}

	public class FightGameStateInfo : SerializedClass
	{
		public ulong Pid;
		public int PosX;
		public int PosY;
		public FightGameDirection Face;
		public int Hp;
		public int AngryValue;
	}

	public class FightGameUnitInfo : SerializedClass
	{
		public bool IsAi;
		public uint RoleId;
		public int Index;
		public bool IsReady;
		public int DeadCount;
		public string CurrentAction;
		public FightGameStateInfo State;
	}

	public class FightGroupDebugInfo : SerializedClass
	{
		public uint configId;
		public List<ulong> uIds;
		public List<EdictDebugInfo> normalEdicts;
		public List<EdictDebugInfo> extraEdicts;
	}

	public class FightPokemon : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class FireworkBuyInfo : SerializedClass
	{
		// No fields found in dump for FireworkBuyInfo
	}

	public class FireworkPlanInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class FireworkStoreInfo : SerializedClass
	{
		// No fields found in dump for FireworkStoreInfo
	}

	public class FishDestructibleData : DynamicDestructibleData
	{
		public int FishGroupId;
	}

	public class Float3 : SerializedClass
	{
		public float x;
		public float y;
		public float z;
	}

	public class FloatingMoveData : SerializedClass
	{
		public ulong unitId;
		public float moveTime;
		public float speed;
		public UXVector3 targetPos;
		public int moveId;
		public uint speedCurveId;
		public ulong targetId;
	}

	public class FollowRecordingParameters : VehicleAITaskParameters
	{
		public uint PathId;
		public E_AIFollowType FollowType;
		public string recordingFileName;
		public E_AITargetType TargetType;
		public ulong TargetUid;
		public float Step;
		public float MinSpeed;
		public float MaxSpeed;
		public bool FarAwayCheck;
		public float FarAwayThrehold;
		public bool CloseToCheck;
		public float CloseToThrehold;
		public float AdjustTime;
		public UXVector3 PathOffset;
		public float guideMinDistance;
		public float guideMaxDistance;
		public float guideMinSpeedThreshold;
		public float guideMaxSpeedThreshold;
		public float CheckStuckTime;
	}

	public class FormationPlayerSlot : SerializedClass
	{
		public int Row;
		public int Col;
	}

	public class FriendSimpleData : SerializedClass
	{
		public bool IsRejectAllFriendApply;
		public List<ulong> BlackList;
		public List<RelationVO> FriendRelationList;
		public List<ulong> SpecialList;
	}

	public class GadgetDestructibleInfo : DestructibleInfo
	{
		public ulong GadgetInstanceId;
	}

	public class GadgetEntityInfo : SerializedClass
	{
		public ulong InstanceId;
		public UXVector3 Position;
		public UXVector3 Facing;
		public Dictionary<int, int> StateIndexDic;
		public Dictionary<int, string> ValueIndexDic;
		public ulong[] Occupants;
		public List<SceneItemOccupantInfo> OccupantInfos;
		public uint LinkOccupiedId;
		public uint MetroLineId;
		public uint MetroCarriageId;
		public int NavId;
		public MetroLineCarriageInfo MetroLineCarriageInfo;
		public Dictionary<ulong, ulong> SymbiosisGadgets;
		public Dictionary<ulong, ulong> SymbiosisDestructibles;
		public PackedGadgetInfo Pack;
		public MobilePlatformSyncInfo MobilePlatformInfo;
	}

	public class GadgetGridAOIIncrease : SerializedClass
	{
		public List<GadgetEntityInfo> addInfos;
		public List<GridIndex> indexList;
		public List<ulong> addUniqueIds;
		public List<ulong> removeIds;
		public List<ulong> activeIds;
		public List<ulong> inactiveIds;
		public AoiAddAndRemoveReason reason;
	}

	public class GadgetPackSyncInfo : SerializedClass
	{
		public ulong InstanceId;
		public PackedGadgetInfo PackedInfo;
		public Dictionary<ulong, ulong> SymbiosisDestructibles;
	}

	public class GameGroundParticipantInfo : SerializedClass
	{
		public ulong Pid;
		public uint NpcCultivationId;
		public ulong AgentUId;
		public int SeatIndex;
		public bool IsReady;
		public bool IsPlayAgain;
	}

	public class GameGroundZoneInfo : SerializedClass
	{
		public ulong GadgetUId;
		public GameGroundZoneStartReason StartReason;
		public GameGroundZoneSyncReason SyncReason;
		public GameGroundZoneType ZoneType;
		public GameGroundZoneState ZoneState;
		public GameGroundParticipantInfo[] ParticipantInfos;
	}

	public class GameServerInfo : SerializedClass
	{
		public string ClientListenIp;
		public int ClientListenPort;
		public string Token;
	}

	public class GangBossFullDetails : SerializedClass
	{
		public PlayerInfoJobGangBoss full;
		public int CurrentBattleAgentCount;
		public GangBossFullDetails() { onlyFields = true; }
	}

	public class GangMembersInfos : SerializedClass
	{
		public uint TemplateId;
		public bool IsUnlock;
		public double NextReviveTimeStamp;
		public ulong InstanceId;
		public GangMembersInfos() { onlyFields = true; }
	}

	public class GmBehaviorKV : SerializedClass
	{
		public string Key;
		public string Value;
	}

	public class GmCreateNpcOptionData : SerializedClass
	{
		public uint ActionId;
	}

	public class GmCreatePedData : SerializedClass
	{
		public uint AgentId;
		public uint UrbanDiversityId;
		public uint Personality;
		public uint SexType;
		public uint[] Usages;
		public uint[] Crimes;
	}

	public class GmEnemyStrategyInfo : SerializedClass
	{
		public List<uint> SkillIds;
	}

	public class GmLockTargetRadius : SerializedClass
	{
		public string AiName;
		public float Radius;
		public float BackRadius;
		public float LookUpAngle;
		public float LookDownAngle;
		public float EyeHeight;
	}

	public class GmQueryObjectRoot : SerializedClass
	{
		public int Id;
		public string Name;
		public bool IsActive;
		public bool IsStatic;
		public string Position;
		public string LocalPosition;
		public string Rotation;
		public string LocalRotation;
		public string Scale;
		public string LocalScale;
		public string Path;
		public string Layer;
		public List<QueryComponentInfo> Components;
	}

	public class GmQuerySceneInfo : SerializedClass
	{
		public string Name;
		public List<GmQuerySceneObjectInfo> Objects;
	}

	public class GmQuerySceneObjectInfo : SerializedClass
	{
		public int Id;
		public string Name;
		public bool IsActive;
		public bool Leaf;
	}

	public class GomokuParticipantInfo : SerializedClass
	{
		// No fields found in dump for GomokuParticipantInfo
	}

	public class GomokuParticipantScoreInfo : SerializedClass
	{
		public List<GomokuPiece> RecordInfo;
	}

	public class GomokuPiece : SerializedClass
	{
		public uint X;
		public uint Y;
	}

	public class GomokuScoreInfo : SerializedClass
	{
		public Dictionary<int, GomokuParticipantScoreInfo> GomokuParticipantDict;
		public int Winner;
	}

	public class GomokuZoneInfo : GameGroundZoneInfo
	{
		public GomokuGameType GameType;
		public uint CurrentRound;
		public int CurrentTurn;
		public GomokuScoreInfo ScoreInfo;
	}

	public class GridAOIDecrease : SerializedClass
	{
		public List<int> SectorIdList;
		public List<GridIndex> StandardIndexList;
		public List<ulong> ExceptIds;
	}

	public class GridIndex : SerializedClass
	{
		public int X;
		public int Z;
	}

	public class GymPlayResult : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class HackerBatteryCurrentAndTotalCount : SerializedClass
	{
		public uint BatteryTotalCount;
		public uint BatteryCurrentCount;
		public HackerBatteryCurrentAndTotalCount() { onlyFields = true; }
	}

	public class HackerPostInfo : SerializedClass
	{
		public uint Id;
		public HackerPostState State;
		public bool HaveRead;
	}

	public class HitPredictData : SerializedClass
	{
		public ulong TargetId;
		public int HitPredictId;
		public ulong PredictorId;
	}

	public class HouseMoveParkingSpaceInfo : SerializedClass
	{
		public uint VehicleId;
		public uint HouseId;
		public int ParkingSpaceIndex;
	}

	public class HouseParkingInfo : SerializedClass
	{
		public uint HouseId;
		public uint VehicleId;
	}

	public class ImSimpleData : SerializedClass
	{
		public List<ChatGroupClient> ChatGroupList;
		public uint MuteEndTime;
		public uint SoftMuteEndTime;
	}

	public class InteractCmdData : SerializedClass
	{
		public uint CmdType;
		public ulong sender;
		public ulong receiver;
		public byte[] CommandData;
		public int CommandDataLen;
	}

	public class ItemDestructibleData : DynamicDestructibleData
	{
		public uint DesTemplateId;
	}

	public class LeadingWayUrging : SerializedClass
	{
		public uint dialogId;
		public float distance;
		public float minDuration;
	}

	public class LinkInfoClient : SerializedClass
	{
		public ulong Id;
		public LinkMode Mode;
		public LinkDeviceLevel DeviceLevel;
		public List<PlayerBasicInfoVO> Members;
	}

	public class LinkMemberInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class LogicVehicleUnitDebugData : SerializedClass
	{
		public ulong Id;
		public List<uint> FineId;
		public UXVector3 Position;
	}

	public class LookAtPositionData : IAgentClientData
	{
		public UXVector3 Position;
		public float Speed;
		public uint ActionId;
		public bool IsImmediate;
	}

	public class LookAtTargetData : IAgentClientData
	{
		public uint ActionId;
		public float Speed;
		public bool IsImmediate;
	}

	public class MahjongGameInfo : SerializedClass
	{
		public MjGameStateEnum GameState;
		public int Round;
		public int Remainders;
		public int Banker;
		public int Turn;
		public int LastTurn;
		public int LastMoPaiSeatIndex;
		public SeatInfo[] SeatInfos;
		public List<MjPaiInfo> HuPais;
		public List<MjPaiInfo> DoraIndicatorLs;
		public List<MjPaiInfo> DoraLs;
		public List<MjPaiInfo> UraDoraIndicatorLs;
		public List<MjPaiInfo> UraDoraLs;
	}

	public class MahjongPlayerInfo : SerializedClass
	{
		public ulong Pid;
		public int Aid;
		public uint Level;
		public string Name;
		public PersonalZoneHeadInfo PzHeadInfo;
		public int Score;
		public int SeatIndex;
		public uint NpcMahjongId;
		public uint NpcCultivationId;
		public MahjongPlayerInfo() { onlyFields = true; }
	}

	public class MahjongRoomInfo : SerializedClass
	{
		public int MahjongServerId;
		public ulong RoomId;
		public byte RoomType;
		public byte State;
		public List<MahjongPlayerInfo> PlayerInfos;
		public List<bool> HasReady;
		public int RoomOwnerSeatIndex;
		public MahjongRoomInfo() { onlyFields = true; }
	}

	public class MaidTeaChoiceInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MaidTeaMemeberInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MailAttachment : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MailHead : SerializedClass
	{
		// No fields found in dump for MailHead
	}

	public class MailInfo : SerializedClass
	{
		// No fields found in dump for MailInfo
	}

	public class MailParameter : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MassCustomArea : SerializedClass
	{
		public int Uid;
		public bool Hide;
		public List<UXVector3> Points;
		public MassHideType HideType;
	}

	public class MassTrafficSpawnArea : SerializedClass
	{
		public List<SpawnLaneSelector> SpawnLaneSelector;
		public uint Uid;
		public bool UseCustomizedSeed;
		public uint Seed;
		public bool UseIntervalBetweenLanes;
		public float MinSpawnInterval;
		public float MaxSpawnInterval;
		public bool SpawnVehicleContinuously;
		public bool FilledWithVehicleAtStart;
		public bool RemoveVehicleWhenOutOfArea;
		public bool UseSameVelocityConfig;
		public float MinVehicleSpeed;
		public float MaxVehicleSpeed;
		public bool UseCustomizedVehicle;
	}

	public class MassTrafficSpawnAreaManager : SerializedClass
	{
		public bool ClearAllNormalVehicles;
		public List<SpawnAreaSelector> TrafficSpawnAreas;
	}

	public class MatchPlayerSettleData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MatchPrepareInfo : SerializedClass
	{
		public uint VehicleId;
		public OtherPlayerSpiritWearFashionsInfo Fashion;
		public uint SpiritId;
		public uint PoseId;
		public List<ItemCountInfo> LinkPlanningBoardPutInKeys;
	}

	public class MatchPrepareRoom : MatchRoom
	{
		public List<ulong> TeamRooms;
		public List<ulong> PlayAgainMembers;
		public List<ulong> ConfirmMembers;
		public List<ulong> ReadyMembers;
		public uint ConfirmStartTime;
		public uint PrepareStartTime;
		public uint GameStartTime;
		public Dictionary<ulong, MatchPrepareInfo> PrepareInfos;
		public bool MemberLeave;
		public Dictionary<ulong, MatchPrepareRoomPlayerSwapInfo> PlayerSwapInfos;
		public bool IsFreeWorldBattle;
		public ulong GadgetId;
		public ulong SceneId;
		public ulong LeaveToTeam;
		public ulong LeaveToTeamLeader;
		public PrepareRoomState State;
	}

	public class MatchPrepareRoomDutySwapInfo : SerializedClass
	{
		public ulong SourcePid;
		public uint SourceDuty;
		public ulong TargetPid;
		public uint TargetDuty;
	}

	public class MatchPrepareRoomPlayerSwapInfo : SerializedClass
	{
		public Dictionary<ulong, MatchPrepareRoomDutySwapInfo> SwapInfos;
	}

	public class MatchRoom : SerializedClass
	{
		public ulong Id;
		public uint GameId;
		public ulong LeaderPid;
		public List<MatchRoomMemberInfo> Members;
		public uint LastMemberUpdateTime;
		public bool ByMatch;
		public bool PSNOnly;
	}

	public class MatchRoomMemberInfo : SerializedClass
	{
		public ulong Pid;
		public uint MatchForbidDueTime;
		public uint Duty;
		public LinkMode FromMode;
		public LinkDeviceLevel DeviceLevel;
		public uint FromRaidId;
		public ulong FromSceneInstanceId;
		public List<ulong> Blacklist;
	}

	public class MatchRoomSetting : SerializedClass
	{
		public bool AllowNonLeaderInvite;
	}

	public class MatchTeamRoom : MatchRoom
	{
		public uint MatchStartTime;
		public MatchingFactor matchingFactor;
		public bool InMatch;
		public bool Single;
		public MatchRoomSetting Setting;
	}

	public class MatchingFactor : SerializedClass
	{
		public List<ulong> Blacklist;
		public double deviceLevelWeight;
		public double Score;
	}

	public class MessageCallbackParameter : SerializedClass
	{
		// No fields found in dump for MessageCallbackParameter
	}

	public class MetroCarriageGadgetInfos : SerializedClass
	{
		public List<ulong> InnerGadgetIds;
		public List<ulong> OuterGadgetIds;
	}

	public class MetroHideArea : SerializedClass
	{
		public int Uid;
		public bool Hide;
		public UXVector3 Center;
		public float Radius;
	}

	public class MetroHitData : SerializedClass
	{
		public int MetroId;
		public ulong TargetId;
		public float Speed;
		public uint HurtEffectId;
		public uint HurtStiffId;
	}

	public class MetroLineCarriageInfo : SerializedClass
	{
		public uint MetroLineId;
		public uint MetroCarriageId;
	}

	public class MilkTopicInfo : SerializedClass
	{
		// No fields found in dump for MilkTopicInfo
	}

	public class MjAction : SerializedClass
	{
		public MjActionType Type;
		public int Owner;
		public List<int> Targets;
		public int Score;
		public bool IsZhuanYi;
		public int BaseFan;
		public MjHuPattern Pattern;
		public List<MjHuPattern> Patterns;
		public MjPaiInfo Pai;
		public int NumOfGen;
		public int HuAction;
		public int Fan;
	}

	public class MjCanActionInfo : SerializedClass
	{
		public MjPaiInfo Pai;
		public bool CanHu;
		public bool CanReach;
		public List<MjPCGActionInfo> CanPeng;
		public List<MjPCGActionInfo> CanChi;
		public List<MjPCGActionInfo> CanGang;
		public bool CanChuPai;
	}

	public class MjPCGActionInfo : SerializedClass
	{
		public int Source;
		public MjPaiInfo Pai;
		public List<MjPaiInfo> SelectPais;
		public MjPCGType PCGType;
	}

	public class MjPaiInfo : SerializedClass
	{
		public int Pai;
		public MjType MType;
		public bool Red;
		public int Index;
	}

	public class MjPlayerResult : SerializedClass
	{
		public List<MjPaiInfo> Holds;
	}

	public class MjResult : SerializedClass
	{
		public List<MjAction> MJActions;
		public List<MjPlayerResult> MjPlayerResultList;
	}

	public class MobilePlatformSyncInfo : SerializedClass
	{
		public int CurLevel;
		public int TgtLevel;
		public uint StartTime;
		public Dictionary<ulong, UXVector3> Players;
		public UXVector3 CurLevelPos;
		public UXVector3 TgtLevelPos;
	}

	public class ModifySpiritWearFashionResult : SerializedClass
	{
		public List<uint> R0;
		public List<WearFashionInfo> R1;
		public List<uint> R2;
		public List<WearFashionEditInfo> R3;
	}

	public class MomentsNotifyClientInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MonitorTwitterBehavior : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class MoveActionData : SerializedClass
	{
		public ulong UnitId;
		public UXVector3 Pos;
		public UXVector3 Rot;
		public int MoveId;
		public float MoveTime;
		public uint ClientLocalTime;
		public MoveActionGroundData GroundData;
		public byte[] ActionData;
		public int ActionDataLength;
		public byte[] EffectData;
		public int EffectDataLength;
		public byte[] InteractableData;
		public int InteractableDataLength;
	}

	public class MoveActionGroundData : SerializedClass
	{
		public MoveGroundType MoveGroundType;
		public ulong MoveGroundId;
		public UXVector3 LocalPos;
	}

	public class MoveToBorderData : SerializedClass
	{
		public ulong UnitId;
		public MoveToPosType MoveType;
		public float MaxDistance;
		public int MoveId;
		public bool CloseIK;
	}

	public class MoveToCanShootPosData : SerializedClass
	{
		public ulong UnitId;
		public MoveToPosType MoveType;
		public float AngleSpace;
		public float DistanceSpace;
		public int MoveId;
		public bool CloseIK;
	}

	public class MoveToEQSData : SerializedClass
	{
		public ulong UnitId;
		public ulong TargetId;
		public string EqsName;
		public string CheckerName;
		public uint PathTags;
		public MoveToPosType MoveType;
		public int MoveId;
		public bool CloseIK;
		public bool CloseObstacleAvoidance;
	}

	public class MoveToPosData : SerializedClass
	{
		public ulong pid;
		public List<UXVector3> path;
		public uint pathTags;
		public int moveId;
		public float StopDistance;
		public MoveToPosType type;
		public bool reportOnFinish;
		public bool closeIK;
		public bool UseServerPath;
		public bool CloseObstacleAvoidance;
		public List<byte> pathFlags;
	}

	public class MoveTowardUnitData : SerializedClass
	{
		public ulong UnitId;
		public ulong TargetId;
		public int MoveId;
		public uint ActionId;
		public float NearDistance;
		public bool ReportOnFinish;
		public bool CloseObstacleAvoidance;
		public bool CloseIngterStep;
		public bool IsMoveAround;
		public bool CloseIK;
		public MoveToPosType Type;
	}

	public class MoveWanderingData : SerializedClass
	{
		public ulong pid;
		public uint pathTags;
		public int moveId;
		public MoveToPosType type;
		public bool closeIK;
		public bool CloseObstacleAvoidance;
		public float MinDis;
		public float MaxDis;
		public float InRangeAngle;
		public float OutRangeAngle;
		public float MaxTime;
		public float MaxOnceWanderTime;
	}

	public class MusicClientInfo : SerializedClass
	{
		// No fields found in dump for MusicClientInfo
	}

	public class NameCard : SerializedClass
	{
		public ulong Pid;
		public string Name;
		public uint Level;
	}

	public class NgpushSetting : SerializedClass
	{
		public bool DoNotDisturb;
		public uint DoNotDisturbBegin;
		public uint DoNotDisturbEnd;
		public uint TagSetting;
		public uint LastSetTagTime;
	}

	public class NodeSpoonOutputLinks : SerializedClass
	{
		public List<SpoonOutputLink> Links;
	}

	public class NpcShareTimeInfo : SerializedClass
	{
		// No fields found in dump for NpcShareTimeInfo
	}

	public class NpcShopCommodityInfo : SerializedClass
	{
		public uint TemplateId;
		public int Count;
		public uint RefreshTime;
		public byte Status;
		public uint BuyTimes;
		public uint Discount;
		public uint DiscountPrice;
	}

	public class NpcShopInfo : SerializedClass
	{
		public uint CurrentDiscount;
		public uint NextDiscount;
		public List<NpcShopCommodityInfo> CommodityInfoList;
	}

	public class NpcTrustValueInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class NpcVehicleDriveStateInfo : SerializedClass
	{
		public ulong Uid;
		public bool EnterOrLeave;
		public ulong VehicleEntityId;
		public int SeatIndex;
	}

	public class OccupyDebugInfo : SerializedClass
	{
		public uint OccupyId;
		public string Reason;
	}

	public class OtherPlayerSpiritWearFashionsInfo : BaseWearFashionsInfo
	{
		public Dictionary<uint, FashionColoringInfo> WearFashionColoringInfoDict;
	}

	public class OwnerSyncData : SerializedClass
	{
		public uint NetworkTick;
		public ulong attackPid;
		public ulong hurtPid;
		public uint hurtId;
		public UXVector3 hitPoint;
		public UXVector3 hitCenter;
		public UXVector3 hitDirection;
		public UXVector3 colliderPos;
		public UXVector3 colliderForward;
		public UXVector3 colliderVelocity;
		public UXVector3 attackColliderPos;
		public UXVector3 attackColliderForward;
		public UXVector3 attackColliderVelocity;
		public int skillUUID;
		public uint skillId;
		public int triggerIndex;
		public int materialIndex;
		public int hitColliderIndex;
		public uint creationId;
	}

	public class PSNPlayerInfo : SerializedClass
	{
		// No fields found in dump for PSNPlayerInfo
	}

	public class PackedDestructibleInfo : SerializedClass
	{
		public int iScale;
		public byte[] linkType;
		public int[] linkPath;
	}

	public class PackedGadgetInfo : SerializedClass
	{
		public float posX;
		public float posY;
		public float posZ;
		public float eulerX;
		public float eulerY;
		public float eulerZ;
		public int iScale;
		public ulong uniqueId;
		public int pathId;
		public PackedGadgetSpecialParam[] spoonSpecialList;
		public bool delayDestroy;
		public uint startTaskId;
		public uint endTaskId;
	}

	public class PackedGadgetSpecialParam : SerializedClass
	{
		public int markId;
		public string value;
	}

	public class PartyNPCMessage : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PartyResponse : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PartySettleData : SerializedClass
	{
		public uint PartyId;
		public uint Popularity;
		public uint LikeCount;
		public uint GiftCount;
		public uint CommentCount;
		public uint AudienceCount;
		public uint WinGameCount;
		public uint TaskCount;
		public uint InviteFriendCount;
		public uint Drop;
		public List<uint> InviteNPCList;
	}

	public class PauseFrameData : SerializedClass
	{
		public ulong Id;
		public ulong Releaser;
		public float Time;
		public uint SkillId;
		public uint TriggerIndex;
	}

	public class PersonalTeamSetting : SerializedClass
	{
		// No fields found in dump for PersonalTeamSetting
	}

	public class PersonalTimeSetting : SerializedClass
	{
		// No fields found in dump for PersonalTimeSetting
	}

	public class PersonalZoneAchievement : SerializedClass
	{
		// No fields found in dump for PersonalZoneAchievement
	}

	public class PersonalZoneFightSpiritInfo : SerializedClass
	{
		// No fields found in dump for PersonalZoneFightSpiritInfo
	}

	public class PersonalZoneHeadExtendInfo : SerializedClass
	{
		// No fields found in dump for PersonalZoneHeadExtendInfo
	}

	public class PersonalZoneItemInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PersonalZoneUnlockBackgroundInfo : SerializedClass
	{
		// No fields found in dump for PersonalZoneUnlockBackgroundInfo
	}

	public class PlateGridAOIInfo : SerializedClass
	{
		public List<PlateInfo> addInfos;
		public List<ulong> removeIds;
		public AoiAddAndRemoveReason reason;
	}

	public class PlateInfo : SerializedClass
	{
		public ulong UniqueId;
		public int GraphId;
		public Dictionary<int, ulong> GadgetDic;
		public Dictionary<int, ulong> DestructibleDic;
		public Dictionary<int, int> AgentDic;
		public Dictionary<int, int> VehicleDic;
	}

	public class PlayActionData : IAgentClientData
	{
		public uint ActionId;
	}

	public class PlayActionWithLayerData : IAgentClientData
	{
		public uint ActionId;
	}

	public class PlayerBasicInfoVO : SerializedClass
	{
		public ulong Pid;
		public string Name;
		public uint Level;
		public SexType Sex;
		public PersonalZoneHeadInfo PzHeadInfo;
		public uint LastLogoutTime;
		public uint LastDetachTime;
		public uint RaidId;
		public PlayerState OnlineState;
		public LinkMode LinkMode;
		public int LinkIndex;
		public float SyncRate;
		public bool InRoom;
		public bool InMatch;
		public ulong TeamId;
		public string AppChannel;
	}

	public class PlayerDieInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PlayerFightStyleUnLockChangeInfo : SerializedClass
	{
		public PlayerInfoFightStyle playerInfoFightStyle;
		public Dictionary<uint, bool> addOrUpdateUnlockInfo;
	}

	public class PlayerHotSpringInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PlayerInfoJobGangBoss : SerializedClass
	{
		public Dictionary<uint, GangMembersInfos> GangMembers;
		public PlayerInfoJobGangBoss() { onlyFields = true; }
	}

	public class PlayerInfoJobWasher : SerializedClass
	{
		// No fields found in dump for PlayerInfoJobWasher
	}

	public class PlayerInvestigateCountryInfo : SerializedClass
	{
		// No fields found in dump for PlayerInvestigateCountryInfo
	}

	public class PlayerInvestigateGalleryInfo : SerializedClass
	{
		public uint GalleryId;
		public uint UnlockTime;
		public bool IsArchived;
		public UXVector3 Pos;
		public uint Count;
	}

	public class PlayerMahjongInfo : SerializedClass
	{
		// No fields found in dump for PlayerMahjongInfo
	}

	public class PlayerPartyInfo : SerializedClass
	{
		public uint PartyTimes;
		public ulong lastPartyTime;
	}

	public class PlotMinMaxRange : SerializedClass
	{
		public float min;
		public float max;
	}

	public class PointInteractInfo : SerializedClass
	{
		public int NodeId;
		public UXVector3 Pos;
		public int Index;
		public uint Sprite;
		public uint LabelId;
		public bool DoNotFocusCamera;
		public PointInteractPlayerAction PlayerAction;
	}

	public class PointInteractPlayerAction : SerializedClass
	{
		public InteractPlayerActionType CommonInteractType;
		public InteractActionPosType InteractPosType;
		public UXVector3 InteractPos;
		public UXVector3 InteractPosForward;
		public float InteractRadius;
		public float InteractLoopTime;
		public UXVector3 InteractIkPos;
		public UXVector3 InteractIkPosForward;
		public int ChairType;
	}

	public class PoliceCaseInfo : SerializedClass
	{
		// No fields found in dump for PoliceCaseInfo
	}

	public class PoliceChargingSkillInfo : SerializedClass
	{
		public uint ChargingSkillId;
		public UXVector3 Position;
		public float Facing;
	}

	public class PoliceDispatchExtraInfo : SerializedClass
	{
		// No fields found in dump for PoliceDispatchExtraInfo
	}

	public class PoliceDispatchInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PoliceDutyBasicInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PoliceFakeClueAgentInfo : SerializedClass
	{
		public uint AgentId;
		public bool IsRead;
	}

	public class PoliceFakeFileInfo : SerializedClass
	{
		public uint CurFakeFileId;
		public uint ClueValue;
		public Dictionary<uint, PoliceFakeFileState> UnlockFileInfoDict;
		public List<PoliceFakeClueAgentInfo> HistoryClueAgentInfoList;
	}

	public class PoliceServiceData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PoliceVehicleSpawnClientInfo : SerializedClass
	{
		public ulong Id;
		public uint VehicleId;
		public UXVector3 Position;
		public float Facing;
	}

	public class PoliceVehicleSpawnConfigInfo : SerializedClass
	{
		public float ChaseRange;
		public float ChaseDirectlyRange;
		public float ApprehendRange;
		public uint NavConfigId;
		public uint ChaseDirectlyConfigId;
		public float PatrolSpeed;
		public float ChaseSpeed;
		public float ChaseDirectlySpeed;
	}

	public class PoliceViolationInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PosServerEffectData : ServerEffectData
	{
		public UXVector3 Pos;
		public UXVector3 Rotation;
		public UXVector3 Scale;
	}

	public class PossiblePlayerData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PostPlayerCommentClientInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class PostSimpleClientInfo : SerializedClass
	{
		// No fields found in dump for PostSimpleClientInfo
	}

	public class PreSwitchSpiritData : SerializedClass
	{
		public uint SwitchSpiritConfigId;
		public PreSwitchSpiritType PreSwitchSpiritType;
		public ulong DestructibleId;
		public ulong AgentId;
		public uint NewSpiritConfigId;
	}

	public class QueryComponentInfo : SerializedClass
	{
		public bool IsActive;
		public string Name;
		public bool Script;
	}

	public class QueryFieldInfo : SerializedClass
	{
		public string Name;
		public string Value;
		public string FieldType;
		public string SelfType;
		public string Exception;
		public bool CanWrite;
		public bool Leaf;
	}

	public class QueryGameObjectFilter : SerializedClass
	{
		public int[] Path;
		public string Name;
	}

	public class RacingInfo : SerializedClass
	{
		public uint CfgId;
		public uint TaskId;
		public Dictionary<ulong, uint> AIVehicleInfos;
	}

	public class RacingParameters : VehicleAITaskParameters
	{
		public string raceName;
		public int routeId;
		public float discourageRatio;
		public float discourageCD;
		public float checkDiscourageLength;
		public float checkDiscourageWidth;
		public float checkDiscourageMinDeltaSpeed;
		public float checkDiscourageMaxDeltaSpeed;
		public float swayUnitTime;
		public float swayTime;
	}

	public class RaidBattleData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RaidBattleUnitAgent : SerializedClass
	{
		public ulong Id;
		public uint TemplateId;
		public UXVector3 Position;
		public float FacingDirection;
		public ulong OwnerId;
		public ulong ManagedPid;
		public uint NavTags;
		public MoveActionGroundData GroundData;
		public uint ModelId;
		public int SkillId;
		public int HSummonIndex;
		public int SpoonAgentId;
		public uint SuitId;
		public ulong ParentId;
		public uint SpoonIndex;
		public uint AutoBackIndex;
		public ulong VehicleId;
		public int VehicleIndex;
		public ulong SourceWeaponId;
		public bool IsBorn;
		public bool BattleAiS;
		public AgentSyncClientInfo agentSyncClientInfo;
		public uint WeaponId;
		public ulong TransformAgentId;
		public OtherPlayerSpiritWearFashionsInfo SpiritWearFashionsInfo;
		public bool Begging;
	}

	public class RaidBattleUnitSpirit : SerializedClass
	{
		public ulong Id;
		public uint TemplateId;
		public UXVector3 Position;
		public float FacingDirection;
		public ulong OwnerId;
		public ulong ManagedPid;
		public uint NavTags;
		public MoveActionGroundData GroundData;
		public ulong TransformAgentId;
		public OtherPlayerSpiritWearFashionsInfo SpiritWearFashionsInfo;
		public bool Begging;
	}

	public class RaidCleaningInfo : SerializedClass
	{
		public float CleaningProcess;
		public uint TaskId;
		public uint DropId;
		public uint StartTime;
		public uint TotalSecond;
		public float RewardRate;
		public float ProficiencyRate;
	}

	public class RaidGamePlayInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RaidGamePlayRecordValueInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RamParameters : VehicleAITaskParameters
	{
		public ulong TargetUid;
		public float StraightLineDistance;
		public bool UseContinuousRam;
	}

	public class RangeMoveType : SerializedClass
	{
		public float MinDistance;
		public float MaxDistance;
		public MovementMethod Method;
	}

	public class RelationVO : SerializedClass
	{
		public ulong Pid;
		public bool Both;
		public string RemarkName;
	}

	public class ReportBehaviorSeqStartInfo : SerializedClass
	{
		public ulong Uid;
		public int PointIndex;
		public int CommandIndex;
		public BehaviorSeqType Type;
		public BehaviorSeqCommand Cmd;
	}

	public class ResetFashionColoringInfo : SerializedClass
	{
		public List<byte> resetColoringTypeList;
	}

	public class ResetFashionColoringSchemeInfo : SerializedClass
	{
		public uint FashionId;
		public Dictionary<byte, ResetFashionColoringInfo> resetFashionColoringSchemeInfoDict;
	}

	public class RestaurantResult : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RewardCollectionInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RewardDetail : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RewardExtraInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RewardInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RewardUrbanAbilityInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class RollIntervalMessage : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SceneCreationInfo : SerializedClass
	{
		public ulong Id;
		public ulong ParentId;
		public ulong TargetId;
		public ulong DestructibleId;
		public uint CreationId;
		public UXVector3 ParentPosition;
		public float Rotate;
		public bool ClientEnterOrLeave;
		public uint SourceSkillId;
		public ulong SourceDestructibleId;
		public ulong GadgetId;
		public int GadgetTransformId;
	}

	public class SceneItemDropActionInfo : SerializedClass
	{
		public ulong hosterInstanceId;
		public ulong sceneItemInstanceId;
		public UXVector3 hosterPosition;
		public bool isDestroyImmediately;
		public float yForce;
		public float zForce;
		public float gravity;
	}

	public class SceneItemOccupantInfo : SerializedClass
	{
		public ulong Pid;
		public uint FightSpiritId;
		public ulong AttractNpcPid;
		public int Index;
		public bool IsState;
	}

	public class SceneRoomChangeData : SerializedClass
	{
		public int Id;
		public bool Enable;
	}

	public class SeatInfo : SerializedClass
	{
		public int Score;
		public int HoldsCount;
		public List<MjPaiInfo> Holds;
		public List<MjPaiInfo> Folds;
		public List<MjPCGActionInfo> Sequence;
		public int ReachFoldCnt;
		public MjType Que;
		public List<MjPaiInfo> HuanPais;
		public List<MjPaiInfo> HuPais;
	}

	public class SerializeMinMaxAABB : SerializedClass
	{
		public Float3 Min;
		public Float3 Max;
	}

	public class SerializeQuaternion : SerializedClass
	{
		public float x;
		public float y;
		public float z;
		public float w;
	}

	public class ServerEffectData : SerializedClass
	{
		public uint EffectId;
		public ulong InstanceId;
		public double LogicEndTime;
		public ulong ReleaserId;
		public ulong ClientDestructibleId;
		public float Duration;
	}

	public class SetEmotionData : SerializedClass
	{
		public ulong AgentId;
		public uint Emotion;
		public uint State;
	}

	public class SimpleMailAttchment : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SimpleUnreadMessage : SerializedClass
	{
		// No fields found in dump for SimpleUnreadMessage
	}

	public class SimpleVehicleSyncData : SerializedClass
	{
		public ulong EntityId;
		public float TimeStamp;
		public UXVector3 Position;
		public float facingDirection;
	}

	public class SkillCreationData : SerializedClass
	{
		public int Id;
		public ulong ReleaserId;
		public int TriggerIndex;
		public UXVector3 Position;
		public float Facing;
	}

	public class SkillDestructibleData : SerializedClass
	{
		public int Id;
		public uint TemplateId;
		public int PathId;
		public ulong ReleaserId;
		public int TriggerIndex;
		public UXVector3 Position;
		public UXVector3 Facing;
	}

	public class SkillExecuteData : SerializedClass
	{
		public int SkillId;
		public ulong ReleaserId;
		public int TriggerIndex;
		public int ParentTriggerIndex;
		public ulong TargetId;
		public uint StiffId;
	}

	public class SkillHitData : SerializedClass
	{
		public ulong ReleaserId;
		public int Id;
		public uint SkillId;
		public int TriggerIndex;
		public ulong TriggerInstanceId;
		public int Stage;
		public ulong HitTarget;
		public ulong HitDestructible;
		public ulong AttachedDestructibleId;
		public UXVector3 ClientHitPosition;
		public UXVector3 ClientHitPosNormalDir;
		public SkillHitType SkillHitType;
		public int HitMaterial;
		public UXVector3 HitCenter;
		public uint StiffId;
		public float StiffTime;
		public uint HurtEffectId;
		public float FirmHurt;
		public int ShieldDefendIndex;
		public bool IsBackHit;
	}

	public class SkillParam : SerializedClass
	{
		public ulong entityId;
		public ulong targetId;
		public int moveId;
		public int instanceId;
		public uint select;
		public ulong targetDestructibleId;
		public uint skillId;
		public int unitPartIndex;
		public float rotate;
		public UXVector3 unitPosition;
		public UXVector3 location;
		public UXVector3 faceToPos;
		public uint destructibleTemplateId;
		public List<UXVector3> DesignerPosList;
		public uint SectionRepeatTimes;
		public uint SeqConfigID;
		public UXVector3 SelfMobilityPos;
		public UXVector3 TarMobilityPos;
	}

	public class SkillShieldData : SerializedClass
	{
		public int SkillInstanceId;
	}

	public class SkillStateData : SerializedClass
	{
		public int SkillInstanceId;
		public ulong ReleaserId;
		public List<uint> StateIds;
	}

	public class SkillSummonData : SerializedClass
	{
		public int SkillInstanceId;
		public ulong ReleaserId;
		public int TriggerIndex;
		public UXVector3 Position;
		public float Facing;
	}

	public class SkillTimeCurveData : SerializedClass
	{
		public int Id;
		public ulong ReleaserId;
		public int TriggerIndex;
	}

	public class SkillUseData : SerializedClass
	{
		public ulong Releaser;
		public UXVector3 Location;
		public float Facing;
		public ulong TargetId;
		public int UnitPartIndex;
		public ulong TargetDestructibleId;
		public ulong AttachDestructibleId;
		public uint SkillId;
		public int SkillInstanceId;
	}

	public class SpawnAreaSelector : SerializedClass
	{
		public MassTrafficSpawnArea SpawnArea;
		public bool Selected;
	}

	public class SpawnLaneSelector : SerializedClass
	{
		public SpawnLaneType SpawnLaneType;
		public AreaColliderParams FirstArea;
		public AreaColliderParams SecondArea;
	}

	public class SpinOutParameters : VehicleAITaskParameters
	{
		public ulong TargetUid;
	}

	public class SpiritAddWeaponAction : SerializedClass
	{
		public uint SpiritTid;
		public ulong SpiritUid;
		public int SlotIndex;
		public WeaponDetail Weapon;
	}

	public class SpiritBartenderInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SpiritBattleData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SpiritDrawViewData : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SpiritFightTypeChangeAction : SerializedClass
	{
		public uint spiritId;
		public SpiritFightStyleInfo fullInfo;
		public Dictionary<uint, uint> addOrUpdateInfo;
	}

	public class SpiritHackerJobInfo : SerializedClass
	{
		public string HackerName;
		public Dictionary<uint, HackerPostInfo> PostInfos;
		public uint Rank;
		public DailyHackerCounts DailyCounts;
	}

	public class SpiritPoliceJobInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SpiritRemoveWeaponAction : SerializedClass
	{
		public uint SpiritTid;
		public ulong SpiritUid;
		public ulong WeaponUid;
		public DiscardWeaponReason Reason;
	}

	public class SpiritTalentExpInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class SpiritUpdateWeaponAction : SerializedClass
	{
		public uint SpiritTid;
		public ulong SpiritUid;
		public WeaponDetail Weapon;
	}

	public class SpiritVirtualFightStyleInfo : SerializedClass
	{
		public uint SpiritId;
		public uint FightStyleTypeId;
		public uint FightStyleId;
		public uint EventId;
	}

	public class SpoonActionParam : SerializedClass
	{
		public Dictionary<int, string> PortToValue;
		public UXVector3 Position;
	}

	public class SpoonClientActionTaskInfo : SerializedClass
	{
		public uint NodeTaskId;
		public uint ContextTaskId;
		public uint EventId;
		public Dictionary<ulong, int> Pid2Index;
	}

	public class SpoonClientData : SerializedClass
	{
		public Dictionary<int, ulong> Enemies;
		public Dictionary<int, ulong> Npcs;
		public List<SpoonTriggerInfo> TriggerInfos;
		public List<SceneRoomChangeData> SpoonRooms;
		public Dictionary<uint, bool> InteractiveNpcs;
	}

	public class SpoonOutputLink : SerializedClass
	{
		public string Name;
		public List<int> NextNodes;
	}

	public class SpoonTaskClientData : SerializedClass
	{
		public List<SpoonTriggerInfo> TriggerInfos;
		public Dictionary<int, ulong> Enemies;
		public List<SceneRoomChangeData> SpoonRooms;
		public List<int> RemovedNpcList;
		public Dictionary<int, int> VehicleIdDict;
		public uint TaskId;
		public uint EventId;
	}

	public class SpoonTriggerInfo : SerializedClass
	{
		public int FlowIndex;
		public int NodeId;
		public uint StartTime;
		public bool NeedComplete;
		public uint MemoryTaskId;
		public bool IsCondition;
		public List<ControlFlowData> Ports;
	}

	public class StartAttractInfo : SerializedClass
	{
		public ulong UnitUid;
		public ulong AttractPointUid;
		public uint AttractPointId;
		public UXVector3 CenterPosition;
		public float CenterAngle;
		public int GroupIndex;
		public int PointIndex;
		public int CommandIndex;
		public int MetroId;
		public int CarriageIndex;
	}

	public class StartPatrolInfo : SerializedClass
	{
		public ulong Uid;
		public string FileName;
		public int HashCode;
		public int SeqIndex;
		public int GroupIndex;
		public int PointIndex;
		public int CommandIndex;
		public bool Loop;
		public bool Return;
	}

	public class StaticDestructibleInfo : DestructibleInfo
	{
		public int GroupId;
		public PackedDestructibleInfo Pack;
	}

	public class StimEventParameter : SerializedClass
	{
		public ClientActionTarget Source;
		public ClientActionTarget Source2;
	}

	public class StopParameters : VehicleAITaskParameters
	{
		public float StopRatio;
		public bool useThrottleStop;
	}

	public class SummonVehicleResult : SerializedClass
	{
		public ulong VehicleEntityId;
		public ulong TaskToken;
	}

	public class SurroundNpcSpawnInfo : SerializedClass
	{
		public UXVector3 Position;
		public float Facing;
		public int Pid;
		public uint NpcFormworkId;
	}

	public class SyncCinemaQueryInfo : SerializedClass
	{
		public List<uint> HaveSeenList;
		public CinemaTicketInfo TicketInfo;
		public ulong InviteNpcId;
		public List<uint> UnlockMovies;
	}

	public class SyncMultiCinemaQueryInfo : SerializedClass
	{
		public uint LastestMovieId;
		public uint LastestMovieStartTime;
		public CinemaMultiTicketInfo TicketInfo;
	}

	public class TaskDestructibleInfo : DestructibleInfo
	{
		public int PlateInlineId;
		public ulong GroupId;
		public string TriggerTag;
		public uint NpcPhoneId;
		public uint ExternalSystemLinkId;
		public bool NoSleep;
		public uint MetroLineId;
		public uint MetroCarriageId;
		public MetroLineCarriageInfo MetroLineCarriageInfo;
		public Dictionary<int, string> ExposeParams;
	}

	public class TaskStateData : SerializedClass
	{
		public TaskState State;
		public ChangeSingleTaskReason Reason;
		public uint FailTextId;
		public bool CanSkip;
	}

	public class TaskVehicleBuffInitInfo : SerializedClass
	{
		public uint configId;
		public float duration;
	}

	public class TaskWaitLoadResource : SerializedClass
	{
		public List<int> AgentSpoonIds;
		public List<ulong> Gadgets;
		public List<ulong> SceneItems;
		public List<int> VehicleSpoonIds;
		public List<int> DynamicGoIds;
	}

	public class TeamSetting : SerializedClass
	{
		// No fields found in dump for TeamSetting
	}

	public class TimePanelInfo : SerializedClass
	{
		public List<PersonalTimeSetting> PersonalTimeSettings;
	}

	public class TraceGps : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class TrafficLightInfo : SerializedClass
	{
		public int dataPathIndex;
		public int index;
		public TrafficLightDesc desc;
	}

	public class TruckJobOrderAccept : SerializedClass
	{
		public uint AcceptedEventId;
		public uint AcceptTime;
		public TruckJobOrderAccept() { onlyFields = true; }
	}

	public class TruckJobOrderInfo : SerializedClass
	{
		public TruckPosInfo StartPos;
		public TruckPosInfo EndPos;
		public uint CargoId;
		public TruckNpcInfo DeliveryNpc;
		public bool IsEmergency;
		public int LimitAcceptSeconds;
		public int LimitFinishSeconds;
		public int EstimatedFinishSeconds;
		public List<CargoInfo> CargoInfoList;
		public int BasePointReward;
		public float DropCoefficient;
		public int DropMoney;
		public uint OrderType;
		public TruckJobOrderInfo() { onlyFields = true; }
	}

	public class TruckJobOrderResult : SerializedClass
	{
		public uint FinishTime;
		public int CargoIntegrity;
		public uint DropId;
		public int DropMoney;
		public uint DeliverUpset;
		public TruckJobOrderResult() { onlyFields = true; }
	}

	public class TruckJobOrderWrap : SerializedClass
	{
		public TruckJobOrderInfo OrderInfo;
		public uint UniqueId;
		public uint OrderInfoStartTime;
		public TruckJobOrderAccept AcceptInfo;
		public TruckJobOrderResult ResultInfo;
		public bool CargoPickedUp;
		public float CargoIntegrity;
		public TruckJobOrderWrap() { onlyFields = true; }
	}

	public class TruckNpcInfo : SerializedClass
	{
		public uint NpcId;
		public uint ConsigneeId;
		public uint RudeId;
		public TruckNpcInfo() { onlyFields = true; }
	}

	public class TruckPosInfo : SerializedClass
	{
		public int WpId;
		public uint ConfigId;
		public UXVector3 Pos;
		public TruckPosInfo() { onlyFields = true; }
	}

	public class TuiteInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class TurnToPositionData : IAgentClientData
	{
		public UXVector3 Position;
		public float Speed;
		public uint ActionId;
		public bool IsImmediate;
	}

	public class UXBoolObject : UXObject
	{
		public bool Value;
	}

	public class UXDoubleObject : UXObject
	{
		public double Value;
	}

	public class UXIntObject : UXObject
	{
		public int Value;
	}

	public class UXLongObject : UXObject
	{
		public long Value;
	}

	public class UXMassHideArea : SerializedClass
	{
		public int Uid;
		public bool Hide;
		public MassHideType HideType;
		public UXVector3 Center;
		public UXVector3 Extends;
		public UXVector3 Rotation;
	}

	public class UXObject : SerializedClass
	{
		// No fields found in dump for UXObject
	}

	public class UXStringObject : UXObject
	{
		public string Value;
	}

	public class UXUintObject : UXObject
	{
		public uint Value;
	}

	public class UXUlongObject : UXObject
	{
		public ulong Value;
	}

	public class UnitInfoOnMoveGround : SerializedClass
	{
		public MoveGroundType MoveGroundType;
		public ulong MoveGroundId;
		public UXVector3 LocalPos;
		public UXVector3 LocalRot;
	}

	public class UrbanGamePlayResult : SerializedClass
	{
		// No fields found in dump for UrbanGamePlayResult
	}

	public class VehicleAICommonParameters : SerializedClass
	{
		public float FollowPathCheckArrivePointDistance;
		public int TurnSlowSpeedTemplateId;
		public float TurnMinAheadSpeed;
		public float TurnMinAheadDistance;
		public float TurnMaxAheadSpeed;
		public float TurnMaxAheadDistance;
		public float AheadDistanceNormalRatio;
		public float ArriveRoadDistance;
	}

	public class VehicleAITaskParameters : SerializedClass
	{
		public ulong Token;
		public uint taskAIConfigId;
		public float defaultSpeed;
		public VehicleTaskDrivingFlags drivingFlags;
		public float initSpeed;
		public List<TaskVehicleBuffInitInfo> initTaskAIBuffList;
		public VehicleAICommonParameters commonParameters;
	}

	public class VehicleAnimationBase : SerializedClass
	{
		public ulong EntityId;
		public ulong Pid;
	}

	public class VehicleBlockMove : SerializedClass
	{
		public float weight;
		public float blockSpeedMultiplier;
		public float blockDistance;
		public float blockCD;
		public float blockWaitTime;
	}

	public class VehicleBrokenCollisionInfo : SerializedClass
	{
		public ulong VehicleEntityId;
		public float CurrentHp;
		public float MaxHp;
	}

	public class VehicleComponentStateUpdateInfo : SerializedClass
	{
		public ulong UId;
		public VehicleComponentType ComponentType;
		public VehicleComponentStatus NewStatus;
	}

	public class VehicleContactDamageData : SerializedClass
	{
		public float VehicleMass;
		public List<UXVector3> VehicleVelocities;
		public UXVector3 VehicleRelativeVelocity;
		public uint Layer;
		public float TouchMass;
		public float EnemyWeight;
		public uint EnemyRank;
		public bool DisableThreshold;
		public ulong OtherVehicleEntityId;
	}

	public class VehicleDangerZone : SerializedClass
	{
		public ulong Uid;
		public ulong AreaInstanceId;
		public UXVector3 Center;
		public UXVector3 Extends;
		public UXVector3 Rotation;
		public float Radius;
		public bool Add;
		public bool ObstacleOnly;
		public float RemoveRadius;
	}

	public class VehicleEscapeDebugData : SerializedClass
	{
		public ulong VehicleUid;
		public string Status;
	}

	public class VehicleHitData : SerializedClass
	{
		public ulong VehicleId;
		public ulong DriverId;
		public ulong TargetId;
		public float Speed;
		public uint HurtEffectId;
		public uint HurtStiffId;
		public UXVector3 VehicleSpeed;
		public UXVector3 AgentSpeed;
	}

	public class VehicleNavResult : SerializedClass
	{
		public uint NavReqId;
		public List<UXVector3> Points;
		public List<UXVector3> CenterPoints;
	}

	public class NpcVehicleEnterExitData : SerializedClass
	{
		public ulong NpcEntityId;
		public ulong VehicleEntityId;
		public bool IsEntering;
	}

	public class VehiclePartAnimation : VehicleAnimationBase
	{
		public ulong UnitId;
		public int ConfigId;
		public int PartIndex;
		public E_PartEvent Events;
		public int Priority;
	}

	public class VehiclePoliceChaseParameters : VehicleAITaskParameters
	{
		public E_AITargetType TargetType;
		public ulong TargetUid;
	}

	public class VehicleRamMove : SerializedClass
	{
		public float weight;
		public float coldDownForOwn;
		public float coldDownForGroup;
		public float suitableAngle;
		public float exitDistance;
		public float turnTime;
		public float extrusionTime;
		public float extrusionMoveDisAtFront;
		public float regressTime;
	}

	public class VehicleSkillDamageData : SerializedClass
	{
		public float VehicleMass;
		public UXVector3 VehicleVelocity;
		public uint HurtEffectId;
		public ulong ReleaserId;
		public UXVector3 HitPoint;
	}

	public class VehicleSpecialPartAnimation : VehicleAnimationBase
	{
		public E_VehiclePartType PartType;
	}

	public class VisibilityReportData : SerializedClass
	{
		public ulong detectorPid;
		public ulong detectedPid;
		public bool isVisible;
		public bool isFront;
	}

	public class WasherMissionHistoryInfo : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class WasherMissionResult : SerializedClass
	{
		// Class not found in IL2CPP dump - needs manual implementation
	}

	public class WebviewLoginTokenInfo : SerializedClass
	{
		public string Aid;
		public string Username;
		public string RoleId;
		public string RoleName;
		public int ServerId;
		public string RoleIcon;
		public int Time;
		public string ActivityName;
		public string PayloadJson;
	}

	public class WildEnemyClientInfo : SerializedClass
	{
		// No fields found in dump for WildEnemyClientInfo
	}

	public class WildEnemyGroupClientInfo : SerializedClass
	{
		// No fields found in dump for WildEnemyGroupClientInfo
	}

	public class WildEnemyGroupInitSyncInfo : SerializedClass
	{
		public uint Time;
		public List<ulong> EnemyInstanceIds;
	}

	public class WorkActionNodeInfo : SerializedClass
	{
		public int NodeId;
		public int WorkActionIndex;
		public int Value;
	}

	public class ZoneData : SerializedClass
	{
		public int BoundaryPointsBegin;
		public int BoundaryPointsEnd;
		public int LanesBegin;
		public int LanesEnd;
		public SerializeMinMaxAABB Bounds;
		public ZoneGraphTag Tags;
		public int UrbanDiversity;
		public int StationId;
		public int ZoneGroupHandle;
		public int ZoneGroupInternalNumber;
		public int PointsCount;
		public float DensityFactor;
		public float RoadWidth;
	}

	public class ZoneGraphBVNode : SerializedClass
	{
		public float MinX;
		public float MinY;
		public float MinZ;
		public float MaxX;
		public float MaxY;
		public float MaxZ;
		public int Index;
	}

	public class ZoneGraphBVTree : SerializedClass
	{
		public Float3 Origin;
		public ZoneGraphBVNode[] Nodes;
	}

	public class ZoneGraphLaneLocation : SerializedClass
	{
		public Float3 Position;
		public Float3 LanePosition;
		public Float3 Direction;
		public Float3 Tangent;
		public Float3 Up;
		public int LaneHandle;
		public int LaneSegment;
		public float DistanceAlongLane;
		public List<int> ZoneIndexs;
		public int LaneZoneIndex;
	}

	public class ZoneGraphLaneSection : SerializedClass
	{
		public int LaneHandle;
		public float StartDistanceAlongLane;
		public float EndDistanceAlongLane;
	}

	public class ZoneGraphLinkedLane : SerializedClass
	{
		public int DestLane;
		public ZoneLaneLinkType Type;
		public uint Flags;
		public float Weight;
	}

	public class ZoneGraphStorage : SerializedClass
	{
		public ZoneData[] Zones;
		public ZoneLaneData[] Lanes;
		public Float3[] BoundaryPoints;
		public Float3[] LanePoints;
		public Float3[] LaneUpVectors;
		public Float3[] LaneTangentVectors;
		public float[] LanePointProgressions;
		public ZoneLaneLinkData[] LaneLinks;
		public SerializeMinMaxAABB Bounds;
		public ZoneGraphBVTree ZoneBVTree;
		public int DataHandle;
	}

	public class ZoneGraphTagFilter : SerializedClass
	{
		public ZoneGraphTag AnyTags;
		public ZoneGraphTag AllTags;
		public ZoneGraphTag NotTags;
	}

	public class ZoneLaneData : SerializedClass
	{
		public float Width;
		public ZoneGraphTag Tags;
		public int PointsBegin;
		public int PointsEnd;
		public int LinksBegin;
		public int LinksEnd;
		public int ZoneIndex;
		public uint StartEntryId;
		public uint EndEntryId;
		public int CenterLaneId;
		public int TurnDirection;
		public int ConnectionType;
		public float SourceExtendDistance;
		public float DestExtendDistance;
	}

	public class ZoneLaneLinkData : SerializedClass
	{
		public int DestLaneIndex;
		public ZoneLaneLinkType Type;
		public uint Flags;
	}

}