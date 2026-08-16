using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class VehiclePartConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("PartPath")]
        public string PartPath { get; set; } = "";

        [JsonPropertyName("PartType")]
        public string PartType { get; set; } = "";

        [JsonPropertyName("Desc")]
        public string Desc { get; set; } = "";

        [JsonPropertyName("BindParts")]
        public List<uint> BindParts { get; set; } = new();
    }
}
