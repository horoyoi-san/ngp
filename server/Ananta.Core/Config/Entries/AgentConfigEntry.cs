using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class AgentConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("CNName")]
        public string CNName { get; set; } = "";

        [JsonPropertyName("ByName")]
        public string ByName { get; set; } = "";

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("Address")]
        public string Address { get; set; } = "";

        [JsonPropertyName("AgentType")]
        public int AgentType { get; set; }

        [JsonPropertyName("AgentSecondaryType")]
        public int AgentSecondaryType { get; set; }

        [JsonPropertyName("AgentSpecificType")]
        public int AgentSpecificType { get; set; }

        [JsonPropertyName("SpeciesType")]
        public int SpeciesType { get; set; }

        [JsonPropertyName("EnemyRank")]
        public int EnemyRank { get; set; }

        [JsonPropertyName("EnemyClassType")]
        public int EnemyClassType { get; set; }

        [JsonPropertyName("IsGaintEnemy")]
        public bool IsGaintEnemy { get; set; }

        [JsonPropertyName("Faction")]
        public int Faction { get; set; }

        [JsonPropertyName("Camp")]
        public int Camp { get; set; }

        [JsonPropertyName("SexType")]
        public int SexType { get; set; }

        [JsonPropertyName("Race")]
        public int Race { get; set; }

        [JsonPropertyName("Age")]
        public int Age { get; set; }

        [JsonPropertyName("Height")]
        public double Height { get; set; }

        [JsonPropertyName("Weight")]
        public double Weight { get; set; }

        [JsonPropertyName("Personality")]
        public int Personality { get; set; }

        [JsonPropertyName("MBTI")]
        public int MBTI { get; set; }

        [JsonPropertyName("EconomicLevel")]
        public int EconomicLevel { get; set; }

        [JsonPropertyName("GeneralModelId")]
        public long GeneralModelId { get; set; }

        [JsonPropertyName("ModelType")]
        public int ModelType { get; set; }

        [JsonPropertyName("Tag")]
        public List<int> Tag { get; set; } = new();

        [JsonPropertyName("InitWeaponId")]
        public int InitWeaponId { get; set; }

        [JsonPropertyName("JobTag")]
        public int JobTag { get; set; }

        [JsonPropertyName("CriminalRecord")]
        public int CriminalRecord { get; set; }

        [JsonPropertyName("AttributeSchemeId")]
        public int AttributeSchemeId { get; set; }

        [JsonPropertyName("ShowHPBar")]
        public bool ShowHPBar { get; set; }

        [JsonPropertyName("HideHp")]
        public bool HideHp { get; set; }

        [JsonPropertyName("ShowNameBar")]
        public bool ShowNameBar { get; set; }

        [JsonPropertyName("HeadIcon")]
        public int HeadIcon { get; set; }

        [JsonPropertyName("HudIconId")]
        public int HudIconId { get; set; }

        [JsonPropertyName("PictureId")]
        public int PictureId { get; set; }

        [JsonPropertyName("BodyHeight")]
        public double BodyHeight { get; set; }

        [JsonPropertyName("BodyRadius")]
        public double BodyRadius { get; set; }

        [JsonPropertyName("CanQkill")]
        public int CanQkill { get; set; }

        [JsonPropertyName("CanAssassinate")]
        public bool CanAssassinate { get; set; }

        [JsonPropertyName("ForbidPlayerAttack")]
        public bool ForbidPlayerAttack { get; set; }

        [JsonPropertyName("IsUniqueCharacter")]
        public bool IsUniqueCharacter { get; set; }

        [JsonPropertyName("TargetLockDistance")]
        public double TargetLockDistance { get; set; }

        [JsonPropertyName("GroupEnemy")]
        public int GroupEnemy { get; set; }

        [JsonPropertyName("AI")]
        public int AI { get; set; }

        [JsonPropertyName("Action")]
        public int Action { get; set; }

        [JsonPropertyName("Navigation")]
        public int Navigation { get; set; }

        [JsonPropertyName("StiffSetting")]
        public int StiffSetting { get; set; }

        [JsonPropertyName("DeathSetting")]
        public int DeathSetting { get; set; }

        [JsonPropertyName("VehicleGameplay")]
        public int VehicleGameplay { get; set; }

        [JsonPropertyName("MindLevel")]
        public int MindLevel { get; set; }

        [JsonPropertyName("MindInteractionType")]
        public int MindInteractionType { get; set; }

        [JsonPropertyName("AgentProfileId")]
        public int AgentProfileId { get; set; }

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("ShieldIds")]
        public List<int> ShieldIds { get; set; } = new();

        [JsonPropertyName("HookSkill")]
        public List<int> HookSkill { get; set; } = new();

        [JsonPropertyName("ActionGroup")]
        public int ActionGroup { get; set; }

        [JsonPropertyName("ActionGroupId")]
        public int ActionGroupId { get; set; }

        [JsonPropertyName("ActionRemappingSets")]
        public List<int> ActionRemappingSets { get; set; } = new();

        [JsonPropertyName("ActionTypeId")]
        public int ActionTypeId { get; set; }

        [JsonPropertyName("AgentDropWeaponType")]
        public int AgentDropWeaponType { get; set; }

        [JsonPropertyName("AnimGraph")]
        public int AnimGraph { get; set; }

        [JsonPropertyName("AnimStereotype")]
        public int AnimStereotype { get; set; }

        [JsonPropertyName("AppearanceTag")]
        public int AppearanceTag { get; set; }

        [JsonPropertyName("Avoidanc")]
        public int Avoidanc { get; set; }

        [JsonPropertyName("BanBlock")]
        public List<int> BanBlock { get; set; } = new();

        [JsonPropertyName("BattleComponentAsset")]
        public string BattleComponentAsset { get; set; } = "";

        [JsonPropertyName("Birthday")]
        public BirthdayData? Birthday { get; set; }

        [JsonPropertyName("BodyTag")]
        public int BodyTag { get; set; }

        [JsonPropertyName("BornEndAction")]
        public int BornEndAction { get; set; }

        [JsonPropertyName("BornStartAction")]
        public int BornStartAction { get; set; }

        [JsonPropertyName("BossFollowCameraID")]
        public string BossFollowCameraID { get; set; } = "";

        [JsonPropertyName("BVBEnemyType")]
        public int BVBEnemyType { get; set; }

        [JsonPropertyName("CanEffectDestructible")]
        public bool CanEffectDestructible { get; set; }

        [JsonPropertyName("CanHookBoneId")]
        public List<int> CanHookBoneId { get; set; } = new();

        [JsonPropertyName("Capusle")]
        public int Capusle { get; set; }

        [JsonPropertyName("ChaosMasterId")]
        public int ChaosMasterId { get; set; }

        [JsonPropertyName("ColliderOffset")]
        public ColliderOffsetData? ColliderOffset { get; set; }

        [JsonPropertyName("DetectId")]
        public int DetectId { get; set; }

        [JsonPropertyName("DMEMType")]
        public int DMEMType { get; set; }

        [JsonPropertyName("EnemyIcon")]
        public int EnemyIcon { get; set; }

        [JsonPropertyName("EnemyOccurId")]
        public int EnemyOccurId { get; set; }

        [JsonPropertyName("ExamType")]
        public int ExamType { get; set; }

        [JsonPropertyName("FavoriteRadio")]
        public int FavoriteRadio { get; set; }

        [JsonPropertyName("FontInvisible")]
        public bool FontInvisible { get; set; }

        [JsonPropertyName("HoldCatHeight")]
        public double HoldCatHeight { get; set; }

        [JsonPropertyName("IDIssueDate")]
        public BirthdayData? IDIssueDate { get; set; }

        [JsonPropertyName("IdValidDate")]
        public int IdValidDate { get; set; }

        [JsonPropertyName("ignoreLOD")]
        public bool IgnoreLOD { get; set; }

        [JsonPropertyName("IKSetting")]
        public int IKSetting { get; set; }

        [JsonPropertyName("InitialScore")]
        public double InitialScore { get; set; }

        [JsonPropertyName("InteractGroupID")]
        public int InteractGroupID { get; set; }

        [JsonPropertyName("InteractSetting")]
        public int InteractSetting { get; set; }

        [JsonPropertyName("IsAuxiliaryCollimation")]
        public bool IsAuxiliaryCollimation { get; set; }

        [JsonPropertyName("IsDisplayMarkPoint")]
        public bool IsDisplayMarkPoint { get; set; }

        [JsonPropertyName("IsEmptyAction")]
        public bool IsEmptyAction { get; set; }

        [JsonPropertyName("JobFakeTag")]
        public string JobFakeTag { get; set; } = "";

        [JsonPropertyName("LaunchProperty")]
        public List<int> LaunchProperty { get; set; } = new();

        [JsonPropertyName("LimitSameModelConflict")]
        public bool LimitSameModelConflict { get; set; }

        [JsonPropertyName("LockEnemyPoint")]
        public string LockEnemyPoint { get; set; } = "";

        [JsonPropertyName("LockTargetParameter")]
        public List<LockTargetData> LockTargetParameter { get; set; } = new();

        [JsonPropertyName("LockTargetParameter_Fight")]
        public List<LockTargetData> LockTargetParameterFight { get; set; } = new();

        [JsonPropertyName("MindInteractionParams")]
        public MindInteractionParamsData? MindInteractionParams { get; set; }

        [JsonPropertyName("MindInteractionWeaponId")]
        public int MindInteractionWeaponId { get; set; }

        [JsonPropertyName("MindPowerSkillRange")]
        public MindPowerSkillRangeData? MindPowerSkillRange { get; set; }

        [JsonPropertyName("MotionDataset")]
        public int MotionDataset { get; set; }

        [JsonPropertyName("NameDisplay")]
        public int NameDisplay { get; set; }

        [JsonPropertyName("NeedToBeDetected")]
        public bool NeedToBeDetected { get; set; }

        [JsonPropertyName("NormalBindItem")]
        public List<BindItemData> NormalBindItem { get; set; } = new();

        [JsonPropertyName("Physics")]
        public int Physics { get; set; }

        [JsonPropertyName("Progress")]
        public int Progress { get; set; }

        [JsonPropertyName("QuoteId")]
        public int QuoteId { get; set; }

        [JsonPropertyName("Ragdoll")]
        public int Ragdoll { get; set; }

        [JsonPropertyName("Region")]
        public List<int> Region { get; set; } = new();

        [JsonPropertyName("SEnemyIcon")]
        public int SEnemyIcon { get; set; }

        [JsonPropertyName("ShowBossHpInDistance")]
        public double ShowBossHpInDistance { get; set; }

        [JsonPropertyName("ShowBossHpInLockPlayer")]
        public bool ShowBossHpInLockPlayer { get; set; }

        [JsonPropertyName("ShowHPBarUnderAttack")]
        public bool ShowHPBarUnderAttack { get; set; }

        [JsonPropertyName("ShowNameBarDistance")]
        public double ShowNameBarDistance { get; set; }

        [JsonPropertyName("SoundState")]
        public string SoundState { get; set; } = "";

        [JsonPropertyName("SoundSwtichs")]
        public List<SoundSwitchData> SoundSwtichs { get; set; } = new();

        [JsonPropertyName("SpecialBindItem")]
        public List<BindItemData> SpecialBindItem { get; set; } = new();

        [JsonPropertyName("SPictureId")]
        public int SPictureId { get; set; }

        [JsonPropertyName("SummonTag")]
        public int SummonTag { get; set; }

        [JsonPropertyName("TimelinePersonality")]
        public int TimelinePersonality { get; set; }

        [JsonPropertyName("UnitSelect")]
        public int UnitSelect { get; set; }

        [JsonPropertyName("UnitStateEventId")]
        public List<int> UnitStateEventId { get; set; } = new();

        [JsonPropertyName("VoiceToneNumber")]
        public int VoiceToneNumber { get; set; }

        [JsonPropertyName("WeaponAttackAddRate")]
        public double WeaponAttackAddRate { get; set; }

        [JsonPropertyName("WeaponDestructibleId")]
        public int WeaponDestructibleId { get; set; }

        [JsonPropertyName("__IDX__Name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__Name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__ByName")]
        public long IdxByName { get; set; }

        [JsonPropertyName("__RAW__ByName")]
        public string RawByName { get; set; } = "";

        [JsonPropertyName("__IDX__Address")]
        public long IdxAddress { get; set; }

        [JsonPropertyName("__RAW__Address")]
        public string RawAddress { get; set; } = "";

        [JsonPropertyName("__IDX__JobFakeTag")]
        public long IdxJobFakeTag { get; set; }

        [JsonPropertyName("__RAW__JobFakeTag")]
        public string RawJobFakeTag { get; set; } = "";
    }

    public class BirthdayData
    {
        [JsonPropertyName("month")]
        public int Month { get; set; }

        [JsonPropertyName("day")]
        public int Day { get; set; }
    }

    public class ColliderOffsetData
    {
        [JsonPropertyName("x")]
        public double X { get; set; }

        [JsonPropertyName("y")]
        public double Y { get; set; }

        [JsonPropertyName("z")]
        public double Z { get; set; }
    }

    public class MindInteractionParamsData
    {
        [JsonPropertyName("holdBindBone")]
        public string HoldBindBone { get; set; } = "";

        [JsonPropertyName("holdOffsetX")]
        public double HoldOffsetX { get; set; }

        [JsonPropertyName("holdOffsetY")]
        public double HoldOffsetY { get; set; }

        [JsonPropertyName("holdOffsetZ")]
        public double HoldOffsetZ { get; set; }

        [JsonPropertyName("flyToHoldSpeed")]
        public double FlyToHoldSpeed { get; set; }

        [JsonPropertyName("magnetScaleRangeBottom")]
        public double MagnetScaleRangeBottom { get; set; }

        [JsonPropertyName("magnetScaleRangeTop")]
        public double MagnetScaleRangeTop { get; set; }

        [JsonPropertyName("groupIdMinded")]
        public int GroupIdMinded { get; set; }

        [JsonPropertyName("actionTypeMinded")]
        public int ActionTypeMinded { get; set; }

        [JsonPropertyName("canThrow")]
        public bool CanThrow { get; set; }

        [JsonPropertyName("morphDestructibleId")]
        public int MorphDestructibleId { get; set; }
    }

    public class MindPowerSkillRangeData
    {
        [JsonPropertyName("radius")]
        public double Radius { get; set; }

        [JsonPropertyName("angle")]
        public double Angle { get; set; }
    }

    public class LockTargetData
    {
        [JsonPropertyName("IsDisplayMarkPoint")]
        public bool IsDisplayMarkPoint { get; set; }

        [JsonPropertyName("TargetLockDistance")]
        public double TargetLockDistance { get; set; }

        [JsonPropertyName("InitialScore")]
        public double InitialScore { get; set; }

        [JsonPropertyName("AngleLimit")]
        public double AngleLimit { get; set; }

        [JsonPropertyName("EnableWeakLock")]
        public bool EnableWeakLock { get; set; }
    }

    public class BindItemData
    {
        [JsonPropertyName("item")]
        public string Item { get; set; } = "";

        [JsonPropertyName("bindBone")]
        public string BindBone { get; set; } = "";

        [JsonPropertyName("battleBindBone")]
        public string BattleBindBone { get; set; } = "";

        [JsonPropertyName("type")]
        public int Type { get; set; }

        [JsonPropertyName("param")]
        public double Param { get; set; }

        [JsonPropertyName("offsetx")]
        public double OffsetX { get; set; }

        [JsonPropertyName("offsety")]
        public double OffsetY { get; set; }

        [JsonPropertyName("offsetz")]
        public double OffsetZ { get; set; }

        [JsonPropertyName("selfEulerX")]
        public double SelfEulerX { get; set; }

        [JsonPropertyName("selfEulerY")]
        public double SelfEulerY { get; set; }

        [JsonPropertyName("selfEulerZ")]
        public double SelfEulerZ { get; set; }

        [JsonPropertyName("scale")]
        public double Scale { get; set; }

        [JsonPropertyName("isBodySplit")]
        public bool IsBodySplit { get; set; }

        [JsonPropertyName("refAnimItem")]
        public string RefAnimItem { get; set; } = "";
    }

    public class SoundSwitchData
    {
        [JsonPropertyName("groupName")]
        public string GroupName { get; set; } = "";

        [JsonPropertyName("groupValue")]
        public string GroupValue { get; set; } = "";
    }
}
