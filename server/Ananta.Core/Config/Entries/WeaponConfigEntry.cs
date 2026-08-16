using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class WeaponConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("Name2")]
        public string Name2 { get; set; } = "";

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("WeaponBelong")]
        public long WeaponBelong { get; set; }

        [JsonPropertyName("WeaponType")]
        public int WeaponType { get; set; }

        [JsonPropertyName("Type")]
        public int Type { get; set; }

        [JsonPropertyName("CantDiscard")]
        public bool CantDiscard { get; set; }

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("AttackPower")]
        public double AttackPower { get; set; }

        [JsonPropertyName("AttackSpeed")]
        public int AttackSpeed { get; set; }

        [JsonPropertyName("AttackRange")]
        public int AttackRange { get; set; }

        [JsonPropertyName("ImpactForce")]
        public int ImpactForce { get; set; }

        [JsonPropertyName("Durability")]
        public int Durability { get; set; } = -1;

        [JsonPropertyName("FightSkillType")]
        public long FightSkillType { get; set; }

        [JsonPropertyName("ActionType")]
        public int ActionType { get; set; }

        [JsonPropertyName("ActionTypeSubType")]
        public int ActionTypeSubType { get; set; }

        [JsonPropertyName("WeaponBuff")]
        public long WeaponBuff { get; set; }

        [JsonPropertyName("WeaponBuffDescription")]
        public string WeaponBuffDescription { get; set; } = "";

        [JsonPropertyName("NoDuraBuff")]
        public long NoDuraBuff { get; set; }

        [JsonPropertyName("WeaponFightingPara")]
        public double WeaponFightingPara { get; set; }

        [JsonPropertyName("FixMoney")]
        public int FixMoney { get; set; }

        [JsonPropertyName("HumanDamagePara")]
        public double HumanDamagePara { get; set; }

        [JsonPropertyName("ChaosDamagePara")]
        public double ChaosDamagePara { get; set; }

        [JsonPropertyName("PoiseAbility")]
        public double PoiseAbility { get; set; }

        [JsonPropertyName("sixDimBonus")]
        public int SixDimBonus { get; set; }

        [JsonPropertyName("WeaponLockDistance")]
        public double WeaponLockDistance { get; set; }

        [JsonPropertyName("LockPointFunc")]
        public int LockPointFunc { get; set; }

        [JsonPropertyName("ShieldId")]
        public int ShieldId { get; set; }

        [JsonPropertyName("SceneItemInteractionID")]
        public long SceneItemInteractionID { get; set; }

        [JsonPropertyName("WeaponDestroyEffect")]
        public long WeaponDestroyEffect { get; set; }

        [JsonPropertyName("SoundSwitch")]
        public string SoundSwitch { get; set; } = "_common";

        [JsonPropertyName("ModelResPath")]
        public List<string> ModelResPath { get; set; } = new();

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("SWeaponIconId")]
        public long SWeaponIconId { get; set; }

        [JsonPropertyName("NotDirectlyEquip")]
        public bool NotDirectlyEquip { get; set; }

        [JsonPropertyName("FixedFightSkill")]
        public int FixedFightSkill { get; set; }

        [JsonPropertyName("SWeaponWheelsIconId")]
        public int SWeaponWheelsIconId { get; set; }

        [JsonPropertyName("WeaponConsumableIcon")]
        public int WeaponConsumableIcon { get; set; }

        [JsonPropertyName("CanIntelligentThrow")]
        public bool CanIntelligentThrow { get; set; }

        [JsonPropertyName("AgentId")]
        public int AgentId { get; set; }

        [JsonPropertyName("DontDestroyOnDurabilityZeroOut")]
        public bool DontDestroyOnDurabilityZeroOut { get; set; }

        [JsonPropertyName("ShootId")]
        public int ShootId { get; set; }

        [JsonPropertyName("NotEnterRoulette")]
        public bool NotEnterRoulette { get; set; }

        [JsonPropertyName("IsFallHurtWeapon")]
        public bool IsFallHurtWeapon { get; set; }

        [JsonPropertyName("UiTipsType")]
        public int UiTipsType { get; set; }

        [JsonPropertyName("ShowInStoreScale")]
        public double ShowInStoreScale { get; set; }

        [JsonPropertyName("BindBone")]
        public List<string> BindBone { get; set; } = new();

        [JsonPropertyName("BindPosOffset")]
        public List<WeaponVector3Data> BindPosOffset { get; set; } = new();

        [JsonPropertyName("BindRotOffset")]
        public List<WeaponVector3Data> BindRotOffset { get; set; } = new();

        [JsonPropertyName("ZoomMul")]
        public List<double> ZoomMul { get; set; } = new();

        [JsonPropertyName("AgentZoomMul")]
        public List<double> AgentZoomMul { get; set; } = new();

        [JsonPropertyName("PermanentEffect")]
        public List<int> PermanentEffect { get; set; } = new();

        [JsonPropertyName("WeaponIdleAnimName")]
        public string WeaponIdleAnimName { get; set; } = "";

        [JsonPropertyName("DropOutOnHit")]
        public bool DropOutOnHit { get; set; }

        [JsonPropertyName("WeaponReactBelong")]
        public int WeaponReactBelong { get; set; }

        [JsonPropertyName("WeaponCameraFollowId")]
        public int WeaponCameraFollowId { get; set; }

        [JsonPropertyName("WeaponLockPoint")]
        public int WeaponLockPoint { get; set; }

        [JsonPropertyName("BattlePeaceModeNoLimit")]
        public bool BattlePeaceModeNoLimit { get; set; }

        [JsonPropertyName("Category")]
        public int Category { get; set; }

        [JsonPropertyName("ParkourStateID")]
        public int ParkourStateID { get; set; }

        [JsonPropertyName("FightResHUD")]
        public int FightResHUD { get; set; }

        [JsonPropertyName("DurabilityUIMode")]
        public int DurabilityUIMode { get; set; }

        [JsonPropertyName("Tags")]
        public List<int> Tags { get; set; } = new();

        [JsonPropertyName("StoreTopTasks")]
        public List<int> StoreTopTasks { get; set; } = new();

        [JsonPropertyName("GuideId")]
        public string GuideId { get; set; } = "";

        [JsonPropertyName("MAGuideId")]
        public string MAGuideId { get; set; } = "";

        [JsonPropertyName("StoreGuideTaskId")]
        public int StoreGuideTaskId { get; set; }

        [JsonPropertyName("WheelGuideTaskId")]
        public int WheelGuideTaskId { get; set; }

        [JsonPropertyName("ShowInStorePos")]
        public List<WeaponVector3Data> ShowInStorePos { get; set; } = new();

        [JsonPropertyName("ShowInStoreRot")]
        public List<WeaponVector3Data> ShowInStoreRot { get; set; } = new();

        [JsonPropertyName("WeaponVisibleEffects")]
        public List<WeaponVisibleEffectData> WeaponVisibleEffects { get; set; } = new();

        [JsonPropertyName("__IDX__Name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__Name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__Description")]
        public long IdxDescription { get; set; }

        [JsonPropertyName("__RAW__Description")]
        public string RawDescription { get; set; } = "";

        [JsonPropertyName("__IDX__WeaponBuffDescription")]
        public long IdxWeaponBuffDescription { get; set; }

        [JsonPropertyName("__RAW__WeaponBuffDescription")]
        public string RawWeaponBuffDescription { get; set; } = "";
    }

    public class WeaponVector3Data
    {
        [JsonPropertyName("x")]
        public double X { get; set; }

        [JsonPropertyName("y")]
        public double Y { get; set; }

        [JsonPropertyName("z")]
        public double Z { get; set; }
    }

    public class WeaponVisibleEffectData
    {
        [JsonPropertyName("isAppear")]
        public bool IsAppear { get; set; }

        [JsonPropertyName("effectId")]
        public int EffectId { get; set; }

        [JsonPropertyName("weaponIndex")]
        public int WeaponIndex { get; set; }
    }
}
