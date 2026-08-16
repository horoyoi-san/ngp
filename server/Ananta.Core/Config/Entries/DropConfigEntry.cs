using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class DropConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("TemplateId")]
        public int TemplateId { get; set; }

        [JsonPropertyName("LimitNum")]
        public int LimitNum { get; set; }

        [JsonPropertyName("Popularity")]
        public double Popularity { get; set; }

        [JsonPropertyName("Money")]
        public int Money { get; set; }

        [JsonPropertyName("BindingGold")]
        public int BindingGold { get; set; }

        [JsonPropertyName("Item4Count")]
        public int Item4Count { get; set; }

        [JsonPropertyName("DropType")]
        public int DropType { get; set; }

        [JsonPropertyName("Subtype")]
        public string Subtype { get; set; } = "";

        [JsonPropertyName("CommonSpiritTalentExp")]
        public int CommonSpiritTalentExp { get; set; }

        [JsonPropertyName("SpiritTalentExp")]
        public int SpiritTalentExp { get; set; }

        [JsonPropertyName("DropEffect")]
        public int DropEffect { get; set; }

        [JsonPropertyName("DelayDrop")]
        public int DelayDrop { get; set; }

        [JsonPropertyName("ReasonText")]
        public int ReasonText { get; set; }

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("UrbanAttributeIndex")]
        public List<int> UrbanAttributeIndex { get; set; } = new();

        [JsonPropertyName("UrbanAttributeValue")]
        public List<int> UrbanAttributeValue { get; set; } = new();

        [JsonPropertyName("Item1")]
        public List<DropItemEntry> Item1 { get; set; } = new();

        [JsonPropertyName("Item2")]
        public List<DropItemEntry> Item2 { get; set; } = new();

        [JsonPropertyName("Item3")]
        public List<DropItemEntry> Item3 { get; set; } = new();

        [JsonPropertyName("Item4Range")]
        public List<int> Item4Range { get; set; } = new();

        [JsonPropertyName("JobExp")]
        public List<int> JobExp { get; set; } = new();

        [JsonPropertyName("FactionInfo")]
        public List<int> FactionInfo { get; set; } = new();

        [JsonPropertyName("FactionInfluenceInfo")]
        public List<int> FactionInfluenceInfo { get; set; } = new();

        [JsonPropertyName("AbilityExp")]
        public List<int> AbilityExp { get; set; } = new();

        [JsonPropertyName("NpcFavor")]
        public List<int> NpcFavor { get; set; } = new();

        [JsonPropertyName("Fan")]
        public List<DropFanEntry> Fan { get; set; } = new();
    }

    public class DropFanEntry
    {
        [JsonPropertyName("Type")]
        public int Type { get; set; }

        [JsonPropertyName("Count")]
        public int Count { get; set; }
    }

    public class DropItemEntry
    {
        [JsonPropertyName("id1")]
        public int Id1 { get; set; }

        [JsonPropertyName("count")]
        public int Count { get; set; }
    }
}
