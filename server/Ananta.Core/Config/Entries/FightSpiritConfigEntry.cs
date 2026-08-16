using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class FightSpiritConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("IsPublish")]
        public bool IsPublish { get; set; }

        [JsonPropertyName("IsShowWeb")]
        public bool IsShowWeb { get; set; }

        [JsonPropertyName("HeadIconVideoId")]
        public int HeadIconVideoId { get; set; }

        [JsonPropertyName("SHeadIconID")]
        public int SHeadIconID { get; set; }

        [JsonPropertyName("SBattleHeadIcon")]
        public int SBattleHeadIcon { get; set; }

        [JsonPropertyName("HavePrivateWeapon")]
        public bool HavePrivateWeapon { get; set; }

        [JsonPropertyName("UnlockUniqueSkill")]
        public bool UnlockUniqueSkill { get; set; }

        [JsonPropertyName("CanJoin")]
        public bool CanJoin { get; set; }

        [JsonPropertyName("Invisible")]
        public bool Invisible { get; set; }

        [JsonPropertyName("Important")]
        public bool Important { get; set; }

        [JsonPropertyName("DispositionDontSwitch")]
        public bool DispositionDontSwitch { get; set; }

        [JsonPropertyName("LockPost")]
        public int LockPost { get; set; }

        [JsonPropertyName("UnlockPost")]
        public int UnlockPost { get; set; }

        [JsonPropertyName("AbilityLevelJump")]
        public int AbilityLevelJump { get; set; }

        [JsonPropertyName("ElementType")]
        public int ElementType { get; set; }

        [JsonPropertyName("FistWeapon")]
        public int FistWeapon { get; set; }

        [JsonPropertyName("PrivateWeapon")]
        public int PrivateWeapon { get; set; }

        [JsonPropertyName("WeaponSlot")]
        public List<string> WeaponSlot { get; set; } = new();

        [JsonPropertyName("AgentId")]
        public int AgentId { get; set; }

        [JsonPropertyName("SguiVerticalDrawing")]
        public int SguiVerticalDrawing { get; set; }

        [JsonPropertyName("NpcCultivationRelatedId")]
        public int NpcCultivationRelatedId { get; set; }

        [JsonPropertyName("BackMoveDistance")]
        public double BackMoveDistance { get; set; }

        [JsonPropertyName("BackMoveTriggerDistance")]
        public double BackMoveTriggerDistance { get; set; }

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("TagList")]
        public List<string> TagList { get; set; } = new();

        [JsonPropertyName("GuideId")]
        public string GuideId { get; set; } = "";

        [JsonPropertyName("CharListTemplateBgColor")]
        public string CharListTemplateBgColor { get; set; } = "";

        [JsonPropertyName("TalentId")]
        public int TalentId { get; set; }

        [JsonPropertyName("DomainAttribute")]
        public int DomainAttribute { get; set; }

        [JsonPropertyName("BasicAttr")]
        public List<int> BasicAttr { get; set; } = new();

        [JsonPropertyName("BasicAttrGrowthCurve")]
        public List<int> BasicAttrGrowthCurve { get; set; } = new();

        [JsonPropertyName("DomainAttr")]
        public List<int> DomainAttr { get; set; } = new();

        [JsonPropertyName("DomainAttrGrowthCurve")]
        public List<int> DomainAttrGrowthCurve { get; set; } = new();

        [JsonPropertyName("Domain")]
        public List<int> Domain { get; set; } = new();

        [JsonPropertyName("ItemId")]
        public List<int> ItemId { get; set; } = new();

        [JsonPropertyName("Number")]
        public List<int> Number { get; set; } = new();

        [JsonPropertyName("SkillUpConsume")]
        public List<int> SkillUpConsume { get; set; } = new();

        [JsonPropertyName("CommonAttackEnhanced")]
        public int CommonAttackEnhanced { get; set; }

        [JsonPropertyName("ActiveSkillEnhanced")]
        public int ActiveSkillEnhanced { get; set; }

        [JsonPropertyName("ChangeAttackEnhanced")]
        public int ChangeAttackEnhanced { get; set; }

        [JsonPropertyName("UniqueSkillEnhanced")]
        public int UniqueSkillEnhanced { get; set; }

        [JsonPropertyName("CharacterLockDistance")]
        public double CharacterLockDistance { get; set; }

        [JsonPropertyName("Weight")]
        public int Weight { get; set; }

        [JsonPropertyName("IsCanFire")]
        public bool IsCanFire { get; set; }

        [JsonPropertyName("ImpactRate")]
        public double ImpactRate { get; set; }

        [JsonPropertyName("UrbanAttribute")]
        public List<int> UrbanAttribute { get; set; } = new();

        [JsonPropertyName("UrbanBuff")]
        public List<int> UrbanBuff { get; set; } = new();

        [JsonPropertyName("UrbanBuffTag")]
        public List<string> UrbanBuffTag { get; set; } = new();

        [JsonPropertyName("DefaultUrbanJob")]
        public int DefaultUrbanJob { get; set; }

        [JsonPropertyName("JobCostLimit")]
        public int JobCostLimit { get; set; }

        [JsonPropertyName("JobLimit")]
        public int JobLimit { get; set; }

        [JsonPropertyName("PassiveSkill")]
        public int PassiveSkill { get; set; }

        [JsonPropertyName("JumpAttackHeight")]
        public int JumpAttackHeight { get; set; }

        [JsonPropertyName("TempSkill")]
        public List<int> TempSkill { get; set; } = new();

        [JsonPropertyName("HeadIconID")]
        public int HeadIconID { get; set; }

        [JsonPropertyName("BattleHeadIcon")]
        public int BattleHeadIcon { get; set; }

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("BodyType")]
        public int BodyType { get; set; }

        [JsonPropertyName("AnimGraph")]
        public int AnimGraph { get; set; }

        [JsonPropertyName("FirmValue")]
        public int FirmValue { get; set; }

        [JsonPropertyName("FirmRecover")]
        public int FirmRecover { get; set; }

        [JsonPropertyName("FirmReset")]
        public int FirmReset { get; set; }

        [JsonPropertyName("BatiBase")]
        public int BatiBase { get; set; }

        [JsonPropertyName("TypeForStiff")]
        public int TypeForStiff { get; set; }
    }
}
