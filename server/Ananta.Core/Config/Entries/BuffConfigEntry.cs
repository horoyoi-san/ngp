using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class BuffConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("Type")]
        public int Type { get; set; }

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("Duration")]
        public double Duration { get; set; }

        [JsonPropertyName("HurtInterval")]
        public double HurtInterval { get; set; }

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("Tag")]
        public string Tag { get; set; } = "";

        [JsonPropertyName("IsHidden")]
        public bool IsHidden { get; set; }

        [JsonPropertyName("DeadKeep")]
        public bool DeadKeep { get; set; }

        [JsonPropertyName("UnitStateId")]
        public List<int> UnitStateId { get; set; } = new();

        [JsonPropertyName("DetonatorId")]
        public List<int> DetonatorId { get; set; } = new();

        [JsonPropertyName("ClientDetonatorId")]
        public List<int> ClientDetonatorId { get; set; } = new();

        [JsonPropertyName("EffectIds")]
        public List<int> EffectIds { get; set; } = new();

        [JsonPropertyName("IconId")]
        public long IconId { get; set; }

        [JsonPropertyName("IconIdSGUI")]
        public long IconIdSGUI { get; set; }

        [JsonPropertyName("headIcon")]
        public int HeadIcon { get; set; }

        [JsonPropertyName("SkillStateId")]
        public int SkillStateId { get; set; }

        [JsonPropertyName("ActionGroupId")]
        public int ActionGroupId { get; set; }

        [JsonPropertyName("ConnectType")]
        public int ConnectType { get; set; }

        [JsonPropertyName("BuffFloat")]
        public string BuffFloat { get; set; } = "";

        [JsonPropertyName("BuffFloatColor")]
        public string BuffFloatColor { get; set; } = "";

        [JsonPropertyName("UIElementType")]
        public int UIElementType { get; set; }

        [JsonPropertyName("IsFreezeAction")]
        public bool IsFreezeAction { get; set; }

        [JsonPropertyName("FreezeActionSpeed")]
        public double FreezeActionSpeed { get; set; }

        [JsonPropertyName("NotUnitTimeScale")]
        public bool NotUnitTimeScale { get; set; }

        [JsonPropertyName("IsClientDecide")]
        public bool IsClientDecide { get; set; }

        [JsonPropertyName("ValidRaid")]
        public List<int> ValidRaid { get; set; } = new();

        [JsonPropertyName("ValidTask")]
        public List<int> ValidTask { get; set; } = new();

        [JsonPropertyName("ValidUnitType")]
        public int ValidUnitType { get; set; }

        [JsonPropertyName("CanStruggleorNot")]
        public bool CanStruggleorNot { get; set; }

        [JsonPropertyName("StruggleRemainTime")]
        public double StruggleRemainTime { get; set; }

        [JsonPropertyName("StruggleDecreaseBuffTimePercentage")]
        public double StruggleDecreaseBuffTimePercentage { get; set; } = 1.0;

        [JsonPropertyName("StruggleCD")]
        public double StruggleCD { get; set; } = 0.2;

        [JsonPropertyName("BVBBuffReset")]
        public bool BVBBuffReset { get; set; }

        [JsonPropertyName("BVBBuffRemove")]
        public bool BVBBuffRemove { get; set; }

        [JsonPropertyName("Abandon")]
        public bool Abandon { get; set; }

        [JsonPropertyName("UseEffectTime")]
        public bool UseEffectTime { get; set; }

        [JsonPropertyName("ReplayEffect")]
        public bool ReplayEffect { get; set; }

        [JsonPropertyName("CodeName")]
        public string CodeName { get; set; } = "";

        [JsonPropertyName("AffectedByD")]
        public List<int> AffectedByD { get; set; } = new();

        [JsonPropertyName("BuffAction")]
        public List<int> BuffAction { get; set; } = new();

        [JsonPropertyName("IsEffectConnect")]
        public List<string> IsEffectConnect { get; set; } = new();

        [JsonPropertyName("WeaponAni")]
        public List<string> WeaponAni { get; set; } = new();

        [JsonPropertyName("WeaponInstanceIndex")]
        public int WeaponInstanceIndex { get; set; }

        [JsonPropertyName("WeaponInstanceAni")]
        public List<int> WeaponInstanceAni { get; set; } = new();

        [JsonPropertyName("EnableElectricShockAction")]
        public bool EnableElectricShockAction { get; set; }

        [JsonPropertyName("EatingBuffValue")]
        public string EatingBuffValue { get; set; } = "";

        [JsonPropertyName("EnemyHeadSlotBuffImg")]
        public int EnemyHeadSlotBuffImg { get; set; }

        [JsonPropertyName("AddAnim")]
        public List<int> AddAnim { get; set; } = new();

        [JsonPropertyName("Icon")]
        public long Icon { get; set; }

        [JsonPropertyName("UrbanAttributeName")]
        public List<string> UrbanAttributeName { get; set; } = new();

        [JsonPropertyName("UrbanAttributeAdd")]
        public List<string> UrbanAttributeAdd { get; set; } = new();

        [JsonPropertyName("UrbanAttributeMul")]
        public List<string> UrbanAttributeMul { get; set; } = new();

        [JsonPropertyName("ControlList")]
        public List<int> ControlList { get; set; } = new();

        [JsonPropertyName("ChangeRenderActive")]
        public List<int> ChangeRenderActive { get; set; } = new();

        [JsonPropertyName("__IDX__BuffFloat")]
        public long IdxBuffFloat { get; set; }

        [JsonPropertyName("__RAW__BuffFloat")]
        public string RawBuffFloat { get; set; } = "";

        [JsonPropertyName("Ikconfig")]
        public IkConfigData? Ikconfig { get; set; }

        [JsonPropertyName("HitFly")]
        public HitFlyData? HitFly { get; set; }
    }

    public class IkConfigData
    {
        [JsonPropertyName("isClose")]
        public bool IsClose { get; set; }

        [JsonPropertyName("FadeInTime")]
        public double FadeInTime { get; set; }

        [JsonPropertyName("FadeOutTime")]
        public double FadeOutTime { get; set; }
    }

    public class HitFlyData
    {
        [JsonPropertyName("acceleration")]
        public double Acceleration { get; set; }

        [JsonPropertyName("maxHeight")]
        public double MaxHeight { get; set; }
    }
}
