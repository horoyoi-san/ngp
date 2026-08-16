using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class ConsumableConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("SubType")]
        public int SubType { get; set; }

        [JsonPropertyName("VehicleSubType")]
        public int VehicleSubType { get; set; }

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("ShortDescription")]
        public string ShortDescription { get; set; } = "";

        [JsonPropertyName("SItemIconId")]
        public long SItemIconId { get; set; }

        [JsonPropertyName("Discard")]
        public bool Discard { get; set; }

        [JsonPropertyName("SystemPrice")]
        public int SystemPrice { get; set; }

        [JsonPropertyName("IfShowHoldNum")]
        public bool IfShowHoldNum { get; set; }

        [JsonPropertyName("GiftType")]
        public int GiftType { get; set; }

        [JsonPropertyName("CDType")]
        public int CDType { get; set; }

        [JsonPropertyName("CDTime")]
        public int CDTime { get; set; }

        [JsonPropertyName("ExpireType")]
        public int ExpireType { get; set; }

        [JsonPropertyName("ShowInRewardPanel")]
        public bool ShowInRewardPanel { get; set; }

        [JsonPropertyName("RequireLevel")]
        public int RequireLevel { get; set; }

        [JsonPropertyName("DailyCount")]
        public int DailyCount { get; set; } = -1;

        [JsonPropertyName("CanRepeatUse")]
        public bool CanRepeatUse { get; set; }

        [JsonPropertyName("ButtonName")]
        public int ButtonName { get; set; }

        [JsonPropertyName("Drop")]
        public int Drop { get; set; }

        [JsonPropertyName("ShowDropDetail")]
        public bool ShowDropDetail { get; set; }

        [JsonPropertyName("UseCloseMenu")]
        public bool UseCloseMenu { get; set; }

        [JsonPropertyName("CanLocker")]
        public bool CanLocker { get; set; }

        [JsonPropertyName("ShowDropResult")]
        public bool ShowDropResult { get; set; }

        [JsonPropertyName("IsGallery")]
        public bool IsGallery { get; set; }

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("AgentId")]
        public int AgentId { get; set; }

        [JsonPropertyName("ShowMessageOnUse")]
        public bool ShowMessageOnUse { get; set; }

        [JsonPropertyName("UseItemAction")]
        public string UseItemAction { get; set; } = "";

        [JsonPropertyName("SourceLabels")]
        public List<string> SourceLabels { get; set; } = new();

        [JsonPropertyName("HyperLink")]
        public List<int> HyperLink { get; set; } = new();

        [JsonPropertyName("GiftTags")]
        public List<int> GiftTags { get; set; } = new();

        [JsonPropertyName("ButtonAction")]
        public List<int> ButtonAction { get; set; } = new();

        [JsonPropertyName("CheckBindIdIsOwned")]
        public int CheckBindIdIsOwned { get; set; }

        [JsonPropertyName("BindId")]
        public int BindId { get; set; }

        [JsonPropertyName("SMoneyIconId")]
        public int SMoneyIconId { get; set; }

        [JsonPropertyName("MoneyIconId")]
        public int MoneyIconId { get; set; }

        [JsonPropertyName("Compound")]
        public CompoundData? Compound { get; set; }

        [JsonPropertyName("DynamicExpiryTime")]
        public DynamicExpiryData? DynamicExpiryTime { get; set; }

        [JsonPropertyName("FixedExpiryTime")]
        public FixedExpiryData? FixedExpiryTime { get; set; }

        [JsonPropertyName("HealingNum")]
        public HealingNumData? HealingNum { get; set; }

        [JsonPropertyName("__IDX__Name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__Name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__Description")]
        public long IdxDescription { get; set; }

        [JsonPropertyName("__RAW__Description")]
        public string RawDescription { get; set; } = "";

        [JsonPropertyName("__IDX__ShortDescription")]
        public long IdxShortDescription { get; set; }

        [JsonPropertyName("__RAW__ShortDescription")]
        public string RawShortDescription { get; set; } = "";

        [JsonPropertyName("__IDX__SourceLabels")]
        public List<long> IdxSourceLabels { get; set; } = new();

        [JsonPropertyName("__RAW__SourceLabels")]
        public List<string> RawSourceLabels { get; set; } = new();
    }

    public class CompoundData
    {
        [JsonPropertyName("dropId")]
        public int DropId { get; set; }

        [JsonPropertyName("amount")]
        public int Amount { get; set; }
    }

    public class DynamicExpiryData
    {
        [JsonPropertyName("num")]
        public int Num { get; set; }

        [JsonPropertyName("time")]
        public string Time { get; set; } = "";
    }

    public class FixedExpiryData
    {
        [JsonPropertyName("year")]
        public int Year { get; set; }

        [JsonPropertyName("month")]
        public int Month { get; set; }

        [JsonPropertyName("day")]
        public int Day { get; set; }

        [JsonPropertyName("hour")]
        public int Hour { get; set; }
    }

    public class HealingNumData
    {
        [JsonPropertyName("Healing")]
        public int Healing { get; set; }

        [JsonPropertyName("proportion")]
        public double Proportion { get; set; }
    }
}
