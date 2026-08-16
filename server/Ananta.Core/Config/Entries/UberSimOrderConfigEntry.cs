using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class UberSimOrderConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("EventId")]
        public uint EventId { get; set; }

        [JsonPropertyName("BUFF")]
        public uint BUFF { get; set; }

        [JsonPropertyName("RandomGoods")]
        public uint RandomGoods { get; set; }

        [JsonPropertyName("Pickup")]
        public uint Pickup { get; set; }

        [JsonPropertyName("Delivery")]
        public uint Delivery { get; set; }

        [JsonPropertyName("DeliveryNPC")]
        public ulong DeliveryNPC { get; set; }

        [JsonPropertyName("Time")]
        public int Time { get; set; }

        [JsonPropertyName("DurationTime")]
        public int DurationTime { get; set; }

        [JsonPropertyName("IntervalTime")]
        public int IntervalTime { get; set; }

        [JsonPropertyName("GoodsPlan")]
        public int GoodsPlan { get; set; }

        [JsonPropertyName("information")]
        public string information { get; set; } = "";

        [JsonPropertyName("Appraiseid")]
        public List<uint> Appraiseid { get; set; } = new();
    }
}
