using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class FightSkillConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("FightSkillType")]
        public long FightSkillType { get; set; }

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("IconId")]
        public long IconId { get; set; }

        [JsonPropertyName("SpiritId")]
        public List<long> SpiritId { get; set; } = new();

        [JsonPropertyName("IsLocked")]
        public bool IsLocked { get; set; }

        [JsonPropertyName("IsShowInArmony")]
        public bool IsShowInArmony { get; set; }

        [JsonPropertyName("CommonSkill")]
        public long CommonSkill { get; set; }

        [JsonPropertyName("PressinCommonSkill")]
        public long PressinCommonSkill { get; set; }

        [JsonPropertyName("HeavyCommonSkill")]
        public long HeavyCommonSkill { get; set; }

        [JsonPropertyName("ControlPowerSkill")]
        public int ControlPowerSkill { get; set; }

        [JsonPropertyName("DodgeSkill")]
        public long DodgeSkill { get; set; }

        [JsonPropertyName("DodgeAttackSkill")]
        public int DodgeAttackSkill { get; set; }

        [JsonPropertyName("GousuoSkill")]
        public int GousuoSkill { get; set; }

        [JsonPropertyName("JumpSkill")]
        public int JumpSkill { get; set; }

        [JsonPropertyName("JumpAttackSkill")]
        public int JumpAttackSkill { get; set; }

        [JsonPropertyName("ActiveSkill")]
        public long ActiveSkill { get; set; }

        [JsonPropertyName("UpActiveSkill")]
        public int UpActiveSkill { get; set; }

        [JsonPropertyName("LongPressActiveSkill")]
        public long LongPressActiveSkill { get; set; }

        [JsonPropertyName("UniqueSkill")]
        public long UniqueSkill { get; set; }

        [JsonPropertyName("SwitchSkill")]
        public int SwitchSkill { get; set; }

        [JsonPropertyName("FightSkillGenericId")]
        public int FightSkillGenericId { get; set; }

        [JsonPropertyName("ActionType")]
        public int ActionType { get; set; }

        [JsonPropertyName("ActionTypeSubType")]
        public int ActionTypeSubType { get; set; }

        [JsonPropertyName("FightResHUD")]
        public int FightResHUD { get; set; }

        [JsonPropertyName("Tag")]
        public string Tag { get; set; } = "";

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("GuideId")]
        public string GuideId { get; set; } = "";

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("Text1")]
        public List<string> Text1 { get; set; } = new();

        [JsonPropertyName("Text2")]
        public List<string> Text2 { get; set; } = new();

        [JsonPropertyName("Text3")]
        public List<string> Text3 { get; set; } = new();

        [JsonPropertyName("Text4")]
        public List<string> Text4 { get; set; } = new();

        [JsonPropertyName("Text5")]
        public List<string> Text5 { get; set; } = new();

        [JsonPropertyName("PressinSkilltype")]
        public List<string> PressinSkilltype { get; set; } = new();

        [JsonPropertyName("UnlockCondition1")]
        public int UnlockCondition1 { get; set; }

        [JsonPropertyName("UnlockCondition2")]
        public int UnlockCondition2 { get; set; }

        [JsonPropertyName("UnlockCondition3")]
        public int UnlockCondition3 { get; set; }

        [JsonPropertyName("UnlockCondition4")]
        public int UnlockCondition4 { get; set; }

        [JsonPropertyName("UnlockCondition5")]
        public int UnlockCondition5 { get; set; }

        [JsonPropertyName("UnlockCondition6")]
        public int UnlockCondition6 { get; set; }

        [JsonPropertyName("UnlockCondition7")]
        public int UnlockCondition7 { get; set; }

        [JsonPropertyName("UnlockCondition8")]
        public int UnlockCondition8 { get; set; }

        [JsonPropertyName("Text6")]
        public List<string> Text6 { get; set; } = new();

        [JsonPropertyName("Text7")]
        public List<string> Text7 { get; set; } = new();

        [JsonPropertyName("Text8")]
        public List<string> Text8 { get; set; } = new();

        [JsonPropertyName("__IDX__Name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__Name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__Tag")]
        public long IdxTag { get; set; }

        [JsonPropertyName("__RAW__Tag")]
        public string RawTag { get; set; } = "";

        [JsonPropertyName("__IDX__Description")]
        public long IdxDescription { get; set; }

        [JsonPropertyName("__RAW__Description")]
        public string RawDescription { get; set; } = "";

        [JsonPropertyName("__IDX__Text1")]
        public List<long> IdxText1 { get; set; } = new();

        [JsonPropertyName("__RAW__Text1")]
        public List<string> RawText1 { get; set; } = new();

        [JsonPropertyName("__IDX__Text2")]
        public List<long> IdxText2 { get; set; } = new();

        [JsonPropertyName("__RAW__Text2")]
        public List<string> RawText2 { get; set; } = new();

        [JsonPropertyName("__IDX__Text3")]
        public List<long> IdxText3 { get; set; } = new();

        [JsonPropertyName("__RAW__Text3")]
        public List<string> RawText3 { get; set; } = new();

        [JsonPropertyName("__IDX__Text4")]
        public List<long> IdxText4 { get; set; } = new();

        [JsonPropertyName("__RAW__Text4")]
        public List<string> RawText4 { get; set; } = new();

        [JsonPropertyName("__IDX__Text5")]
        public List<long> IdxText5 { get; set; } = new();

        [JsonPropertyName("__RAW__Text5")]
        public List<string> RawText5 { get; set; } = new();

        [JsonPropertyName("__IDX__Text6")]
        public List<long> IdxText6 { get; set; } = new();

        [JsonPropertyName("__RAW__Text6")]
        public List<string> RawText6 { get; set; } = new();

        [JsonPropertyName("__IDX__Text7")]
        public List<long> IdxText7 { get; set; } = new();

        [JsonPropertyName("__RAW__Text7")]
        public List<string> RawText7 { get; set; } = new();

        [JsonPropertyName("__IDX__Text8")]
        public List<long> IdxText8 { get; set; } = new();

        [JsonPropertyName("__RAW__Text8")]
        public List<string> RawText8 { get; set; } = new();
    }
}
