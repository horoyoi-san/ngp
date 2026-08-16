using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class GachaConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("PriorityDisplay")]
        public int PriorityDisplay { get; set; }

        [JsonPropertyName("RuleText")]
        public long RuleText { get; set; }

        [JsonPropertyName("ProbabilityText")]
        public int ProbabilityText { get; set; }

        [JsonPropertyName("ShopId")]
        public int ShopId { get; set; }

        [JsonPropertyName("PrizePoolIds")]
        public List<GachaPrizePoolRef> PrizePoolIds { get; set; } = new();

        [JsonPropertyName("Milestone")]
        public List<GachaMilestoneEntry> Milestone { get; set; } = new();

        [JsonPropertyName("StartTime")]
        public GachaDateTime StartTime { get; set; } = new();

        [JsonPropertyName("EndTime")]
        public GachaDateTime EndTime { get; set; } = new();
    }

    public class GachaPrizePoolRef
    {
        [JsonPropertyName("level")]
        public int Level { get; set; }

        [JsonPropertyName("id")]
        public int Id { get; set; }
    }

    public class GachaDateTime
    {
        [JsonPropertyName("year")]
        public int Year { get; set; }

        [JsonPropertyName("month")]
        public int Month { get; set; }

        [JsonPropertyName("day")]
        public int Day { get; set; }

        [JsonPropertyName("hour")]
        public int Hour { get; set; }

        [JsonPropertyName("minute")]
        public int Minute { get; set; }

        [JsonPropertyName("second")]
        public int Second { get; set; }
    }

    public class GachaMilestoneEntry
    {
        [JsonPropertyName("count")]
        public int Count { get; set; }

        [JsonPropertyName("dropId")]
        public int DropId { get; set; }
    }
}
